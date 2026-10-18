import { expect, test } from '@playwright/test';

test('public landing navigates to isolated demo, no Firebase requests', async ({ page }) => {
  const errors: string[] = [];
  const firebaseRequests: string[] = [];
  page.on('pageerror', error => errors.push(error.message));
  page.on('request', request => { if (/firestore.googleapis|identitytoolkit.googleapis/.test(request.url())) firebaseRequests.push(request.url()); });
  await page.goto('/');
  await expect(page.getByRole('heading', { name: /Cada señal/ })).toBeVisible();
  await page.getByRole('link', { name: 'Explorar la demo' }).click();
  await expect(page.getByText('DEMO — DATOS SIMULADOS', { exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Iniciar viaje simulado', exact: true }).click();
  await page.getByRole('button', { name: 'Simular conducción normal' }).click();
  await expect(page.getByRole('status')).toContainText('sin nuevo incidente');
  expect(firebaseRequests).toEqual([]); expect(errors).toEqual([]);
});

test('offline → persisted incident → reconnect → human action → complete → reset', async ({ page }) => {
  await page.goto('/demo/');
  await page.getByRole('button', { name: 'Iniciar viaje simulado', exact: true }).click();
  await page.getByRole('button', { name: 'Simular pérdida de conectividad' }).click();
  await page.getByRole('button', { name: 'Simular cierre ocular prolongado' }).click();
  await expect(page.getByRole('heading', { name: 'Cierre ocular prolongado', exact: true })).toBeVisible();
  await expect(page.getByText('Evento guardado en el dispositivo.', { exact: false })).toBeVisible();
  await page.reload();
  await expect(page.getByRole('heading', { name: 'Cierre ocular prolongado', exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Restaurar conectividad' }).click();
  await expect(page.getByText(/Recibido con retraso/)).toBeVisible();
  await page.getByRole('button', { name: 'Reconocer incidente', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Recepción reconocida' })).toBeDisabled();
  await page.getByLabel('Acción o seguimiento').fill('Se coordinó una parada segura con el conductor demo.');
  await page.getByRole('button', { name: 'Registrar acción', exact: true }).click();
  await expect(page.getByText('Se coordinó una parada segura con el conductor demo.', { exact: true })).toBeVisible();
  await page.getByLabel('Acción o seguimiento').fill('Seguimiento completado en el escenario ficticio.');
  await page.getByRole('button', { name: 'Resolver incidente' }).click();
  await expect(page.getByRole('button', { name: 'Resolver incidente' })).toBeDisabled();
  await page.getByRole('button', { name: 'Finalizar escenario' }).click();
  await expect(page.getByText('Finalizado · monitoreo pausado', { exact: true })).toBeVisible();
  const summary = page.getByRole('region', { name: 'Resumen del viaje simulado' });
  await expect(summary.getByRole('heading', { name: 'Resumen del escenario' })).toBeVisible();
  await expect(summary).toContainText('Eventos recibidos en central demo');
  await page.getByRole('button', { name: 'Reiniciar demostración' }).click();
  await expect(page.getByRole('heading', { name: 'Sin incidentes registrados' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Iniciar viaje simulado', exact: true })).toBeEnabled();
});

test('caution cooldown groups duplicate events', async ({ page }) => {
  await page.goto('/demo/');
  await page.getByRole('button', { name: 'Iniciar viaje simulado', exact: true }).click();
  await page.getByRole('button', { name: 'Simular precaución' }).click();
  await page.getByRole('button', { name: 'Simular precaución' }).click();
  await expect(page.getByRole('status')).toContainText('cooldown');
  await expect(page.locator('.incident-list li')).toHaveCount(1);
});

test('synthetic destination and voluntary rest never imply real navigation or recovery', async ({ page }) => {
  await page.goto('/demo/');
  await page.getByLabel('¿A dónde quieres ir? · destinos simulados').selectOption('ica');
  await expect(page.getByRole('heading', { name: 'Arequipa → Ica' })).toBeVisible();
  await page.getByRole('button', { name: 'Iniciar viaje simulado', exact: true }).click();
  await page.getByRole('button', { name: 'Simular cierre ocular prolongado' }).click();
  await expect(page.getByText(/Señal crítica simulada: detente/)).toBeVisible();
  await page.getByRole('button', { name: /Área Demo de Descanso/ }).click();
  await expect(page.getByRole('button', { name: 'Iniciar descanso simulado', exact: true })).toBeDisabled();
  await page.getByRole('checkbox', { name: /Confirmo voluntariamente/ }).check();
  await page.getByRole('button', { name: 'Iniciar descanso simulado', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Simular conducción normal' })).toBeDisabled();
  await page.reload();
  await expect(page.getByText('MONITOREO PAUSADO · DESCANSO SIMULADO', { exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Terminar descanso simulado' }).click();
  await expect(page.getByText(/s lógicos/, { exact: false })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Simular conducción normal' })).toBeEnabled();
});

test('pitch has ten slides, keyboard controls and working demo link', async ({ page }) => {
  await page.goto('/pitch/');
  await expect(page.getByRole('heading', { name: /La señal importa/ })).toBeVisible();
  await page.keyboard.press('ArrowRight');
  await expect(page.getByRole('heading', { name: /Un mismo viaje/ })).toBeVisible();
  await page.keyboard.press('End');
  await expect(page.getByRole('heading', { name: /Cerrar el circuito/ })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Siguiente →' })).toBeDisabled();
  await page.getByRole('button', { name: 'Diapositiva 5:', exact: false }).click();
  await page.getByRole('link', { name: 'Abrir escenario de demostración' }).click();
  await expect(page).toHaveURL(/\/demo\/?$/);
});

test('protected routes require configuration or an authenticated session', async ({ page }) => {
  for (const path of ['/dashboard/', '/dashboard/trips/', '/dashboard/incidents/', '/dashboard/fleet/', '/dashboard/drivers/', '/dashboard/rest/', '/dashboard/reports/', '/dashboard/settings/']) {
    await page.goto(path);
    await expect(page.getByRole('heading', { name: /Central pendiente de configurar|Bienvenido a la central/ })).toBeVisible();
    await expect(page.getByText('DEMO — DATOS SIMULADOS', { exact: true })).toHaveCount(0);
  }
});

test('main public pages fit the viewport and support keyboard focus', async ({ page }) => {
  for (const path of ['/', '/demo/', '/pitch/']) {
    await page.goto(path);
    await expect(page.locator('#main')).toBeVisible();
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);
  }
  await page.goto('/demo/');
  await page.keyboard.press('Tab');
  await expect(page.getByRole('link', { name: 'Saltar al contenido' })).toBeFocused();
});
