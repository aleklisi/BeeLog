const { test, expect } = require('@playwright/test');

test.beforeEach(async ({ page }) => {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    if (!sessionStorage.getItem('__PRESERVE_LANGUAGE__')) localStorage.setItem('beelog_language', 'pl');
  });
  await page.route('https://accounts.google.com/gsi/client', route => route.fulfill({
    status: 200,
    contentType: 'application/javascript',
    body: 'window.google = { accounts: { id: { initialize() {}, renderButton(container, config) { const button = document.createElement("button"); button.type = "button"; button.dataset.testid = "google-signin-button"; button.textContent = config.locale === "en" ? "Sign in with Google" : "Zaloguj przez Google"; container.replaceChildren(button); } } } };'
  }));
  await page.goto('/');
  const consentButton = page.getByRole('button', { name: 'Tylko niezbędne' });
  if (await consentButton.isVisible()) await consentButton.click();
});

test('1. Test logowania - widok początkowy', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await expect(page.getByTestId('google-signin-button')).toBeVisible();
    await expect(page.locator('text=BeeLog 🐝')).toBeVisible();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'login-view-test-user', email: 'login@beelog.test' }));
    await expect(page.locator('#google-signin-button')).toHaveCount(0);
  });

test('main navigation is keyboard accessible and keeps Settings and Logout available', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'menu-test-user', email: 'menu@beelog.test' }));

    const menuButton = page.getByTestId('main-menu-toggle');
    await menuButton.focus();
    await page.keyboard.press('Enter');
    await expect(menuButton).toHaveAttribute('aria-expanded', 'true');
    await expect(page.getByRole('navigation', { name: 'Nawigacja główna' })).toContainText('Pasieczyska towarowe');
    await expect(page.getByRole('navigation', { name: 'Nawigacja główna' })).toContainText('⚙️ Ustawienia');
    await expect(page.getByRole('navigation', { name: 'Nawigacja główna' })).toContainText('Wyloguj się');
    const menuItems = page.getByRole('navigation', { name: 'Nawigacja główna' }).getByRole('button');
    const itemBoxes = await menuItems.evaluateAll(items => items.map(item => item.getBoundingClientRect().y));
    expect(itemBoxes.length).toBeGreaterThanOrEqual(4);
    expect(itemBoxes.every((y, index) => index === 0 || y > itemBoxes[index - 1])).toBe(true);

    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();
    await page.getByTestId('settings-section-toggle-queen-rearing').click();
    await page.getByTestId('queen-rearing-toggle').check();
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Hodowla matek' }).click();
    await expect(page.getByRole('heading', { name: 'Hodowla matek' })).toBeVisible();
  });

test('menu labels follow the selected language', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'menu-language-user', email: 'language@beelog.test' }));

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();
    await page.getByTestId('settings-section-toggle-ogolne').click();
    await page.getByTestId('language-select').selectOption('en');
    await page.getByTestId('main-menu-toggle').click();

    await expect(page.getByRole('navigation', { name: 'Main navigation' })).toContainText('Commercial Apiaries');
    await expect(page.getByRole('navigation', { name: 'Main navigation' })).toContainText('⚙️ Settings');
    await expect(page.getByRole('navigation', { name: 'Main navigation' })).toContainText('Log out');
    await expect(page.getByRole('navigation', { name: 'Main navigation' })).not.toContainText('Pasieczyska towarowe');
  });

test('settings actions keep semantic colors and keyboard focus in both themes', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'settings-colors-user', email: 'colors@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();

    const backButton = page.getByRole('button', { name: '← Powrót' });
    await expect(backButton).toHaveClass(/settings-primary-action/);
    const generalToggle = page.getByTestId('settings-section-toggle-ogolne');
    await expect(generalToggle).toHaveClass(/settings-secondary-action/);
    await backButton.focus();
    await page.keyboard.press('Tab');
    await expect(generalToggle).toBeFocused();
    expect(await generalToggle.evaluate(element => getComputedStyle(element).outlineStyle)).toBe('solid');

    await generalToggle.click();
    const themeButton = page.getByRole('button', { name: '✨ Zmień na tryb ciemny' });
    await expect(themeButton).toHaveClass(/settings-preference-action/);
    await page.getByTestId('settings-section-toggle-pasieczyska').click();
    const addButton = page.getByRole('button', { name: 'Dodaj' }).first();
    await expect(addButton).toHaveClass(/settings-primary-action/);

    for (const darkMode of [false, true]) {
      if (darkMode) {
        await themeButton.click();
        await expect(page.getByRole('button', { name: '☀️ Zmień na tryb jasny' })).toBeVisible();
        await expect(page.locator('html')).toHaveClass(/dark/);
      }
      expect(await addButton.evaluate(element => getComputedStyle(element).color)).toBe('rgb(255, 255, 255)');
      const frameTypeInput = page.getByPlaceholder('Nowy rodzaj ramki (np. Dadant)');
      await frameTypeInput.focus();
      await page.keyboard.press('Tab');
      await expect(addButton).toBeFocused();
      expect(await addButton.evaluate(element => getComputedStyle(element).outlineStyle)).toBe('solid');
      if (darkMode) {
        await expect(page.locator('html')).toHaveClass(/dark/);
      } else {
        await expect(page.locator('html')).not.toHaveClass(/dark/);
      }

      await page.getByTestId('delete-account').click();
      const cancelButton = page.getByRole('button', { name: 'Anuluj' });
      await expect(cancelButton).toHaveClass(/destructive-action/);
      expect(await cancelButton.evaluate(element => getComputedStyle(element).color)).toBe('rgb(255, 255, 255)');
      await cancelButton.click();
    }
  });

test('language selection persists across refresh and sign in', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'language-persistence-user', email: 'language@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();
    await page.getByTestId('settings-section-toggle-ogolne').click();
    await page.getByTestId('language-select').selectOption('en');
    await expect(page.getByRole('heading', { name: '⚙️ Settings' })).toBeVisible();
    await page.evaluate(() => sessionStorage.setItem('__PRESERVE_LANGUAGE__', 'true'));
    await page.reload();
    await expect(page.getByText('Welcome to BeeLog')).toBeVisible();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'language-persistence-user', email: 'language@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await expect(page.getByRole('navigation', { name: 'Main navigation' })).toContainText('Commercial Apiaries');
  });

test('10. Trwałość ustawień (tryb ciemny) po odświeżeniu', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Przejdź do ustawień
    await page.getByTestId('main-menu-toggle').click();
    await page.click('button:has-text("⚙️ Ustawienia")');
    await expect(page.locator('text=⚙️ Ustawienia')).toBeVisible();
    await page.getByTestId('settings-section-toggle-ogolne').click();
    await expect(page.locator('[data-testid="user-email"]')).toHaveText('e2e@beelog.test');

    // Włącz tryb ciemny
    await page.click('button:has-text("✨ Zmień na tryb ciemny")');
    await expect(page.locator('button:has-text("☀️ Zmień na tryb jasny")')).toBeVisible();

    // Odśwież stronę
    await page.reload();
    await page.waitForFunction(() => window.app && window.app.ports && window.app.ports.authStateChanged);
    await page.evaluate(() => {
      window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
    });
    await page.waitForTimeout(300);

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Przejdź ponownie do ustawień i sprawdź czy tryb ciemny nadal jest aktywny
    await page.getByTestId('main-menu-toggle').click();
    await page.click('button:has-text("⚙️ Ustawienia")');
    await expect(page.locator('text=⚙️ Ustawienia')).toBeVisible();
    await page.getByTestId('settings-section-toggle-ogolne').click();
    await expect(page.locator('button:has-text("☀️ Zmień na tryb jasny")')).toBeVisible();
  });

test('Collapsible Settings — domyślnie wszystkie sekcje zwinięte', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });
    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Przejdź do ustawień
    await page.getByTestId('main-menu-toggle').click();
    await page.click('text=⚙️ Ustawienia');

    // Wszystkie 4 sekcje powinny być domyślnie zwinięte
    await expect(page.locator('[data-testid="settings-section-ogolne"]')).not.toBeVisible();
    await expect(page.locator('[data-testid="settings-section-pasieczyska"]')).not.toBeVisible();
    await expect(page.locator('[data-testid="settings-section-trutowiska"]')).not.toBeVisible();
    await expect(page.locator('[data-testid="settings-section-queen-rearing"]')).not.toBeVisible();

    // Przyciski nagłówków mają aria-expanded="false"
    await expect(page.locator('[data-testid="settings-section-toggle-ogolne"]')).toHaveAttribute('aria-expanded', 'false');
    await expect(page.locator('[data-testid="settings-section-toggle-pasieczyska"]')).toHaveAttribute('aria-expanded', 'false');
    await expect(page.locator('[data-testid="settings-section-toggle-trutowiska"]')).toHaveAttribute('aria-expanded', 'false');
    await expect(page.locator('[data-testid="settings-section-toggle-queen-rearing"]')).toHaveAttribute('aria-expanded', 'false');
  });

test('Collapsible Settings — zwijanie i rozwijanie sekcji', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });
    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    await page.getByTestId('main-menu-toggle').click();
    await page.click('text=⚙️ Ustawienia');

    // Rozwiń sekcję Ogólne
    await page.click('[data-testid="settings-section-toggle-ogolne"]');
    await expect(page.locator('[data-testid="settings-section-ogolne"]')).toBeVisible();
    await expect(page.locator('[data-testid="settings-section-toggle-ogolne"]')).toHaveAttribute('aria-expanded', 'true');
    // Ikona ∧ powinna być widoczna w rozwiniętym nagłówku
    await expect(page.locator('[data-testid="settings-section-toggle-ogolne"]')).toContainText('∧');

    // Rozwiń sekcję Trutowiska bez wpływu na pozostałe sekcje
    await page.click('[data-testid="settings-section-toggle-trutowiska"]');
    await expect(page.locator('[data-testid="settings-section-trutowiska"]')).toBeVisible();
    await expect(page.locator('[data-testid="settings-section-pasieczyska"]')).not.toBeVisible();
    await expect(page.locator('[data-testid="settings-section-ogolne"]')).toBeVisible();
    // Zwiń sekcję Trutowiska
    await page.click('[data-testid="settings-section-toggle-trutowiska"]');
    await expect(page.locator('[data-testid="settings-section-trutowiska"]')).not.toBeVisible();
    await expect(page.locator('[data-testid="settings-section-pasieczyska"]')).not.toBeVisible();
    await expect(page.locator('[data-testid="settings-section-ogolne"]')).toBeVisible();
  });
