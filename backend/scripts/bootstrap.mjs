import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

const args = Object.fromEntries(process.argv.slice(2).map(value => {
  const i = value.indexOf('=');
  if (!value.startsWith('--') || i < 0) throw new Error('Use --project=ID --org=ID --name=NAME --admin=UID [--apply=true]');
  return [value.slice(2, i), value.slice(i+1)];
}));
if (!args.project || !args.org || !args.name || !args.admin || !/^[a-zA-Z0-9_-]{1,100}$/.test(args.org) || args.name.length > 120) {
  throw new Error('Required valid --project, --org, --name, --admin. No account passwords are accepted.');
}
if (args.apply !== 'true') {
  console.log('DRY RUN: would create organization and initial ADMIN. Rerun with --apply=true using authorized Application Default Credentials.');
  process.exit(0);
}
initializeApp({credential: applicationDefault(), projectId: args.project});
await getAuth().getUser(args.admin); // Require an existing authenticated account.
const db = getFirestore();
const org = db.doc(`organizations/${args.org}`);
await db.runTransaction(async tx => {
  if ((await tx.get(org)).exists) throw new Error('Organization exists; refusing to overwrite its owner or configuration.');
  tx.create(org, {id: args.org, name: args.name, status: 'ACTIVE', createdAt: FieldValue.serverTimestamp()});
  tx.create(org.collection('members').doc(args.admin), {
    userId: args.admin, organizationId: args.org, role: 'ADMIN', status: 'ACTIVE',
  });
});
console.log('Created organization and ADMIN. No personal data seeded.');
