import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { initializeApp } from 'firebase-admin/app';
import { getFirestore, FieldValue, Timestamp } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';
import { alertText, recipients, shouldDispatch } from './alert-policy.mjs';
import { CoachingAccessError, createMemoryClient, handleCoachingRequest, memoryConfig } from './coaching-notes.mjs';

initializeApp();

export const notifyFleetIncident = onDocumentCreated({
  document: 'organizations/{org}/incidents/{incidentId}',
  region: 'us-central1',
  retry: true,
}, async event => {
  const incident = event.data?.data();
  const orgId = event.params.org;
  const incidentId = event.params.incidentId;
  if (!incident || incident.organizationId !== orgId || incident.id !== incidentId) return;
  const db = getFirestore();
  const org = db.collection('organizations').doc(orgId);
  const orgSnapshot = await org.get();
  if (!shouldDispatch(incident, orgSnapshot.data())) return;

  // Firestore events can be delivered more than once. A short lease prevents
  // concurrent sends; the notification tag collapses a retried display.
  const receipt = org.collection('alertDispatches').doc(incidentId);
  const claimed = await db.runTransaction(async tx => {
    const previous = await tx.get(receipt);
    const data = previous.data();
    if (data?.status === 'SENT') return false;
    if (data?.status === 'SENDING' && data.leaseUntil?.toMillis() > Date.now()) {
      throw new Error('Alert dispatch already in progress; retry after lease.');
    }
    tx.set(receipt, {
      status: 'SENDING', incidentId, organizationId: orgId,
      leaseUntil: Timestamp.fromMillis(Date.now() + 120_000),
      attempts: (data?.attempts ?? 0) + 1,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return true;
  });
  if (!claimed) return;

  try {
    const subscriptions = await org.collection('alertSubscriptions').get();
    const values = subscriptions.docs.map(doc => ({ id: doc.id, ...doc.data() }))
      .filter(value => value.organizationId === orgId);
    const userIds = [...new Set(values.map(value => value.userId).filter(Boolean))];
    const memberships = new Map();
    for (const userId of userIds) {
      const member = await org.collection('members').doc(userId).get();
      const data = member.data();
      memberships.set(userId, data?.organizationId === orgId ? data : null);
    }
    const targets = recipients(values, memberships, incident);
    const text = alertText(incident);
    let delivered = 0;
    let invalid = 0;
    for (let index = 0; index < targets.length; index += 500) {
      const batch = targets.slice(index, index + 500);
      const result = await getMessaging().sendEachForMulticast({
        tokens: batch.map(target => target.token),
        data: { organizationId: orgId, incidentId, severity: incident.severity },
        webpush: {
          headers: { Urgency: incident.severity === 'CRITICAL' ? 'high' : 'normal' },
          notification: { ...text, tag: incidentId, requireInteraction: incident.severity === 'CRITICAL' },
        },
      });
      delivered += result.successCount;
      for (let i = 0; i < result.responses.length; i++) {
        const response = result.responses[i];
        if (response.success) continue;
        const code = response.error?.code;
        if (code === 'messaging/registration-token-not-registered' || code === 'messaging/invalid-registration-token') {
          await org.collection('alertSubscriptions').doc(batch[i].id).delete();
          invalid++;
          continue;
        }
        throw response.error ?? new Error('FCM delivery failed');
      }
    }
    await receipt.update({ status: 'SENT', delivered, invalid, updatedAt: FieldValue.serverTimestamp() });
  } catch (error) {
    await receipt.update({ status: 'FAILED', updatedAt: FieldValue.serverTimestamp() });
    throw error;
  }
});

// Optional driver coaching notes. Unrelated to incident detection and alert dispatch above.
export const driverCoachingNotes = onCall({ region: 'us-central1', timeoutSeconds: 20 }, async request => {
  const config = memoryConfig(process.env);
  const db = getFirestore();
  try {
    return await handleCoachingRequest({
      uid: request.auth?.uid,
      data: request.data,
      readDoc: async path => { const snapshot = await db.doc(path).get(); return snapshot.exists ? snapshot.data() : null; },
      memory: config ? createMemoryClient({ config }) : null,
    });
  } catch (error) {
    if (error instanceof CoachingAccessError) throw new HttpsError(error.code, error.message);
    throw error;
  }
});
