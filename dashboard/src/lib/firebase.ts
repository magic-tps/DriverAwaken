import { getApp, getApps, initializeApp } from 'firebase/app';
import { connectAuthEmulator, getAuth } from 'firebase/auth';
import { connectFirestoreEmulator, getFirestore } from 'firebase/firestore';

const config = {
  apiKey: process.env.NEXT_PUBLIC_FIREBASE_API_KEY,
  authDomain: process.env.NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.NEXT_PUBLIC_FIREBASE_PROJECT_ID,
  appId: process.env.NEXT_PUBLIC_FIREBASE_APP_ID,
  messagingSenderId: process.env.NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
};
let connected = false;
export function emulatorPort(value: string | undefined, fallback: number) {
  const port = value === undefined ? fallback : Number(value);
  if (!Number.isInteger(port) || port < 1024 || port > 65535) throw new Error('Invalid local emulator port.');
  return port;
}
export function firebaseClient() {
  if (![config.apiKey, config.authDomain, config.projectId, config.appId].every(Boolean)) return null;
  const app = getApps().length ? getApp() : initializeApp(config);
  const auth = getAuth(app);
  const db = getFirestore(app);
  if (process.env.NEXT_PUBLIC_USE_EMULATORS === 'true' && !connected) {
    connectAuthEmulator(auth, `http://127.0.0.1:${emulatorPort(process.env.NEXT_PUBLIC_FIREBASE_AUTH_EMULATOR_PORT, 9098)}`, { disableWarnings: true });
    connectFirestoreEmulator(db, '127.0.0.1', emulatorPort(process.env.NEXT_PUBLIC_FIRESTORE_EMULATOR_PORT, 8085));
    connected = true;
  }
  return { app, auth, db };
}
export function firebaseError(error: unknown): string {
  const code = typeof error === 'object' && error !== null && 'code' in error ? String(error.code) : '';
  if (code.includes('permission-denied')) return 'Acceso denegado. Verifica la membresía activa, el rol y las reglas de la organización.';
  if (code.includes('invalid-credential') || code.includes('wrong-password') || code.includes('user-not-found')) return 'No se pudo iniciar sesión con esas credenciales.';
  if (code.includes('too-many-requests')) return 'Demasiados intentos. Espera antes de volver a intentar.';
  if (code.includes('network') || code.includes('unavailable')) return 'No hay conexión con Firebase. Conserva la nota y vuelve a intentar.';
  if (code.includes('failed-precondition')) return 'La operación requiere una configuración pendiente en Firestore. Revisa los índices y el contrato.';
  if (code.includes('operation-not-allowed')) return 'El proveedor de correo y contraseña debe habilitarse en Firebase Authentication.';
  return 'No se pudo completar la operación. Verifica la configuración y vuelve a intentar.';
}
