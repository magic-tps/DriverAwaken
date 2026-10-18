import { expect, test, type Page } from '@playwright/test';
import { readFile } from 'node:fs/promises';

test.describe('Firebase emulator integration — FICTIONAL FIXTURES ONLY', () => {
  test.setTimeout(60_000);
  test.skip(process.env.FIREBASE_E2E !== 'true', 'Requires an emulator-configured static build and local seed-emulators.mjs fixture.');
  async function login(page: Page, role: 'operator' | 'driver' | 'admin') {
    await page.goto('/dashboard/');
    await expect(page.getByRole('heading', { name: 'Bienvenido a la central.' })).toBeVisible({ timeout: 15_000 });
    await page.getByLabel('Correo electrónico').fill(`${role}@guardian.test`);
    await page.getByLabel('Contraseña').fill('GuardianDemo2026!');
    await page.getByRole('button', { name: 'Ingresar a la central' }).click();
    await page.getByLabel('Identificador de organización').fill('andes-emulator');
    await page.getByRole('button', { name: 'Abrir organización' }).click();
  }
  test('operator sees driver-SDK event, appends a response, and selection survives navigation', async ({ page }, info) => {
    await login(page, 'operator');
    await expect(page.getByRole('heading', { name: 'Cierre ocular prolongado', exact: true })).toBeVisible();
    await expect(page.getByText('Datos confirmados por Firestore', { exact: true })).toBeVisible();
    const acknowledge = page.getByRole('button', { name: 'Reconocer incidente', exact: true });
    if (await acknowledge.count() && await acknowledge.isEnabled()) await acknowledge.click();
    const note = `Respuesta ficticia E2E ${info.project.name} ${Date.now()}`;
    await page.getByLabel('Acción o seguimiento').fill(note);
    await page.getByRole('button', { name: 'Registrar acción', exact: true }).click();
    await expect(page.getByText(note, { exact: true })).toBeVisible();
    await page.getByRole('link', { name: 'Viajes', exact: true }).click();
    await expect(page.getByRole('heading', { name: 'Viajes y estado de monitoreo' })).toBeVisible();
    await expect(page.getByText('Arequipa → Juliaca', { exact: true })).toBeVisible();
    await page.getByRole('link', { name: 'Incidentes', exact: true }).click();
    await expect(page.getByText(note, { exact: true })).toBeVisible();
  });
  test('driver cannot open operations central', async ({ page }) => {
    await login(page, 'driver');
    await expect(page.getByRole('alert').filter({ hasText: 'Esta central requiere el rol OPERATOR o ADMIN' })).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Cierre ocular prolongado', exact: true })).toHaveCount(0);
  });
  test('operator sees actual driver membership, rest and consistently filtered report export', async ({ page }) => {
    await login(page, 'operator');
    await page.getByRole('link', { name: 'Conductores', exact: true }).click();
    await expect(page.getByRole('heading', { name: 'Conductores de la organización' })).toBeVisible();
    await expect(page.getByRole('cell', { name: 'demo-driver', exact: true })).toBeVisible();
    await expect(page.getByRole('cell', { name: '96/100', exact: false })).toBeVisible();
    await page.getByRole('link', { name: 'Descansos', exact: true }).click();
    await expect(page.getByRole('heading', { name: 'Descansos autodeclarados', exact: true })).toBeVisible();
    await expect(page.getByText('EMULATOR_SELF_REPORTED', { exact: true })).toBeVisible();
    await page.getByRole('link', { name: 'Historial y análisis', exact: true }).click();
    await page.getByRole('combobox', { name: 'Conductor', exact: true }).selectOption('demo-driver');
    await page.getByRole('combobox', { name: 'Vehículo', exact: true }).selectOption('BUS-001');
    await page.getByRole('combobox', { name: 'Severidad', exact: true }).selectOption('INFO');
    await expect(page.getByRole('heading', { name: 'Sin datos para estos filtros' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Exportar CSV' })).toBeDisabled();
    await page.getByRole('combobox', { name: 'Severidad', exact: true }).selectOption('CRITICAL');
    await expect(page.getByRole('heading', { name: 'Sin datos para estos filtros' })).toHaveCount(0);
    const downloadPromise = page.waitForEvent('download');
    await page.getByRole('button', { name: 'Exportar CSV' }).click();
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toBe('guardian-incidentes-filtrados.csv');
    const path = await download.path();
    expect(path).not.toBeNull();
    const csv = await readFile(path!, 'utf8');
    expect(csv).toContain('"PROLONGED_EYE_CLOSURE","CRITICAL"');
    expect(csv).toContain('"' + 'e'.repeat(64) + '"');
    expect(csv.split('\r\n')).toHaveLength(2);
    await page.getByRole('button', { name: 'Limpiar filtros', exact: true }).click();
    await expect(page.getByRole('combobox', { name: 'Severidad', exact: true })).toHaveValue('');
    await expect(page.getByRole('combobox', { name: 'Vehículo', exact: true })).toHaveValue('');
  });
  test('operator reads completed self-declared rest from driver SDK without edit controls', async ({ page }) => {
    await login(page, 'operator');
    await page.getByRole('link', { name: 'Viajes', exact: true }).click();
    const history = page.locator('section').filter({ has: page.getByRole('heading', { name: 'Descansos autodeclarados', exact: true }) });
    await expect(history.getByText('EMULATOR_SELF_REPORTED', { exact: true })).toBeVisible();
    await expect(history.getByText(/No demuestra recuperación fisiológica/)).toBeVisible();
    await expect(history.getByRole('button')).toHaveCount(0);
  });
  test('administrator registers vehicle, membership and assigned trip', async ({ page }, info) => {
    test.setTimeout(60_000);
    await login(page, 'admin');
    await page.getByRole('link', { name: 'Ajustes', exact: true }).click();
    await page.getByLabel('UID de la cuenta').fill('demo-driver');
    await page.getByRole('button', { name: 'Guardar membresía' }).click();
    await expect(page.getByRole('status')).toContainText('Membresía actualizada');
    await page.getByRole('link', { name: 'Flota', exact: true }).click();
    const code = `E2E-${info.project.name}`;
    await page.getByLabel('Código interno').fill(code);
    await page.getByRole('button', { name: 'Registrar vehículo', exact: true }).click();
    await expect(page.getByRole('status')).toContainText('Vehículo registrado');
    await expect(page.getByText(code, { exact: true }).first()).toBeVisible();
    await page.getByRole('link', { name: 'Viajes', exact: true }).click();
    await page.getByRole('combobox', { name: 'Vehículo', exact: true }).selectOption('BUS-001');
    await page.getByLabel('UID del conductor').fill('demo-driver');
    await page.getByLabel('Origen', { exact: true }).fill(`Origen ${info.project.name}`);
    await page.getByLabel('Destino', { exact: true }).fill('Destino ficticio');
    await page.getByRole('button', { name: 'Asignar viaje', exact: true }).click();
    await expect(page.getByRole('status')).toContainText('Viaje asignado');
    await expect(page.getByText(`Origen ${info.project.name} → Destino ficticio`, { exact: true }).first()).toBeVisible();
  });
});
