import {before, after, beforeEach, test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {initializeTestEnvironment, assertFails, assertSucceeds} from '@firebase/rules-unit-testing';
import {doc, setDoc, getDoc, updateDoc, deleteDoc, collection, getDocs, query, where, limit, Timestamp, serverTimestamp, runTransaction} from 'firebase/firestore';

let env;
const now = Timestamp.fromMillis(Date.now()-60000);
const incidentId = 'a'.repeat(64);
const trip = (org='a',driverId='driver-a') => ({id:'trip-1',organizationId:org,vehicleId:'bus-1',driverId,
  origin:'Arequipa',destination:'Juliaca',startTime:now,endTime:null,status:'ACTIVE',
  monitoringStatus:'UNAVAILABLE',lastEventAt:null,lastSeenAt:null});
const incident = (overrides={}) => ({id:incidentId,organizationId:'a',tripId:'trip-1',driverId:'driver-a',
  type:'PROLONGED_EYE_CLOSURE',severity:'CRITICAL',detectedAt:Timestamp.fromMillis(Date.now()-1000),receivedAt:serverTimestamp(),
  riskScore:96,reasonCode:'PROLONGED_EYE_CLOSURE',signalQuality:'RELIABLE',monitoringHealth:'HEALTHY',...overrides});
const action = (overrides={}) => ({id:'action-1',organizationId:'a',incidentId,operatorId:'operator-a',
  actionType:'ACKNOWLEDGED',note:'',createdAt:serverTimestamp(),...overrides});
const db = uid => env.authenticatedContext(uid).firestore();
before(async () => {
  env = await initializeTestEnvironment({projectId:'demo-guardian-security',firestore:{host:'127.0.0.1',port:8185,
    rules:await readFile(new URL('../firestore.rules',import.meta.url),'utf8')}});
});
after(async () => {await env?.cleanup();});
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async context => {
    const store = context.firestore();
    for (const org of ['a','b']) {
      await setDoc(doc(store,`organizations/${org}`),{id:org,name:`Synthetic ${org}`,status:'ACTIVE',createdAt:now});
      for (const role of ['driver','operator','admin']) {
        const uid = `${role}-${org}`;
        await setDoc(doc(store,`organizations/${org}/members/${uid}`),{userId:uid,organizationId:org,role:role.toUpperCase(),status:'ACTIVE'});
      }
      await setDoc(doc(store,`organizations/${org}/vehicles/bus-1`),{id:'bus-1',organizationId:org,internalCode:'BUS-001',vehicleType:'BUS',status:'ACTIVE'});
      await setDoc(doc(store,`organizations/${org}/assignments/driver-${org}`),{userId:`driver-${org}`,organizationId:org,vehicleId:'bus-1',status:'ACTIVE'});
      await setDoc(doc(store,`organizations/${org}/trips/trip-1`),trip(org,`driver-${org}`));
    }
  });
});
test('unauthenticated users cannot access tenant or personal data', async () => {
  const store = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(store,'organizations/a')));
  await assertFails(setDoc(doc(store,`organizations/a/incidents/${incidentId}`),incident()));
  await assertFails(getDoc(doc(store,'users/driver-a/reports/x')));
});
test('tenant isolation for driver and operator, including queries', async () => {
  await assertFails(getDoc(doc(db('driver-a'),'organizations/b')));
  await assertFails(getDoc(doc(db('operator-a'),'organizations/b/trips/trip-1')));
  await assertFails(getDocs(collection(db('operator-a'),'organizations/b/incidents')));
  await assertSucceeds(getDocs(query(collection(db('driver-a'),'organizations/a/trips'),where('driverId','==','driver-a'))));
  await assertSucceeds(getDocs(query(collection(db('driver-a'),'organizations/a/incidents'),where('driverId','==','driver-a'),limit(300))));
  await assertSucceeds(getDocs(query(collection(db('driver-a'),'organizations/a/restSessions'),where('driverId','==','driver-a'),limit(200))));
  await assertFails(getDocs(collection(db('driver-a'),'organizations/a/trips')));
});
test('web push subscriptions are opt-in, private and restricted to active staff', async () => {
  const id='e'.repeat(64);
  const subscription={id,organizationId:'a',userId:'operator-a',token:'test-fcm-token',platform:'WEB',updatedAt:serverTimestamp()};
  const ref=doc(db('operator-a'),`organizations/a/alertSubscriptions/${id}`);
  await assertSucceeds(setDoc(ref,subscription));
  await assertSucceeds(getDoc(ref));
  await assertFails(getDoc(doc(db('admin-a'),ref.path)));
  await assertFails(getDocs(collection(db('operator-a'),'organizations/a/alertSubscriptions')));
  await assertFails(setDoc(doc(db('driver-a'),`organizations/a/alertSubscriptions/${'f'.repeat(64)}`),{
    ...subscription,id:'f'.repeat(64),userId:'driver-a'}));
  await assertFails(setDoc(doc(db('operator-b'),`organizations/a/alertSubscriptions/${'f'.repeat(64)}`),{
    ...subscription,id:'f'.repeat(64),userId:'operator-b'}));
  await assertFails(setDoc(doc(db('operator-a'),`organizations/a/alertSubscriptions/${'f'.repeat(64)}`),{
    ...subscription,id:'f'.repeat(64),userId:'admin-a'}));
  await assertFails(updateDoc(ref,{token:'forged',userId:'admin-a'}));
  await assertFails(setDoc(doc(db('operator-a'),`organizations/a/alertDispatches/${incidentId}`),{status:'SENT'}));
  await assertSucceeds(deleteDoc(ref));
});
test('driver cannot elevate role, bootstrap org, create trips or forge assignments', async () => {
  const store=db('driver-a');
  await assertFails(updateDoc(doc(store,'organizations/a/members/driver-a'),{role:'ADMIN'}));
  await assertFails(setDoc(doc(store,'organizations/new'),{id:'new',name:'Bad',status:'ACTIVE',createdAt:serverTimestamp()}));
  await assertFails(setDoc(doc(store,'organizations/a/trips/trip-2'),{...trip(),id:'trip-2'}));
  await assertFails(updateDoc(doc(store,'organizations/a/assignments/driver-a'),{vehicleId:'another'}));
  await assertFails(setDoc(doc(store,'organizations/a/members/intruder'),{userId:'intruder',organizationId:'a',role:'ADMIN',status:'ACTIVE'}));
});
test('only ADMIN manages valid members vehicles assignments and assigned trips', async () => {
  const admin=db('admin-a');
  const member={userId:'new-driver',organizationId:'a',role:'DRIVER',status:'ACTIVE'};
  await assertSucceeds(setDoc(doc(admin,'organizations/a/members/new-driver'),member));
  await assertFails(setDoc(doc(db('operator-a'),'organizations/a/members/forbidden'),{...member,userId:'forbidden'}));
  await assertFails(updateDoc(doc(admin,'organizations/b/vehicles/bus-1'),{status:'INACTIVE'}));
  await assertFails(updateDoc(doc(admin,'organizations/a/vehicles/bus-1'),{unexpected:'x'}));
  await assertSucceeds(setDoc(doc(admin,'organizations/a/trips/new-trip'),{...trip(),id:'new-trip',status:'ASSIGNED'}));
  await assertFails(setDoc(doc(admin,'organizations/a/trips/forged'),{...trip(),id:'forged',driverId:'operator-a'}));
});
test('only an administrator configures a validated fleet emergency number', async () => {
  const organization=doc(db('admin-a'),'organizations/a');
  await assertSucceeds(updateDoc(organization,{emergencyPhone:'+51987654321',emergencyLabel:'Central de emergencia'}));
  assert.equal((await getDoc(doc(db('driver-a'),'organizations/a'))).data().emergencyPhone,'+51987654321');
  await assertFails(updateDoc(doc(db('operator-a'),'organizations/a'),{emergencyPhone:'+51999999999'}));
  await assertFails(updateDoc(doc(db('driver-a'),'organizations/a'),{emergencyPhone:'+51999999999'}));
  await assertFails(updateDoc(organization,{emergencyPhone:'not-a-phone'}));
  await assertFails(updateDoc(organization,{emergencyPhone:'123',status:'INACTIVE'}));
});
test('driver publishes valid immutable incident only for assigned active trip', async () => {
  const ref=doc(db('driver-a'),`organizations/a/incidents/${incidentId}`);
  await assertSucceeds(setDoc(ref,incident()));
  await assertFails(updateDoc(ref,{riskScore:0}));
  await assertFails(deleteDoc(ref));
  await assertFails(updateDoc(doc(db('operator-a'),ref.path),{severity:'INFO'}));
  await assertFails(setDoc(doc(db('driver-b'),`organizations/a/incidents/${'b'.repeat(64)}`),incident({id:'b'.repeat(64),driverId:'driver-b'})));
  await assertSucceeds(updateDoc(doc(db('driver-a'),'organizations/a/trips/trip-1'),{status:'COMPLETED',endTime:serverTimestamp(),monitoringStatus:'PAUSED',lastSeenAt:serverTimestamp()}));
  await assertFails(setDoc(doc(db('driver-a'),`organizations/a/incidents/${'c'.repeat(64)}`),incident({id:'c'.repeat(64)})));
});
test('invalid incident fields values times and missing trip rejected', async () => {
  const invalid=[{riskScore:101},{riskScore:-1},{riskScore:'96'},{receivedAt:now},{detectedAt:Timestamp.fromMillis(1)},
    {tripId:'missing'},{driverId:'other'},{organizationId:'b'},{frame:'forbidden'},{type:'ACCIDENT'},
    {type:'SIGNAL_UNAVAILABLE',reasonCode:'SIGNAL_UNAVAILABLE',severity:'CRITICAL'},
    {signalQuality:'INSUFFICIENT'},{reasonCode:'invented'},{severity:'UNKNOWN'},{monitoringHealth:'fake'}];
  for (const patch of invalid) await assertFails(setDoc(doc(db('driver-a'),`organizations/a/incidents/${incidentId}`),incident(patch)));
});
test('unavailable signal is INFO with zero fatigue risk', async () => {
  await assertSucceeds(setDoc(doc(db('driver-a'),`organizations/a/incidents/${incidentId}`),incident({
    type:'SIGNAL_UNAVAILABLE',reasonCode:'SIGNAL_UNAVAILABLE',severity:'INFO',riskScore:0,signalQuality:'INSUFFICIENT',monitoringHealth:'UNAVAILABLE'})));
});
test('operator actions append with authenticated identity, never rewrite detection', async () => {
  await setDoc(doc(db('driver-a'),`organizations/a/incidents/${incidentId}`),incident());
  const ref=doc(db('operator-a'),'organizations/a/operatorActions/action-1');
  await assertSucceeds(setDoc(ref,action()));
  await assertFails(updateDoc(ref,{note:'overwrite'}));
  await assertFails(deleteDoc(ref));
  for (const patch of [{operatorId:'admin-a'},{incidentId:'missing'},{note:'x'.repeat(1001)},
    {actionType:'RESOLVED',note:''},{createdAt:now},{extra:true}]) {
    await assertFails(setDoc(doc(db('operator-a'),'organizations/a/operatorActions/bad'),action({id:'bad',...patch})));
  }
  await assertFails(setDoc(doc(db('driver-a'),'organizations/a/operatorActions/driver'),action({id:'driver',operatorId:'driver-a'})));
  await assertFails(setDoc(doc(db('operator-b'),'organizations/a/operatorActions/other'),action({id:'other',operatorId:'operator-b'})));
});
test('trip lifecycle prevents reassignment timestamps spoofing and resurrection', async () => {
  const ref=doc(db('driver-a'),'organizations/a/trips/trip-1');
  await assertFails(updateDoc(ref,{driverId:'other'}));
  await assertFails(updateDoc(ref,{lastSeenAt:Timestamp.fromMillis(Date.now()+60000)}));
  await assertSucceeds(updateDoc(ref,{monitoringStatus:'ACTIVE',lastSeenAt:serverTimestamp()}));
  await assertSucceeds(updateDoc(ref,{monitoringStatus:'PAUSED',lastSeenAt:serverTimestamp()}));
  await assertSucceeds(updateDoc(ref,{status:'COMPLETED',endTime:serverTimestamp(),monitoringStatus:'PAUSED'}));
  await assertFails(updateDoc(ref,{status:'ACTIVE',endTime:null}));
});
test('delayed health keeps its observed time and cannot move backwards', async () => {
  const ref=doc(db('driver-a'),'organizations/a/trips/trip-1');
  const observed=Timestamp.fromMillis(Date.now()-30000);
  await assertSucceeds(updateDoc(ref,{lastSeenAt:observed,monitoringStatus:'ACTIVE'}));
  assert.equal((await getDoc(ref)).data().lastSeenAt.toMillis(),observed.toMillis());
  await assertFails(updateDoc(ref,{lastSeenAt:Timestamp.fromMillis(observed.toMillis()-1000)}));
});
test('revoked membership blocks pending publication', async () => {
  await updateDoc(doc(db('admin-a'),'organizations/a/members/driver-a'),{status:'INACTIVE'});
  await assertFails(setDoc(doc(db('driver-a'),`organizations/a/incidents/${incidentId}`),incident()));
});
test('real emulator flow: assigned trip → incident → idempotent retry → acknowledgement → action history', async () => {
  const store=db('driver-a');
  const assigned=doc(db('admin-a'),'organizations/a/trips/new-trip');
  await setDoc(assigned,{...trip(),id:'new-trip',status:'ASSIGNED'});
  await updateDoc(doc(store,assigned.path),{status:'ACTIVE',lastSeenAt:serverTimestamp()});
  const ref=doc(store,`organizations/a/incidents/${incidentId}`);
  async function deliver() {
    await runTransaction(store,async tx => {
      const old=await tx.get(ref);
      if (!old.exists()) tx.set(ref,incident({tripId:'new-trip'}));
    });
  }
  await deliver(); await deliver();
  const operator=db('operator-a');
  const incidents=await getDocs(collection(operator,'organizations/a/incidents'));
  assert.equal(incidents.size,1);
  const data=incidents.docs[0].data();
  assert.ok(data.receivedAt.toMillis() >= data.detectedAt.toMillis());
  await setDoc(doc(operator,'organizations/a/operatorActions/action-1'),action());
  await setDoc(doc(operator,'organizations/a/operatorActions/action-2'),action({id:'action-2',actionType:'ACTION_RECORDED',note:'Se recomendó detenerse en un lugar seguro.'}));
  assert.equal((await getDocs(collection(operator,'organizations/a/operatorActions'))).size,2);
  assert.equal((await getDoc(ref)).data().riskScore,96);
});
test('personal reports remain owner-only with original validated schema', async () => {
  const report={schemaVersion:1,tripId:'personal-trip',startedAtMs:1,endedAtMs:2,drivingDurationMs:1,
    warningAlerts:0,dangerAlerts:0,yawnCount:0,closedEyeDurationMs:0,noFaceEvents:0,averageRisk:0,maxRisk:0,
    dominantLevel:'normal',startBatteryLevel:null,endBatteryLevel:null,startTemperatureC:null,endTemperatureC:null,maxTemperatureC:null,isCharging:false,updatedAt:serverTimestamp()};
  const ref=doc(db('driver-a'),'users/driver-a/reports/report-1');
  await assertSucceeds(setDoc(ref,report));
  await assertFails(getDoc(doc(db('operator-a'),ref.path)));
  await assertSucceeds(deleteDoc(ref));
});
test('completed voluntary rests are validated, immutable and tenant-scoped', async () => {
  const id='d'.repeat(64),end=Timestamp.fromMillis(Date.now()-1000),start=Timestamp.fromMillis(end.toMillis()-10000);
  const rest={id,organizationId:'a',tripId:'trip-1',driverId:'driver-a',startedAt:start,endedAt:end,durationMs:10000,
    recommendationReason:'MANUAL',voluntarilyConfirmed:true,receivedAt:serverTimestamp()};
  const ref=doc(db('driver-a'),`organizations/a/restSessions/${id}`);
  await assertSucceeds(setDoc(ref,rest));
  await assertSucceeds(getDoc(doc(db('operator-a'),ref.path)));
  await assertFails(getDoc(doc(db('operator-b'),ref.path)));
  await assertFails(updateDoc(ref,{durationMs:1}));
  await assertFails(deleteDoc(doc(db('operator-a'),ref.path)));
  const badId='f'.repeat(64);
  for(const patch of [{durationMs:9},{voluntarilyConfirmed:false},{latitude:12},{startedAt:now,endedAt:null},
    {driverId:'driver-b'},{receivedAt:now},{recommendationReason:'x'.repeat(121)}]) {
    await assertFails(setDoc(doc(db('driver-a'),`organizations/a/restSessions/${badId}`),{...rest,id:badId,...patch}));
  }
});
test('late rest sync remains possible for own completed trip within its interval', async () => {
  const end=Timestamp.fromMillis(Date.now()-1000),start=Timestamp.fromMillis(end.toMillis()-10000);
  await updateDoc(doc(db('driver-a'),'organizations/a/trips/trip-1'),{status:'COMPLETED',endTime:end,monitoringStatus:'PAUSED'});
  const id='d'.repeat(64),rest={id,organizationId:'a',tripId:'trip-1',driverId:'driver-a',startedAt:start,endedAt:end,
    durationMs:10000,recommendationReason:'MANUAL',voluntarilyConfirmed:true,receivedAt:serverTimestamp()};
  await assertSucceeds(setDoc(doc(db('driver-a'),`organizations/a/restSessions/${id}`),rest));
  await assertFails(setDoc(doc(db('driver-a'),`organizations/a/restSessions/${'f'.repeat(64)}`),{...rest,id:'f'.repeat(64),
    endedAt:Timestamp.fromMillis(end.toMillis()+1000),durationMs:11000}));
});
