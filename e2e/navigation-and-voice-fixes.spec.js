const { test, expect } = require('@playwright/test');

test('commercial hive notes accept recognized speech text', async ({ page }) => {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    localStorage.setItem('beelog_language', 'pl');
  });
  await page.goto('/');
  await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
  await page.reload();
  await page.evaluate(() => {
    window.app.ports.authStateChanged.send({ uid: 'voice-test-user', email: 'voice@beelog.test' });
    window.SpeechRecognition = class {
      start() {
        this.onresult({ results: [[{ transcript: 'notatka podyktowana' }]] });
      }
    };
  });

  await expect(page.getByText('Twoje Pasieczyska')).toBeVisible();
  await page.getByText('+ Dodaj Pasieczysko').click();
  await page.locator('input[placeholder="Nazwa pasieczyska"]').fill('Pasieka głosowa');
  await page.locator('div[style*="position: fixed"] select').selectOption('towarowe');
  await page.getByRole('button', { name: 'Zapisz' }).click();
  await page.getByText('Pasieka głosowa').click();
  await page.getByText('+ Dodaj Nowy Ul').click();
  await page.locator('input[placeholder="np. Ul #04"]').fill('Ul głosowy');
  await page.getByRole('button', { name: 'Zapisz' }).click();
  await page.getByText('Ul głosowy').click();

  await page.getByRole('button', { name: '🎤 Dyktuj' }).click();
  await expect(page.locator('textarea').first()).toHaveValue(/notatka podyktowana/);
});
