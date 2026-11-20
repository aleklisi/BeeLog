const { test, expect } = require('@playwright/test');

// Helper: boot without saved consent (simulates first visit)
async function bootWithoutConsent(page) {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    localStorage.removeItem('beelog_consent');
    localStorage.setItem('beelog_language', 'pl');
  });
  await page.goto('/');
  await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
  await page.reload();
}

// Helper: boot with consent already decided
async function bootWithConsent(page, analytics = false) {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    localStorage.setItem('beelog_language', 'pl');
  });
  await page.evaluate(() => {
    localStorage.setItem('beelog_consent', JSON.stringify({ necessary: true, analytics: false, decidedAt: new Date().toISOString() }));
  });
  await page.goto('/');
  await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
  await page.reload();
}

test('consent banner appears on first visit without saved consent', async ({ page }) => {
  await bootWithoutConsent(page);
  await expect(page.getByTestId('consent-banner')).toBeVisible();
});

test('consent banner disappears after accepting necessary cookies only', async ({ page }) => {
  await bootWithoutConsent(page);
  await page.getByTestId('consent-necessary').click();
  await expect(page.getByTestId('consent-banner')).not.toBeVisible();
  // consent should be persisted in localStorage
  const consent = await page.evaluate(() => JSON.parse(localStorage.getItem('beelog_consent') || 'null'));
  expect(consent).not.toBeNull();
  expect(consent.necessary).toBe(true);
  expect(consent.analytics).toBe(false);
});

test('consent banner disappears after accepting all cookies', async ({ page }) => {
  await bootWithoutConsent(page);
  await page.getByTestId('consent-all').click();
  await expect(page.getByTestId('consent-banner')).not.toBeVisible();
  const consent = await page.evaluate(() => JSON.parse(localStorage.getItem('beelog_consent') || 'null'));
  expect(consent).not.toBeNull();
  expect(consent.analytics).toBe(true);
});

test('consent banner does not appear when consent already saved', async ({ page }) => {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    localStorage.setItem('beelog_language', 'pl');
    localStorage.setItem('beelog_consent', JSON.stringify({ necessary: true, analytics: false, decidedAt: new Date().toISOString() }));
  });
  await page.goto('/');
  await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
  await page.reload();
  await expect(page.getByTestId('consent-banner')).not.toBeVisible();
});

test('privacy policy opens from consent banner link', async ({ page }) => {
  await bootWithoutConsent(page);
  await page.getByTestId('consent-privacy-policy').click();
  await expect(page.getByTestId('privacy-policy-modal')).toBeVisible();
});

test('privacy policy opens from login screen link', async ({ page }) => {
  await bootWithoutConsent(page);
  // Dismiss banner first so login-privacy-policy is not obstructed
  await page.getByTestId('consent-necessary').click();
  await page.getByTestId('login-privacy-policy').click();
  await expect(page.getByTestId('privacy-policy-modal')).toBeVisible();
});

test('privacy policy can be closed', async ({ page }) => {
  await bootWithoutConsent(page);
  await page.getByTestId('consent-privacy-policy').click();
  await expect(page.getByTestId('privacy-policy-modal')).toBeVisible();
  await page.getByTestId('close-privacy-policy').click();
  await expect(page.getByTestId('privacy-policy-modal')).not.toBeVisible();
});

test('privacy section appears in settings for authenticated user', async ({ page }) => {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    localStorage.setItem('beelog_language', 'pl');
    localStorage.setItem('beelog_consent', JSON.stringify({ necessary: true, analytics: false, decidedAt: new Date().toISOString() }));
  });
  await page.goto('/');
  await page.evaluate(() => {
    localStorage.removeItem('__E2E_STATE__');
  });
  await page.reload();
  await page.evaluate(() => {
    window.app.ports.authStateChanged.send({ uid: 'privacy-test-user', email: 'privacy@beelog.test' });
  });
  await expect(page.getByText('Twoje Pasieczyska')).toBeVisible();
  await page.getByTestId('main-menu-toggle').click();
  await page.getByText('⚙️ Ustawienia').click();
  await page.getByTestId('settings-section-toggle-prywatnosc').click();
  await expect(page.getByTestId('settings-section-prywatnosc')).toBeVisible();
});

test('privacy policy opens from settings section', async ({ page }) => {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    localStorage.setItem('beelog_language', 'pl');
    localStorage.setItem('beelog_consent', JSON.stringify({ necessary: true, analytics: false, decidedAt: new Date().toISOString() }));
  });
  await page.goto('/');
  await page.evaluate(() => {
    localStorage.removeItem('__E2E_STATE__');
  });
  await page.reload();
  await page.evaluate(() => {
    window.app.ports.authStateChanged.send({ uid: 'privacy-test-user2', email: 'privacy2@beelog.test' });
  });
  await expect(page.getByText('Twoje Pasieczyska')).toBeVisible();
  await page.getByTestId('main-menu-toggle').click();
  await page.getByText('⚙️ Ustawienia').click();
  await page.getByTestId('settings-section-toggle-prywatnosc').click();
  await page.getByTestId('open-privacy-policy').click();
  await expect(page.getByTestId('privacy-policy-modal')).toBeVisible();
  await page.getByTestId('close-privacy-policy-btn').click();
  await expect(page.getByTestId('privacy-policy-modal')).not.toBeVisible();
});

test('analytics toggle in settings changes consent preference', async ({ page }) => {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    localStorage.setItem('beelog_language', 'pl');
    localStorage.setItem('beelog_consent', JSON.stringify({ necessary: true, analytics: false, decidedAt: new Date().toISOString() }));
  });
  await page.goto('/');
  await page.evaluate(() => {
    localStorage.removeItem('__E2E_STATE__');
  });
  await page.reload();
  await page.evaluate(() => {
    window.app.ports.authStateChanged.send({ uid: 'analytics-test-user', email: 'analytics@beelog.test' });
  });
  await expect(page.getByText('Twoje Pasieczyska')).toBeVisible();
  await page.getByTestId('main-menu-toggle').click();
  await page.getByText('⚙️ Ustawienia').click();
  await page.getByTestId('settings-section-toggle-prywatnosc').click();
  const toggle = page.getByTestId('analytics-toggle');
  await expect(toggle).not.toBeChecked();
  await toggle.click();
  await expect(toggle).toBeChecked();
  const consent = await page.evaluate(() => JSON.parse(localStorage.getItem('beelog_consent') || 'null'));
  expect(consent.analytics).toBe(true);
});
