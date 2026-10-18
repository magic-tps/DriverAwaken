'use client';
import { useEffect, useState } from 'react';
import { deleteDoc, doc, serverTimestamp, setDoc } from 'firebase/firestore';
import { deleteToken, getMessaging, getToken, isSupported } from 'firebase/messaging';
import { firebaseError, firebaseClient } from '@/lib/firebase';

type Client = NonNullable<ReturnType<typeof firebaseClient>>;
const storageKey = (org: string, uid: string) => `guardian.alert.${org}.${uid}`;

async function tokenId(token: string) {
  const bytes = new TextEncoder().encode(token);
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)].map(byte => byte.toString(16).padStart(2, '0')).join('');
}

export async function disableSupervisorAlerts(client: Client, org: string, uid: string) {
  const key = storageKey(org, uid);
  const id = localStorage.getItem(key);
  if (!id) return;
  // Keep the local key when Firestore is offline, so the user can retry.
  await deleteDoc(doc(client.db, 'organizations', org, 'alertSubscriptions', id));
  if (await isSupported()) await deleteToken(getMessaging(client.app));
  localStorage.removeItem(key);
}

export function AlertSubscription({ client, org, uid }: { client: Client; org: string; uid: string }) {
  const [enabled, setEnabled] = useState(false);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const deliveryAvailable = Boolean(
    process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY &&
    process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID &&
    process.env.NEXT_PUBLIC_PUSH_DELIVERY_ENABLED === 'true',
  );
  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setEnabled(Boolean(localStorage.getItem(storageKey(org, uid))));
  }, [org, uid]);

  async function toggle() {
    setBusy(true); setMessage('');
    try {
      if (enabled) {
        await disableSupervisorAlerts(client, org, uid);
        setEnabled(false); setMessage('Avisos de este navegador desactivados.');
        return;
      }
      if (!deliveryAvailable) {
        throw new Error('Los avisos push aún no están disponibles en este despliegue. La central en vivo sigue disponible.');
      }
      if (!('serviceWorker' in navigator) || !('Notification' in window) || !(await isSupported())) {
        throw new Error('Este navegador no admite notificaciones push de Firebase. La central en vivo sigue disponible.');
      }
      const vapidKey = process.env.NEXT_PUBLIC_FIREBASE_VAPID_KEY;
      if (!vapidKey || !process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID) {
        throw new Error('Falta configurar FCM Web Push para esta central.');
      }
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') throw new Error('El navegador no autorizó los avisos.');
      const basePath = process.env.NEXT_PUBLIC_SITE_BASE_PATH ?? '';
      const worker = await navigator.serviceWorker.register(`${basePath}/alert-sw.js`, { scope: `${basePath}/` });
      const token = await getToken(getMessaging(client.app), { vapidKey, serviceWorkerRegistration: worker });
      if (!token) throw new Error('Firebase no entregó un identificador de notificaciones.');
      const id = await tokenId(token);
      const key = storageKey(org, uid);
      const previous = localStorage.getItem(key);
      await setDoc(doc(client.db, 'organizations', org, 'alertSubscriptions', id), {
        id, organizationId: org, userId: uid, token, platform: 'WEB', updatedAt: serverTimestamp(),
      });
      if (previous && previous !== id) await deleteDoc(doc(client.db, 'organizations', org, 'alertSubscriptions', previous));
      localStorage.setItem(key, id);
      setEnabled(true); setMessage('Avisos activados para este navegador.');
    } catch (error) {
      setMessage(error instanceof Error && !('code' in error) ? error.message : firebaseError(error));
    } finally { setBusy(false); }
  }

  return <div className="alert-subscription"><button type="button" className="button ghost small" onClick={() => void toggle()} disabled={busy || (!deliveryAvailable && !enabled)} aria-pressed={enabled}>{busy ? 'Configurando avisos…' : enabled ? 'Avisos activos · desactivar' : 'Activar avisos'}</button>{!deliveryAvailable && !enabled && <span className="microcopy">Avisos push no disponibles en este despliegue; la central en vivo sigue operativa.</span>}{message && <span role="status" className="microcopy">{message}</span>}</div>;
}
