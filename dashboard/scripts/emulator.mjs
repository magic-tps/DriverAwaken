// Disposable localhost-only integration configuration; never production credentials.
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const mode = process.argv[2];
if (mode !== 'build' && mode !== 'test') throw new Error('Expected build or test.');
const projectId = process.env.GUARDIAN_EMULATOR_PROJECT ?? 'demo-guardian';
if (!/^demo-[a-z0-9-]+$/.test(projectId)) throw new Error('Only demo-* emulator projects are allowed.');
function port(value, fallback) {
  const result = value === undefined ? fallback : Number(value);
  if (!Number.isInteger(result) || result < 1024 || result > 65535) throw new Error('Invalid local emulator port.');
  return String(result);
}
const relative = mode === 'build' ? '../node_modules/next/dist/bin/next' : '../node_modules/@playwright/test/cli.js';
// These cases share one fictional organization; serialize its administrative writes.
const args = mode === 'build' ? ['build'] : ['test', 'e2e/emulator.spec.ts', '--workers=1'];
const result = spawnSync(process.execPath, [fileURLToPath(new URL(relative, import.meta.url)), ...args], {
  stdio: 'inherit',
  env: {
    ...process.env,
    NEXT_PUBLIC_FIREBASE_API_KEY: 'demo-guardian-emulator',
    NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN: `${projectId}.firebaseapp.com`,
    NEXT_PUBLIC_FIREBASE_PROJECT_ID: projectId,
    NEXT_PUBLIC_FIREBASE_APP_ID: 'guardian-emulator',
    NEXT_PUBLIC_USE_EMULATORS: 'true',
    NEXT_PUBLIC_FIREBASE_AUTH_EMULATOR_PORT: port(process.env.GUARDIAN_AUTH_EMULATOR_PORT, 9098),
    NEXT_PUBLIC_FIRESTORE_EMULATOR_PORT: port(process.env.GUARDIAN_FIRESTORE_EMULATOR_PORT, 8085),
    FIREBASE_E2E: 'true',
  },
});
if (result.error) throw result.error;
process.exitCode = result.status ?? 1;
