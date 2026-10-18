import { defineConfig, devices } from '@playwright/test';
export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  use: { baseURL: 'http://127.0.0.1:3100', trace: 'retain-on-failure', launchOptions: process.env.GUARDIAN_BROWSER_EXECUTABLE ? { executablePath: process.env.GUARDIAN_BROWSER_EXECUTABLE } : {} },
  projects: [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }, { name: 'mobile-chromium', use: { ...devices['Pixel 7'] } }],
  webServer: { command: 'node scripts/serve.mjs', url: 'http://127.0.0.1:3100', reuseExistingServer: !process.env.CI },
  reporter: [['list']],
});
