// This fixture refuses every remote endpoint. Its people and fleet are fictional.
import {initializeApp as adminApp} from 'firebase-admin/app';
import {getAuth as adminAuth} from 'firebase-admin/auth';
import {getFirestore as adminStore, Timestamp as AdminTimestamp} from 'firebase-admin/firestore';
import {initializeApp, deleteApp} from 'firebase/app';
import {getAuth, connectAuthEmulator, signInWithEmailAndPassword} from 'firebase/auth';
import {getFirestore, connectFirestoreEmulator, doc, runTransaction, Timestamp, serverTimestamp, terminate} from 'firebase/firestore';
function loopbackPort(value) {
  const match = /^127\.0\.0\.1:(\d{4,5})$/.exec(value ?? '');
  const port = Number(match?.[1]);
  if (!match || port < 1024 || port > 65535) throw new Error('Only explicit 127.0.0.1 emulator hosts with valid ports are allowed.');
  return port;
}
const firestorePort = loopbackPort(process.env.FIRESTORE_EMULATOR_HOST);
const authPort = loopbackPort(process.env.FIREBASE_AUTH_EMULATOR_HOST);
const projectId = process.env.GUARDIAN_EMULATOR_PROJECT ?? 'demo-guardian';
if (!/^demo-[a-z0-9-]+$/.test(projectId)) throw new Error('Only demo-* emulator projects are allowed.');
adminApp({projectId});
const auth=adminAuth(), store=adminStore();
for(const role of ['admin','operator','driver']) {
  try { await auth.getUser(`demo-${role}`); }
  catch(error) {
    if(error.code!=='auth/user-not-found') throw error;
    await auth.createUser({uid:`demo-${role}`,email:`${role}@guardian.test`,password:'GuardianDemo2026!'});
  }
}
const org=store.doc('organizations/andes-emulator');
const started=AdminTimestamp.fromMillis(Date.now()-60000);
await store.runTransaction(async tx => {
  if((await tx.get(org)).exists) return;
  tx.create(org,{id:'andes-emulator',name:'Andes Emulator — DATOS SIMULADOS',status:'ACTIVE',createdAt:started});
  for(const role of ['admin','operator','driver']) tx.create(org.collection('members').doc(`demo-${role}`),{
    userId:`demo-${role}`,organizationId:org.id,role:role.toUpperCase(),status:'ACTIVE'});
  tx.create(org.collection('vehicles').doc('BUS-001'),{id:'BUS-001',organizationId:org.id,internalCode:'BUS-001',vehicleType:'BUS',status:'ACTIVE'});
  tx.create(org.collection('assignments').doc('demo-driver'),{userId:'demo-driver',organizationId:org.id,vehicleId:'BUS-001',status:'ACTIVE'});
  tx.create(org.collection('trips').doc('trip-emulator'),{id:'trip-emulator',organizationId:org.id,vehicleId:'BUS-001',driverId:'demo-driver',
    origin:'Arequipa',destination:'Juliaca',startTime:started,endTime:null,status:'ACTIVE',monitoringStatus:'UNAVAILABLE',lastSeenAt:null,lastEventAt:null});
});
// Detection is emitted through the unprivileged driver SDK and real rules.
const client=initializeApp({projectId,apiKey:'demo-guardian-emulator',appId:'guardian-emulator'},'emulator-fixture');
const clientAuth=getAuth(client); connectAuthEmulator(clientAuth,`http://127.0.0.1:${authPort}`,{disableWarnings:true});
const db=getFirestore(client); connectFirestoreEmulator(db,'127.0.0.1',firestorePort);
await signInWithEmailAndPassword(clientAuth,'driver@guardian.test','GuardianDemo2026!');
const id='e'.repeat(64), ref=doc(db,`organizations/andes-emulator/incidents/${id}`);
await runTransaction(db,async tx => {
  if((await tx.get(ref)).exists()) return;
  tx.set(ref,{id,organizationId:org.id,tripId:'trip-emulator',driverId:'demo-driver',type:'PROLONGED_EYE_CLOSURE',
    severity:'CRITICAL',detectedAt:Timestamp.now(),receivedAt:serverTimestamp(),riskScore:96,reasonCode:'PROLONGED_EYE_CLOSURE',signalQuality:'RELIABLE',monitoringHealth:'HEALTHY'});
  tx.update(doc(db,'organizations/andes-emulator/trips/trip-emulator'),{monitoringStatus:'ACTIVE',lastEventAt:serverTimestamp(),lastSeenAt:serverTimestamp()});
});
const restId='d'.repeat(64), restRef=doc(db,`organizations/andes-emulator/restSessions/${restId}`);
await runTransaction(db,async tx=>{
  if((await tx.get(restRef)).exists()) return;
  const end=Timestamp.fromMillis(Date.now()-1000),start=Timestamp.fromMillis(end.toMillis()-10000);
  tx.set(restRef,{id:restId,organizationId:org.id,tripId:'trip-emulator',driverId:'demo-driver',startedAt:start,endedAt:end,
    durationMs:10000,recommendationReason:'EMULATOR_SELF_REPORTED',voluntarilyConfirmed:true,receivedAt:serverTimestamp()});
});
await terminate(db); await deleteApp(client);
console.log('Local fictional fleet seeded: andes-emulator. Driver SDK incident accepted by rules. See DEPLOYMENT.md for fixture accounts.');
