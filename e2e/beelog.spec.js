const { test, expect } = require('@playwright/test');

test.describe('BeeLog E2E Test Suite', () => {

  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      window.__E2E__ = true;
      if (!sessionStorage.getItem('__PRESERVE_LANGUAGE__')) localStorage.setItem('beelog_language', 'pl');
    });
    await page.goto('/');
    const consentButton = page.getByRole('button', { name: 'Tylko niezbędne' });
    if (await consentButton.isVisible()) {
      await consentButton.click();
    }
  });

  test('1. Test logowania - widok początkowy', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await expect(page.locator('text=Zaloguj przez Google')).toBeVisible();
    await expect(page.locator('text=BeeLog 🐝')).toBeVisible();
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

  test('menu opens separate mating and commercial apiary lists', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'split-view-user', email: 'split@beelog.test' }));
    await expect(page.getByText('Twoje Pasieczyska')).toBeVisible();

    await page.getByText('+ Dodaj Pasieczysko').click();
    await page.locator('input[placeholder="Nazwa pasieczyska"]').fill('Commercial sample');
    await page.locator('div[style*="position: fixed"] select').selectOption('towarowe');
    await page.getByRole('button', { name: 'Zapisz' }).click();
    await expect(page.getByText('Commercial sample')).toBeVisible();

    await page.getByText('+ Dodaj Pasieczysko').click();
    await page.locator('input[placeholder="Nazwa pasieczyska"]').fill('Mating sample');
    await page.locator('div[style*="position: fixed"] select').selectOption('trutowisko');
    await page.getByRole('button', { name: 'Zapisz' }).click();

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    await expect(page.getByRole('heading', { name: 'Trutowiska' })).toBeVisible();
    await expect(page.getByText('Mating sample')).toBeVisible();
    await expect(page.getByText('Commercial sample')).not.toBeVisible();

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Pasieczyska towarowe' }).click();
    await expect(page.getByRole('heading', { name: 'Pasieczyska towarowe' })).toBeVisible();
    await expect(page.getByText('Commercial sample')).toBeVisible();
    await expect(page.getByText('Mating sample')).not.toBeVisible();
  });

  test('menu opens separate apiary lists in English', async ({ page }) => {
    await page.evaluate(() => {
      localStorage.removeItem('__E2E_STATE__');
      localStorage.setItem('beelog_language', 'en');
      sessionStorage.setItem('__PRESERVE_LANGUAGE__', 'true');
    });
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'split-view-user-en', email: 'split-en@beelog.test' }));
    await expect(page.getByText('Your Apiaries')).toBeVisible();

    await page.getByText('+ Add Apiary').click();
    await page.locator('input[placeholder="Apiary name"]').fill('Commercial sample');
    await page.locator('div[style*="position: fixed"] select').selectOption('towarowe');
    await page.getByRole('button', { name: 'Save' }).click();
    await expect(page.getByText('Commercial sample')).toBeVisible();

    await page.getByText('+ Add Apiary').click();
    await page.locator('input[placeholder="Apiary name"]').fill('Mating sample');
    await page.locator('div[style*="position: fixed"] select').selectOption('trutowisko');
    await page.getByRole('button', { name: 'Save' }).click();

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Mating Apiaries' }).click();
    await expect(page.getByRole('heading', { name: 'Mating Apiaries' })).toBeVisible();
    await expect(page.getByText('Mating sample')).toBeVisible();
    await expect(page.getByText('Commercial sample')).not.toBeVisible();

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Commercial Apiaries' }).click();
    await expect(page.getByRole('heading', { name: 'Commercial Apiaries' })).toBeVisible();
    await expect(page.getByText('Commercial sample')).toBeVisible();
    await expect(page.getByText('Mating sample')).not.toBeVisible();
  });

  test('type-scoped creation assigns the view type and preserves detail navigation', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'scoped-create-user', email: 'create@beelog.test' }));

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    await expect(page.getByTestId('apiary-empty-state')).toContainText('Brak trutowisk');
    await page.getByText('+ Dodaj Pasieczysko').click();
    await expect(page.locator('div[style*="position: fixed"] select')).toHaveCount(0);
    await page.locator('input[placeholder="Nazwa pasieczyska"]').fill('Scoped mating apiary');
    await page.getByRole('button', { name: 'Zapisz' }).click();
    await page.getByText('Scoped mating apiary').click();
    await expect(page.getByText('Trutowisko: Scoped mating apiary')).toBeVisible();
    await page.getByText('← Powrót').click();
    await expect(page.getByText('Scoped mating apiary')).toBeVisible();

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Pasieczyska towarowe' }).click();
    await expect(page.getByTestId('apiary-empty-state')).toContainText('Brak pasieczysk towarowych');
    await page.getByText('+ Dodaj Pasieczysko').click();
    await expect(page.locator('div[style*="position: fixed"] select')).toHaveCount(0);
    await page.locator('input[placeholder="Nazwa pasieczyska"]').fill('Scoped commercial apiary');
    await page.getByRole('button', { name: 'Zapisz' }).click();
    await page.getByText('Scoped commercial apiary').click();
    await expect(page.getByText('Pasieka: Scoped commercial apiary')).toBeVisible();
  });

  test('disabling one apiary module hides its list and preserves both sets of data', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'preserve-view-user', email: 'preserve@beelog.test' }));

    for (const [name, type] of [['Preserved commercial', 'towarowe'], ['Preserved mating', 'trutowisko']]) {
      await page.getByText('+ Dodaj Pasieczysko').click();
      await page.locator('input[placeholder="Nazwa pasieczyska"]').fill(name);
      await page.locator('div[style*="position: fixed"] select').selectOption(type);
      await page.getByRole('button', { name: 'Zapisz' }).click();
      await expect(page.getByText(name)).toBeVisible();
    }

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();
    await page.getByTestId('settings-section-toggle-trutowiska').click();
    await page.getByTestId('mating-apiaries-toggle').click({ noWaitAfter: true });
    await expect(page.getByRole('heading', { name: 'Pasieczyska towarowe' })).toBeVisible();
    await page.getByTestId('main-menu-toggle').click();
    await expect(page.getByRole('navigation', { name: 'Nawigacja główna' })).not.toContainText('Trutowiska');
    await expect(page.getByRole('navigation', { name: 'Nawigacja główna' })).toContainText('Pasieczyska towarowe');

    const savedApiaries = await page.evaluate(() => JSON.parse(localStorage.getItem('__E2E_STATE__')).apiaries);
    expect(savedApiaries.map(apiary => apiary.name).sort()).toEqual(['Preserved commercial', 'Preserved mating']);

    const settingsBtn = page.getByRole('button', { name: '⚙️ Ustawienia' });
    if (!(await settingsBtn.isVisible())) {
      await page.getByTestId('main-menu-toggle').click();
    }
    await settingsBtn.click();
    const matingSettingsSection = page.getByTestId('settings-section-toggle-trutowiska');
    if ((await matingSettingsSection.getAttribute('aria-expanded')) !== 'true') {
      await matingSettingsSection.click();
    }
    const matingToggle = page.getByTestId('mating-apiaries-toggle');
    await expect(matingToggle).toBeVisible();
    await matingToggle.evaluate(element => element.click());
    await expect(matingToggle).toBeChecked();
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('navigation', { name: 'Nawigacja główna' }).getByRole('button', { name: 'Trutowiska', exact: true }).click();
    await expect(page.getByText('Preserved mating')).toBeVisible();
  });

  test('queen rearing completes a batch directly and completes a zero-acceptance batch', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'queen-cycle-user', email: 'queen@beelog.test' }));
    const year = new Date().getUTCFullYear();

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();
    await page.getByTestId('settings-section-toggle-queen-rearing').click();
    await page.getByTestId('queen-rearing-toggle').check();
    await page.getByTestId('main-menu-toggle').click();
    await expect(page.getByRole('navigation', { name: 'Nawigacja główna' })).toContainText('Hodowla matek');
    await page.getByRole('navigation', { name: 'Nawigacja główna' }).getByRole('button', { name: 'Hodowla matek' }).click();
    await expect(page.getByTestId('queen-rearing-view')).toBeVisible();

    await page.getByRole('button', { name: 'Zasoby' }).click();
    await page.getByTestId('qr-resource-toggle-breederQueens').click();
    await page.getByTestId('qr-input-breedLine').selectOption('car. Galicja');
    await page.getByTestId('qr-input-markingColor').selectOption('blue');
    await page.getByTestId('qr-input-markingCode').fill('17');
    await page.getByTestId('qr-input-hiveNumber').fill('BQ-1');
    await page.getByTestId('qr-resource-save-breederQueens').click();
    await expect(page.getByText('BQ-1 · car. Galicja · blue 17')).toBeVisible();

    await page.getByTestId('qr-resource-toggle-starterColonies').click();
    const starterSection = page.getByTestId('qr-resource-section-starterColonies');
    await starterSection.getByTestId('qr-input-hiveNumber').fill('S-1');
    await starterSection.getByTestId('qr-resource-save-starterColonies').click();
    await expect(page.getByText('S-1', { exact: true })).toBeVisible();

    await page.getByTestId('qr-resource-toggle-finisherColonies').click();
    const finisherSection = page.getByTestId('qr-resource-section-finisherColonies');
    await finisherSection.getByTestId('qr-input-hiveNumber').fill('F-1');
    await finisherSection.getByTestId('qr-resource-save-finisherColonies').click();
    await expect(page.getByText('F-1', { exact: true })).toBeVisible();

    await page.getByRole('button', { name: '← Hodowla matek' }).click();

    await page.getByTestId('qr-breeder-select').selectOption({ label: 'BQ-1 · car. Galicja' });
    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const batch = page.locator('[data-testid^="qr-batch-"]').first();
    await expect(batch).toContainText(`${year}/01 · Zaplanowana`);
    await batch.locator('select[data-testid^="qr-starter-"]').selectOption({ label: 'S-1' });
    await batch.getByTestId('qr-input-graftedAt').fill('2026-05-10T10:00');
    await batch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await expect(batch).toContainText('W starterze');
    await expect(batch).toContainText('Przeniesienie do startera: 2026-05-12T10:00');

    await page.getByTestId('qr-input-count').fill('10.5');
    await page.getByTestId('qr-finisher-select').selectOption({ label: 'F-1' });
    await batch.getByRole('button', { name: 'Przenieś do finishera' }).click();
    await expect(batch).toContainText('W starterze');
    await expect(page.getByText('Enter a whole-number count for this transition.')).toBeVisible();
    await page.getByText('✕').click();
    await page.getByTestId('qr-input-count').fill('25');
    await batch.getByRole('button', { name: 'Przenieś do finishera' }).click();
    await expect(batch).toContainText('W starterze');
    await expect(page.getByText('Accepted cell count must be between 1 and the graft count.')).toBeVisible();
    await page.getByText('✕').click();

    await page.getByTestId('qr-input-count').fill('20');
    await batch.getByRole('button', { name: 'Przenieś do finishera' }).click();
    await expect(batch).toContainText('W finisherze');
    await page.getByTestId('qr-input-count').fill('5');
    await batch.getByRole('button', { name: 'Zakończ bezpośrednio' }).click();
    await expect(batch).toContainText('Zakończona');
    await expect(batch).toContainText('Wygryzione: 5');
    await page.getByRole('button', { name: 'Zasoby' }).click();
    await expect(page.getByText('S-1', { exact: true })).toBeVisible();
    await expect(page.getByText('F-1', { exact: true })).toBeVisible();
    await page.getByRole('button', { name: '← Hodowla matek' }).click();

    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const zeroBatch = page.locator('[data-testid^="qr-batch-"]').filter({ hasText: `${year}/02` });
    await expect(zeroBatch).toContainText('Zaplanowana');
    await zeroBatch.locator('select[data-testid^="qr-starter-"]').selectOption({ label: 'S-1' });
    await page.getByTestId('qr-input-graftedAt').fill('2026-05-11T10:00');
    await zeroBatch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await expect(zeroBatch).toContainText('W starterze');
    await page.getByTestId('qr-input-count').fill('0');
    await zeroBatch.getByRole('button', { name: 'Zakończ bez przyjętych mateczników' }).click();
    await expect(zeroBatch).toContainText('Zakończona');

    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const incubatorBatch = page.locator('[data-testid^="qr-batch-"]').filter({ hasText: `${year}/03` });
    await incubatorBatch.locator('select[data-testid^="qr-starter-"]').selectOption({ label: 'S-1' });
    await page.getByTestId('qr-input-graftedAt').fill('2026-05-12T10:00');
    await incubatorBatch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await page.getByTestId('qr-input-count').fill('10');
    await page.getByTestId('qr-finisher-select').selectOption({ label: 'F-1' });
    await incubatorBatch.getByRole('button', { name: 'Przenieś do finishera' }).click();
    await page.getByTestId('qr-input-incubatorBar').fill('B-4');
    await incubatorBatch.getByRole('button', { name: 'Przenieś do inkubatora' }).click();
    await expect(incubatorBatch).toContainText('W inkubatorze');
    await expect(incubatorBatch).toContainText('Listwa inkubatorowa: B-4');
    await page.getByTestId('qr-input-count').fill('7');
    await incubatorBatch.getByRole('button', { name: 'Zakończ serię' }).click();
    await expect(incubatorBatch).toContainText('Zakończona');
    await expect(incubatorBatch).toContainText('Wygryzione: 7');
    await expect(incubatorBatch).toContainText('Listwa inkubatorowa: B-4');
  });

  test('queen-rearing batches show urgency and sort overdue, upcoming, planned, completed', async ({ page }) => {
    await page.evaluate(() => {
      const zone = 'Europe/Warsaw';
      const local = (epoch) => {
        const parts = new Intl.DateTimeFormat('en-CA', { timeZone: zone, year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).formatToParts(new Date(epoch));
        const value = Object.fromEntries(parts.map(part => [part.type, part.value]));
        return `${value.year}-${value.month}-${value.day}T${value.hour}:${value.minute}`;
      };
      const now = Date.now();
      const batch = (id, number, status, deadline) => ({
        id, number, status, breederQueenId: 'queen', graftCount: 24, acceptedCount: 12,
        emergedCount: null, timeZone: zone, graftedAt: local(now), starterDurationDays: 2, isolationDay: 10, emergenceDay: 11,
        starterTransferAt: status === 'W_STARTERZE' ? local(deadline) : null,
        isolationAt: status === 'W_FINISHERZE' ? local(deadline) : null,
        emergenceAt: status === 'W_CIEPLARCE' ? local(deadline) : null
      });
      localStorage.setItem('__E2E_STATE__', JSON.stringify({
        apiaries: [], hives: {}, notes: {}, userSettings: {
          frameTypes: ['Dadant'], ulikTypes: ['Apidea'], breedLines: ['Galicja'], darkMode: false,
          hatchingToMatingDays: 12, maxUlikHistoryLimit: 40, enableTrutowiska: true, enablePasieczyskaTowarowe: true,
          enableQueenRearing: true, defaultGraftCount: 24, starterDurationDays: 2, isolationDay: 10, emergenceDay: 11
        },
        queenRearing: {
          breederQueens: [{ id: 'queen', breed: 'Carniolan', line: 'Galicja', hiveNumber: 'BQ-1', active: true }],
          starterColonies: [], finisherColonies: [], sequences: {},
          rearingBatches: [
            batch('overdue', '2026/01', 'W_STARTERZE', now - 60 * 60 * 1000),
            batch('soon', '2026/02', 'W_FINISHERZE', now + 2 * 60 * 60 * 1000),
            batch('future', '2026/03', 'W_CIEPLARCE', now + 3 * 24 * 60 * 60 * 1000),
            batch('planned', '2026/04', 'ZAPLANOWANA', null),
            batch('completed', '2026/05', 'ZAKONCZONA', null)
          ]
        }
      }));
    });
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'queen-alert-user', email: 'alerts@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('navigation', { name: 'Nawigacja główna' }).getByRole('button', { name: 'Hodowla matek' }).click();

    const rows = page.locator('[data-testid^="qr-batch-"]');
    await expect(rows).toHaveCount(5);
    await expect(rows.nth(0)).toHaveAttribute('data-testid', 'qr-batch-overdue');
    await expect(rows.nth(1)).toHaveAttribute('data-testid', 'qr-batch-soon');
    await expect(rows.nth(2)).toHaveAttribute('data-testid', 'qr-batch-future');
    await expect(rows.nth(3)).toHaveAttribute('data-testid', 'qr-batch-planned');
    await expect(rows.nth(4)).toHaveAttribute('data-testid', 'qr-batch-completed');
    await expect(page.getByTestId('qr-next-action-overdue')).toContainText('Opóźnienie:');
    await expect(page.getByTestId('qr-next-action-overdue')).toContainText('2 h');
    await expect(page.getByTestId('qr-next-action-soon')).toContainText('Termin za 2 h');
    await expect(page.getByTestId('qr-next-action-future')).toContainText('Termin za 3 d');
    await expect(page.getByTestId('qr-next-action-overdue')).toHaveCSS('background-color', 'rgb(231, 76, 60)');
    await expect(page.getByTestId('qr-next-action-soon')).toHaveCSS('background-color', 'rgb(241, 196, 15)');
    await expect(page.getByTestId('qr-next-action-future')).toHaveCSS('background-color', 'rgb(39, 174, 96)');
  });

  test('queen-rearing resources edit safely, protect active assignments, and delete after release', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'queen-resource-user', email: 'resources@beelog.test' }));
    const year = new Date().getUTCFullYear();
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();
    await page.getByTestId('settings-section-toggle-queen-rearing').click();
    await page.getByTestId('queen-rearing-toggle').check();
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('navigation', { name: 'Nawigacja główna' }).getByRole('button', { name: 'Hodowla matek' }).click();

    await page.getByRole('button', { name: 'Zasoby' }).click();
    await page.getByTestId('qr-resource-toggle-breederQueens').click();
    await page.getByTestId('qr-input-breedLine').selectOption('car. Galicja');
    await page.getByTestId('qr-input-hiveNumber').fill('BQ-7');
    await page.getByTestId('qr-resource-save-breederQueens').click();
    let queenRow = page.locator('[data-testid^="qr-resource-qr-"]').filter({ hasText: 'BQ-7' });
    const queenId = await queenRow.getAttribute('data-testid').then(id => id.replace('qr-resource-', ''));
    await queenRow.getByRole('button', { name: 'Edytuj' }).click();
    await page.getByTestId('qr-input-breedLine').selectOption('cau. M');
    await page.getByTestId('qr-resource-save-breederQueens').click();
    await expect(queenRow).toContainText('cau. M');

    await page.reload();
    await page.waitForFunction(() => window.app && window.app.ports && window.app.ports.authStateChanged);
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'queen-resource-user', email: 'resources@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('navigation', { name: 'Nawigacja główna' }).getByRole('button', { name: 'Hodowla matek' }).click();
    await page.getByRole('button', { name: 'Zasoby' }).click();
    await page.getByTestId('qr-resource-toggle-breederQueens').click();
    queenRow = page.locator(`[data-testid="qr-resource-${queenId}"]`);
    await expect(queenRow).toContainText('cau. M');

    await page.getByTestId('qr-resource-toggle-starterColonies').click();
    const starterSection = page.getByTestId('qr-resource-section-starterColonies');
    await starterSection.getByTestId('qr-input-hiveNumber').fill('S-7');
    await starterSection.getByTestId('qr-resource-save-starterColonies').click();
    const starterRow = page.locator('[data-testid^="qr-resource-qr-"]').filter({ hasText: 'S-7' });
    const starterId = await starterRow.getAttribute('data-testid').then(id => id.replace('qr-resource-', ''));

    await page.getByRole('button', { name: '← Hodowla matek' }).click();
    await page.getByTestId('qr-breeder-select').selectOption(queenId);
    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const batch = page.locator('[data-testid^="qr-batch-"]').filter({ hasText: `${year}/01` });
    await batch.locator('select[data-testid^="qr-starter-"]').selectOption(starterId);
    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const conflictingBatch = page.locator('[data-testid^="qr-batch-"]').filter({ hasText: `${year}/02` });
    await conflictingBatch.locator('select[data-testid^="qr-starter-"]').selectOption(starterId);
    await batch.getByTestId('qr-input-graftedAt').fill('2026-05-10T10:00');
    await batch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await expect(batch).toContainText('W starterze');
    await conflictingBatch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await expect(conflictingBatch).toContainText('Zaplanowana');
    await expect(page.getByText('Batch or starter is unavailable.')).toBeVisible();

    await page.getByRole('button', { name: 'Zasoby' }).click();
    queenRow = page.locator(`[data-testid="qr-resource-${queenId}"]`);
    await queenRow.getByRole('button', { name: 'Usuń' }).click();
    await expect(page.getByText('A breeder queen referenced by a batch cannot be deleted. Retire it instead.')).toBeVisible();
    await expect(queenRow).toBeVisible();
    await starterRow.getByRole('button', { name: 'Usuń' }).click();
    await expect(page.getByText('This colony is reserved by an active batch.')).toBeVisible();
    await expect(starterRow).toBeVisible();

    await page.getByRole('button', { name: '← Hodowla matek' }).click();
    await batch.getByRole('button', { name: 'Usuń serię' }).click();
    await expect(batch).toHaveCount(0);
    await conflictingBatch.getByRole('button', { name: 'Usuń serię' }).click();
    await expect(conflictingBatch).toHaveCount(0);
    await page.getByRole('button', { name: 'Zasoby' }).click();
    const releasedStarter = page.locator(`[data-testid="qr-resource-${starterId}"]`);
    const releasedQueen = page.locator(`[data-testid="qr-resource-${queenId}"]`);
    await expect(releasedStarter).toBeVisible();
    await releasedStarter.getByRole('button', { name: 'Usuń' }).click();
    await expect(releasedStarter).toHaveCount(0);
    await releasedQueen.getByRole('button', { name: 'Wycofaj' }).click();
    await expect(releasedQueen).toContainText('Nieaktywna');
    await page.getByRole('button', { name: '← Hodowla matek' }).click();
    await expect(page.getByTestId('qr-breeder-select').locator(`option[value="${queenId}"]`)).toHaveCount(0);
    await page.getByRole('button', { name: 'Zasoby' }).click();
    await releasedQueen.getByRole('button', { name: 'Usuń' }).click();
    await expect(releasedQueen).toHaveCount(0);
  });

  test('feature toggles persist independently and disabling the current view falls back', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'settings-test-user', email: 'settings@beelog.test' }));

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    await expect(page.getByRole('heading', { name: 'Trutowiska' })).toBeVisible();
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();

    await page.getByTestId('settings-section-toggle-queen-rearing').click();
    await page.getByTestId('queen-rearing-toggle').check();
    await page.getByTestId('settings-section-toggle-trutowiska').click();
    await page.getByTestId('mating-apiaries-toggle').click();
    await expect(page.getByRole('heading', { name: 'Pasieczyska towarowe' })).toBeVisible();

    await page.reload();
    await page.waitForFunction(() => window.app && window.app.ports && window.app.ports.authStateChanged);
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'settings-test-user', email: 'settings@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: '⚙️ Ustawienia' }).click();
    await page.getByTestId('settings-section-toggle-queen-rearing').click();
    await expect(page.getByTestId('queen-rearing-toggle')).toBeChecked();
    await page.getByTestId('settings-section-toggle-trutowiska').click();
    await expect(page.getByTestId('mating-apiaries-toggle')).not.toBeChecked();
    await page.getByTestId('settings-section-toggle-pasieczyska').click();
    await expect(page.getByTestId('commercial-apiaries-toggle')).toBeChecked();

    await page.getByTestId('main-menu-toggle').click();
    await expect(page.getByRole('navigation', { name: 'Nawigacja główna' })).not.toContainText('Trutowiska');
    await expect(page.getByRole('navigation', { name: 'Nawigacja główna' })).toContainText('Hodowla matek');
    await page.getByRole('button', { name: 'Wyloguj się' }).click();
    await expect(page.getByText('Zaloguj przez Google')).toBeVisible();
  });

  test('2, 3, 4. Dodanie, Edycja i Usunięcie Pasieczyska', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    // Symulacja zalogowania przez port Elm
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // 2. Dodanie pasieczyska
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Pasieka E2E Testowa');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Pasieka E2E Testowa')).toBeVisible();

    // 3. Edycja pasieczyska
    await page.click('button:has-text("✏️")');
    await page.fill('div:has-text("Edytuj Nazwę Pasieczyska") input[type="text"]', 'Pasieka E2E Edytowana');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Pasieka E2E Edytowana')).toBeVisible();

    // 4. Usunięcie pasieczyska
    await page.click('button:has-text("🗑️")');
    await page.click('button:has-text("Potwierdź usunięcie")');
    await expect(page.locator('h3:has-text("Pasieka E2E Edytowana")')).not.toBeVisible();
  });

  test('5. Dodanie 3 pasieczysk, zmiana kolejności i trwałość po odświeżeniu', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Pasieka X, Y, Z
    for (const name of ['Pasieka X', 'Pasieka Y', 'Pasieka Z']) {
      await page.click('text=+ Dodaj Pasieczysko');
      await page.fill('input[placeholder="Nazwa pasieczyska"]', name);
      await page.click('button:has-text("Zapisz")');
      await expect(page.locator(`text=${name}`)).toBeVisible();
    }

    // Przeciągnij Pasiekę X za Pasiekę Z.
    const apiaryOrder = () => page.locator('[data-testid="apiary-card"]').evaluateAll(nodes => nodes.map(node => node.getAttribute('data-apiary-id')));
    const apiaryXId = await page.locator('[data-testid="apiary-card"]', { hasText: 'Pasieka X' }).getAttribute('data-apiary-id');
    const apiaryYId = await page.locator('[data-testid="apiary-card"]', { hasText: 'Pasieka Y' }).getAttribute('data-apiary-id');
    const apiaryZ = page.locator('[data-testid="apiary-card"]', { hasText: 'Pasieka Z' });
    const apiaryTarget = apiaryZ;
    const sourceBox = await page.locator(`[data-testid="apiary-card"][data-apiary-id="${apiaryXId}"]`).boundingBox();
    const targetBox = await apiaryTarget.boundingBox();
    await page.mouse.move(sourceBox.x + sourceBox.width / 2, sourceBox.y + sourceBox.height / 2);
    await page.mouse.down();
    await page.mouse.move(targetBox.x + targetBox.width / 2, targetBox.y + targetBox.height * 0.8, { steps: 10 });
    await page.mouse.up();
    await expect.poll(apiaryOrder).toEqual([
      apiaryYId,
      await apiaryZ.getAttribute('data-apiary-id'),
      apiaryXId
    ]);

    // Odśwież stronę
    await page.reload();
    await page.waitForFunction(() => window.app && window.app.ports && window.app.ports.authStateChanged);
    await page.evaluate(() => {
      window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
    });
    await page.waitForTimeout(300);

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });
    await expect(page.locator('text=Pasieka X')).toBeVisible();
    await expect(page.locator('text=Pasieka Y')).toBeVisible();
    await expect(page.locator('text=Pasieka Z')).toBeVisible();
    await expect.poll(apiaryOrder).toEqual([
      apiaryYId,
      await page.locator('[data-testid="apiary-card"]', { hasText: 'Pasieka Z' }).getAttribute('data-apiary-id'),
      apiaryXId
    ]);
  });

  test('6. W pasieczysku: Dodanie, edycja, usunięcie ula oraz test kolejności 3 uli', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj pasieczysko do testu uli
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Pasieka Ulowa');
    await page.click('button:has-text("Zapisz")');

    // Wejdź do pasieki
    await page.click('text=Pasieka Ulowa');
    await expect(page.locator('text=Pasieka: Pasieka Ulowa')).toBeVisible();

    // Dodaj Ul 1
    await page.click('text=+ Dodaj Nowy Ul');
    await page.fill('input[placeholder="np. Ul #04"]', 'Ul 1');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ul 1')).toBeVisible();

    // Dodaj Ul 2 i Ul 3
    for (const hiveName of ['Ul 2', 'Ul 3']) {
      await page.click('text=+ Dodaj Nowy Ul');
      await page.fill('input[placeholder="np. Ul #04"]', hiveName);
      await page.click('button:has-text("Zapisz")');
      await expect(page.locator(`text=${hiveName}`)).toBeVisible();
    }

    // Przeciągnij Ul 2 przed Ul 1.
    const hiveOrder = () => page.locator('[data-testid="commercial-hive-card"]').evaluateAll(nodes => nodes.map(node => node.getAttribute('data-hive-id')));
    const hive1Id = await page.locator('[data-testid="commercial-hive-card"]', { hasText: 'Ul 1' }).getAttribute('data-hive-id');
    const hive1Card = page.locator(`[data-testid="commercial-hive-card"][data-hive-id="${hive1Id}"]`);
    const hive1Box = await hive1Card.boundingBox();
    await page.locator('[data-testid="commercial-hive-card"]', { hasText: 'Ul 2' }).dragTo(hive1Card, { targetPosition: { x: hive1Box.width / 2, y: hive1Box.height * 0.2 } });
    await expect.poll(hiveOrder).toEqual([
      await page.locator('[data-testid="commercial-hive-card"]', { hasText: 'Ul 2' }).getAttribute('data-hive-id'),
      hive1Id,
      await page.locator('[data-testid="commercial-hive-card"]', { hasText: 'Ul 3' }).getAttribute('data-hive-id')
    ]);

    // Edytuj Ul 1 (kliknij w kafelek ula, aby wejść w kartę ula)
    await page.click('text=Ul 1');
    await expect(page.locator('text=Karta Ula: Ul 1')).toBeVisible();
    await page.fill('div:has-text("Dane Techniczne") input[type="text"]', 'Ul 1 Edytowany');
    await page.click('text=← Powrót');
    await expect(page.locator('text=Ul 1 Edytowany')).toBeVisible();

    // Usuń Ul 3
    await page.locator('h3', { hasText: 'Ul 3' }).evaluate(node => {
      const card = node.parentElement;
      const delBtn = card.querySelector('[data-testid="delete-hive-trigger"]');
      if (delBtn) delBtn.click();
    });
    await page.getByTestId('confirm-delete-hive').click();
    await expect(page.locator('h3:has-text("Ul 3")')).not.toBeVisible();
  });

  test('6.5. Tworzenie i konfiguracja uli typu leżak i kombinowany', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj pasieczysko
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Pasieka Leżakowa');
    await page.click('button:has-text("Zapisz")');

    await page.click('text=Pasieka Leżakowa');
    await expect(page.locator('text=Pasieka: Pasieka Leżakowa')).toBeVisible();

    // Dodaj ul leżak z nadstawką
    await page.click('text=+ Dodaj Nowy Ul');
    await page.fill('input[placeholder="np. Ul #04"]', 'Ul Leżak 1');
    await page.selectOption('select', { value: 'lezak' });
    await page.check('input#newHiveHasSuperCheck');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ul Leżak 1')).toBeVisible();

    // Wejdź w kartę ula leżaka i sprawdź konfigurację
    await page.click('text=Ul Leżak 1');
    await expect(page.locator('text=Karta Ula: Ul Leżak 1')).toBeVisible();
    await expect(page.locator('text=Konfiguracja Gniazda i Nadstawek')).toBeVisible();
    await expect(page.locator('text=Maks. pojemność: 24 ramek')).toBeVisible();
    await expect(page.locator('text=10 / 24')).toBeVisible();

    // Zwiększ liczbę ramek w gnieździe przyciskiem ➕
    await page.click('button:has-text("➕")');
    await expect(page.locator('text=11 / 24')).toBeVisible();

    // Zmniejsz liczbę ramek w gnieździe przyciskiem ➖
    await page.click('button:has-text("➖")');
    await expect(page.locator('text=10 / 24')).toBeVisible();

    // Sprawdź przełączanie pola "Czy jest nadstawka" w widoku ula
    await expect(page.locator('input#detailHasSuperCheck')).toBeChecked();
    await page.uncheck('input#detailHasSuperCheck');
    await expect(page.locator('input#detailHasSuperCheck')).not.toBeChecked();
    await expect(page.locator('text=Brak nadstawki')).toBeVisible();
    await page.check('input#detailHasSuperCheck');
    await expect(page.locator('input#detailHasSuperCheck')).toBeChecked();
    await expect(page.locator('text=Typ ramki nadstawkowej')).toBeVisible();

    // Wróć do listy uli i dodaj ul kombinowany
    await page.click('button:has-text("← Powrót")');
    await page.click('text=+ Dodaj Nowy Ul');
    await page.fill('input[placeholder="np. Ul #04"]', 'Ul Kombinowany 1');
    await page.selectOption('select', { value: 'kombinowany' });
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ul Kombinowany 1')).toBeVisible();

    // Wejdź w kartę ula kombinowanego i przetestuj przyciski nadstawek
    await page.click('text=Ul Kombinowany 1');
    await expect(page.locator('text=Karta Ula: Ul Kombinowany 1')).toBeVisible();
    await expect(page.locator('text=Liczba nadstawek: 1')).toBeVisible();

    // Kliknij "Dodaj nadstawkę"
    await page.click('button:has-text("➕ Dodaj nadstawkę")');
    await expect(page.locator('text=Liczba nadstawek: 2')).toBeVisible();

    // Kliknij "Zabierz nadstawkę"
    await page.click('button:has-text("➖ Zabierz nadstawkę")');
    await expect(page.locator('text=Liczba nadstawek: 1')).toBeVisible();
  });

  test('7. Trutowisko i Uliki Weselne', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Trutowisko
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Testowe');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Testowe')).toBeVisible();

    // Wejdź do trutowiska
    await page.click('text=Trutowisko Testowe');
    await expect(page.locator('text=Trutowisko: Trutowisko Testowe')).toBeVisible();

    // Dodaj Ulik Weselny
    await page.click('text=+ Dodaj Ulik Weselny');
    await page.fill('input[placeholder="np. Ulik #01"]', 'Ulik 1');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ulik 1')).toBeVisible();

    // Wejdź do szczegółów uliku
    await page.click('text=Ulik 1');
    await expect(page.locator('text=Ulik Weselny: Ulik 1')).toBeVisible();

    // Test dat spodziewanego wygryzienia i unasiennienia (+12 dni)
    await page.fill('input[type="date"]', '2026-11-01');
    await expect(page.locator('input[type="date"]').nth(1)).toHaveValue('2026-11-13');

    // Test przejść stanów
    await expect(page.locator('text=Aktualny stan: (B) Bezmatek')).toBeVisible();
    await page.click('text=➕ Poddano matecznik (M)');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Aktualny stan: (M) Matecznik')).toBeVisible();
    await expect(page.locator('text=(B) - Poddano Matecznik -> (M)')).toBeVisible();

    await page.click('text=🦋 Matka się wygryzła (N)');
    await expect(page.locator('text=Aktualny stan: (N) Matka nieunasienniona')).toBeVisible();
    await expect(page.locator('text=(M) - Matka się wygryzła -> (N)')).toBeVisible();

    await page.click('text=👑 Matka się unasienniła (UNC)');
    await expect(page.locator('text=Aktualny stan: (UNC) Matka unasienniona')).toBeVisible();
    await expect(page.locator('text=(N) - Matka się unasienniła (UNC) -> (UNC)')).toBeVisible();

    // Test przycisku "zabieram matkę" powracającego do stanu Bezmatek
    await page.click('button:has-text("zabieram matkę (B)")');
    await expect(page.locator('text=Aktualny stan: (B) Bezmatek')).toBeVisible();
    await expect(page.locator('text=(UNC) - Zabrano matkę / zresetowano stan -> (B)')).toBeVisible();
  });

  test('7.1. Alerts wymagające uwagi na liście ulików weselnych', async ({ page }) => {
    const { yesterday, tomorrow, past35Days } = await page.evaluate(() => {
      const dateOffset = offset => {
        const date = new Date();
        date.setUTCDate(date.getUTCDate() + offset);
        return date.toISOString().slice(0, 10);
      };
      return { yesterday: dateOffset(-1), tomorrow: dateOffset(1), past35Days: dateOffset(-35) };
    });
    await page.evaluate(({ yesterday, tomorrow, past35Days }) => {
      const uliki = [
        { id: 'queenless', name: 'Bezmatek', hiveType: 'Mini plus', state: 'bezmatek', hasQueen: false, expectedHatchDate: '', expectedMatingDate: '', order: 0, history: [] },
        { id: 'overdue-hatch', name: 'Po terminie wygryzienia', hiveType: 'Mini plus', state: 'z_matecznikiem', hasQueen: true, expectedHatchDate: yesterday, expectedMatingDate: tomorrow, order: 1, history: [] },
        { id: 'overdue-mating', name: 'Po terminie unasiennienia', hiveType: 'Mini plus', state: 'matka_wygryziona', hasQueen: true, expectedHatchDate: yesterday, expectedMatingDate: yesterday, order: 2, history: [] },
        { id: 'overdue-30days', name: 'Po terminie 30 dni', hiveType: 'Mini plus', state: 'matka_wygryziona', hasQueen: true, expectedHatchDate: past35Days, expectedMatingDate: tomorrow, order: 3, history: [] },
        { id: 'multiple-reasons', name: 'Wielokrotny alert', hiveType: 'Mini plus', state: 'matka_wygryziona', hasQueen: true, expectedHatchDate: past35Days, expectedMatingDate: yesterday, order: 4, history: [] },
        { id: 'future', name: 'Termin w przyszłości', hiveType: 'Mini plus', state: 'z_matecznikiem', hasQueen: true, expectedHatchDate: tomorrow, expectedMatingDate: tomorrow, order: 5, history: [] }
      ];
      localStorage.setItem('__E2E_STATE__', JSON.stringify({
        apiaries: [{
          id: 'attention-apiary', name: 'Trutowisko Alertów', apiaryType: 'trutowisko',
          adminId: 'e2e-test-uid', order: 0,
          uliki, hives: []
        }], uliki: { 'attention-apiary': uliki }, hives: {}, notes: {}
      }));
    }, { yesterday, tomorrow, past35Days });
    await page.reload();
    await page.evaluate(() => {
      window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
    });
    await page.getByText('Trutowisko Alertów').click();
    await expect(page.getByText('Trutowisko: Trutowisko Alertów')).toBeVisible();

    const alerts = page.locator('button[aria-label]:not([data-testid="main-menu-toggle"])');
    await expect(alerts).toHaveCount(5);
    await expect(page.getByRole('button', { name: 'Brak matki w ulu', exact: true })).toHaveAttribute('title', 'Brak matki w ulu');
    await expect(page.getByRole('button', { name: 'Sprawdź, czy matka się wygryzła', exact: true })).toHaveAttribute('title', 'Sprawdź, czy matka się wygryzła');
    await expect(page.getByRole('button', { name: 'Minął oczekiwany termin unasiennienia matki', exact: true })).toHaveAttribute('title', 'Minął oczekiwany termin unasiennienia matki');
    await expect(page.getByRole('button', { name: 'Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona', exact: true })).toHaveAttribute('title', 'Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona');
    await expect(page.getByRole('button', { name: 'Minął oczekiwany termin unasiennienia matki / Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona', exact: true })).toHaveAttribute('title', 'Minął oczekiwany termin unasiennienia matki / Minął deadline 30 dni od wygryzienia – matka nadal nieunasienniona');
    await expect(page.getByText('Termin w przyszłości').locator('..').locator('button[aria-label]')).toHaveCount(0);

    const queenlessAlert = page.getByRole('button', { name: 'Brak matki w ulu' });
    await queenlessAlert.focus();
    await expect(queenlessAlert).toBeFocused();
    await queenlessAlert.click();
    await expect(page.getByText('Trutowisko: Trutowisko Alertów')).toBeVisible();
  });

  test('7.2. Alert wymagający uwagi na karcie trutowiska na liście pasiek', async ({ page }) => {
    const { yesterday, tomorrow } = await page.evaluate(() => {
      const dateOffset = offset => {
        const date = new Date();
        date.setUTCDate(date.getUTCDate() + offset);
        return date.toISOString().slice(0, 10);
      };
      return { yesterday: dateOffset(-1), tomorrow: dateOffset(1) };
    });

    await page.evaluate(({ yesterday, tomorrow }) => {
      const ulikiSingle = [
        { id: 'single-ok', name: 'Ulik Spokojny', hiveType: 'Mini plus', state: 'pusty', hasQueen: false, expectedHatchDate: '', expectedMatingDate: '', order: 0, history: [] },
        { id: 'single-urgent', name: 'Ulik Pilny', hiveType: 'Mini plus', state: 'bezmatek', hasQueen: false, expectedHatchDate: '', expectedMatingDate: '', order: 1, history: [] }
      ];

      const ulikiMultiple = [
        { id: 'm-1', name: 'Ulik Jeden', hiveType: 'Mini plus', state: 'bezmatek', hasQueen: false, expectedHatchDate: '', expectedMatingDate: '', order: 0, history: [] },
        { id: 'm-2', name: 'Ulik Dwa', hiveType: 'Mini plus', state: 'z_matecznikiem', hasQueen: true, expectedHatchDate: yesterday, expectedMatingDate: tomorrow, order: 1, history: [] },
        { id: 'm-3', name: 'Ulik Trzy', hiveType: 'Mini plus', state: 'pusty', hasQueen: false, expectedHatchDate: '', expectedMatingDate: '', order: 2, history: [] },
        { id: 'm-4', name: 'Ulik Cztery', hiveType: 'Mini plus', state: 'matka_wygryziona', hasQueen: true, expectedHatchDate: tomorrow, expectedMatingDate: yesterday, order: 3, history: [] }
      ];

      const ulikiClean = [
        { id: 'clean-1', name: 'Ulik Czysty Pusty', hiveType: 'Mini plus', state: 'pusty', hasQueen: false, expectedHatchDate: '', expectedMatingDate: '', order: 0, history: [] },
        { id: 'clean-2', name: 'Ulik Czysty Przyszłość', hiveType: 'Mini plus', state: 'z_matecznikiem', hasQueen: true, expectedHatchDate: tomorrow, expectedMatingDate: tomorrow, order: 1, history: [] }
      ];

      localStorage.setItem('__E2E_STATE__', JSON.stringify({
        apiaries: [
          {
            id: 'mating-single', name: 'Trutowisko Pojedyncze', apiaryType: 'trutowisko',
            adminId: 'e2e-test-uid', order: 0,
            uliki: ulikiSingle, hives: []
          },
          {
            id: 'mating-multiple', name: 'Trutowisko Wielokrotne', apiaryType: 'trutowisko',
            adminId: 'e2e-test-uid', order: 1,
            uliki: ulikiMultiple, hives: []
          },
          {
            id: 'mating-clean', name: 'Trutowisko Czyste', apiaryType: 'trutowisko',
            adminId: 'e2e-test-uid', order: 2,
            uliki: ulikiClean, hives: []
          },
          {
            id: 'comm-1', name: 'Pasieka Towarowa Alert', apiaryType: 'towarowe',
            adminId: 'e2e-test-uid', order: 3,
            uliki: [], hives: [{ id: 'hive-1', name: 'Ul 1', frameType: 'Dadant', bodyEditor: { bodies: [] }, notes: [] }]
          }
        ],
        uliki: {
          'mating-single': ulikiSingle,
          'mating-multiple': ulikiMultiple,
          'mating-clean': ulikiClean
        },
        hives: {
          'comm-1': [{ id: 'hive-1', name: 'Ul 1', frameType: 'Dadant', bodyEditor: { bodies: [] }, notes: [] }]
        },
        notes: {}
      }));
    }, { yesterday, tomorrow });

    await page.reload();
    await page.evaluate(() => {
      window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible();

    // 1. Pasieka towarowa nie posiada alertu ulików
    const commercialHeader = page.getByRole('heading', { level: 3, name: 'Pasieka Towarowa Alert' }).locator('..');
    await expect(commercialHeader.getByTestId('apiary-attention-alert')).toHaveCount(0);

    // 2. Trutowisko bez aktywnych alertów nie posiada wykrzyknika
    const cleanHeader = page.getByRole('heading', { level: 3, name: 'Trutowisko Czyste' }).locator('..');
    await expect(cleanHeader.getByTestId('apiary-attention-alert')).toHaveCount(0);

    // 3. Trutowisko z jednym alertowym ulikem pokazuje wykrzyknik z nazwą tego uliku
    const singleAlert = page.getByRole('heading', { level: 3, name: 'Trutowisko Pojedyncze' }).locator('..').getByTestId('apiary-attention-alert');
    await expect(singleAlert).toBeVisible();
    await expect(singleAlert).toHaveAttribute('title', 'Uliki wymagające akcji: Ulik Pilny');
    await expect(singleAlert).toHaveAttribute('aria-label', 'Uliki wymagające akcji: Ulik Pilny');

    // 4. Trutowisko z wieloma alertami wymienia wszystkie alertowe uliki w kolejności listy
    const multipleAlert = page.getByRole('heading', { level: 3, name: 'Trutowisko Wielokrotne' }).locator('..').getByTestId('apiary-attention-alert');
    await expect(multipleAlert).toBeVisible();
    await expect(multipleAlert).toHaveAttribute('title', 'Uliki wymagające akcji: Ulik Jeden, Ulik Dwa, Ulik Cztery');
    await expect(multipleAlert).toHaveAttribute('aria-label', 'Uliki wymagające akcji: Ulik Jeden, Ulik Dwa, Ulik Cztery');

    // 5. Alert jest dostępny przez klawiaturę (focus)
    await multipleAlert.focus();
    await expect(multipleAlert).toBeFocused();

    // 6. Kliknięcie w alert nie uruchamia nawigacji karty trutowiska
    await multipleAlert.click();
    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible();
    await expect(page.getByRole('heading', { level: 3, name: 'Trutowisko Wielokrotne' })).toBeVisible();

    // 7. Kliknięcie w treść karty pasieki normalnie otwiera widok trutowiska i zachowuje pojedyncze alerty ulików
    await page.getByRole('heading', { level: 3, name: 'Trutowisko Wielokrotne' }).click();
    await expect(page.getByText('Trutowisko: Trutowisko Wielokrotne')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Brak matki w ulu', exact: true })).toBeVisible();
  });

  test('7.3. Filtr tylko wymagające akcji na liście ulików weselnych', async ({ page }) => {
    const { today, yesterday, tomorrow } = await page.evaluate(() => {
      const dateOffset = offset => {
        const date = new Date();
        date.setUTCDate(date.getUTCDate() + offset);
        return date.toISOString().slice(0, 10);
      };
      return { today: dateOffset(0), yesterday: dateOffset(-1), tomorrow: dateOffset(1) };
    });

    await page.evaluate(({ today, yesterday, tomorrow }) => {
      const uliki = [
        { id: 'u-queenless', name: 'Ulik Bezmatek', hiveType: 'Mini plus', state: 'bezmatek', hasQueen: false, expectedHatchDate: '', expectedMatingDate: '', order: 0, history: [] },
        { id: 'u-due-today-hatch', name: 'Ulik Wygryzienie Dziś', hiveType: 'Mini plus', state: 'z_matecznikiem', hasQueen: true, expectedHatchDate: today, expectedMatingDate: tomorrow, order: 1, history: [] },
        { id: 'u-due-today-mating', name: 'Ulik Unasiennienie Dziś', hiveType: 'Mini plus', state: 'matka_wygryziona', hasQueen: true, expectedHatchDate: yesterday, expectedMatingDate: today, order: 2, history: [] },
        { id: 'u-overdue', name: 'Ulik Przeterminowany', hiveType: 'Mini plus', state: 'z_matecznikiem', hasQueen: true, expectedHatchDate: yesterday, expectedMatingDate: tomorrow, order: 3, history: [] },
        { id: 'u-future', name: 'Ulik W Przyszłości', hiveType: 'Mini plus', state: 'z_matecznikiem', hasQueen: true, expectedHatchDate: tomorrow, expectedMatingDate: tomorrow, order: 4, history: [] },
        { id: 'u-clean', name: 'Ulik Pusty', hiveType: 'Mini plus', state: 'pusty_ulik', hasQueen: false, expectedHatchDate: '', expectedMatingDate: '', order: 5, history: [] }
      ];
      localStorage.setItem('__E2E_STATE__', JSON.stringify({
        apiaries: [{
          id: 'filter-action-apiary', name: 'Trutowisko Filtr Akcji', apiaryType: 'trutowisko',
          adminId: 'e2e-test-uid', order: 0,
          uliki, hives: []
        }], uliki: { 'filter-action-apiary': uliki }, hives: {}, notes: {}
      }));
    }, { today, yesterday, tomorrow });

    await page.reload();
    await page.evaluate(() => {
      window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
    });
    await page.getByText('Trutowisko Filtr Akcji').click();
    await expect(page.getByText('Trutowisko: Trutowisko Filtr Akcji')).toBeVisible();

    // 1. Domyślnie checkbox "Tylko wymagające akcji" jest odznaczony i widoczne są wszystkie uliki
    const actionCheckbox = page.getByRole('checkbox', { name: 'Tylko wymagające akcji' });
    await expect(actionCheckbox).toBeVisible();
    await expect(actionCheckbox).not.toBeChecked();

    await expect(page.getByText('Ulik Bezmatek')).toBeVisible();
    await expect(page.getByText('Ulik Wygryzienie Dziś')).toBeVisible();
    await expect(page.getByText('Ulik Unasiennienie Dziś')).toBeVisible();
    await expect(page.getByText('Ulik Przeterminowany')).toBeVisible();
    await expect(page.getByText('Ulik W Przyszłości')).toBeVisible();
    await expect(page.getByText('Ulik Pusty')).toBeVisible();

    // 2. Po zaznaczeniu widoczne są tylko uliki wymagające akcji (bezmatek, termin dzisiaj, przeterminowane)
    await actionCheckbox.check();
    await expect(actionCheckbox).toBeChecked();

    await expect(page.getByText('Ulik Bezmatek')).toBeVisible();
    await expect(page.getByText('Ulik Wygryzienie Dziś')).toBeVisible();
    await expect(page.getByText('Ulik Unasiennienie Dziś')).toBeVisible();
    await expect(page.getByText('Ulik Przeterminowany')).toBeVisible();

    await expect(page.getByText('Ulik W Przyszłości')).not.toBeVisible();
    await expect(page.getByText('Ulik Pusty')).not.toBeVisible();

    // Zachowane są znaczniki uwagi (!) na ulikach wymagających akcji
    const alerts = page.locator('button[aria-label]:not([data-testid="main-menu-toggle"])');
    await expect(alerts).toHaveCount(4);

    // 3. Połączenie filtru akcji z filtrem stanu ulików
    const stateSelect = page.locator('select').first();
    await stateSelect.selectOption('z_matecznikiem');

    await expect(page.getByText('Ulik Wygryzienie Dziś')).toBeVisible();
    await expect(page.getByText('Ulik Przeterminowany')).toBeVisible();
    await expect(page.getByText('Ulik Bezmatek')).not.toBeVisible();
    await expect(page.getByText('Ulik Unasiennienie Dziś')).not.toBeVisible();
    await expect(page.getByText('Ulik W Przyszłości')).not.toBeVisible();
    await expect(page.getByText('Ulik Pusty')).not.toBeVisible();

    // 4. Pusty stan przy braku dopasowań
    await stateSelect.selectOption('pusty_ulik');
    await expect(page.getByText('Brak ulików wymagających akcji.')).toBeVisible();

    // Lista pozostaje sterowalna i responsywna
    await stateSelect.selectOption('all');
    await expect(page.getByText('Brak ulików wymagających akcji.')).not.toBeVisible();
    await expect(page.getByText('Ulik Bezmatek')).toBeVisible();

    // 5. Odznaczenie checkboxa przywraca pełną listę
    await actionCheckbox.uncheck();
    await expect(actionCheckbox).not.toBeChecked();

    await expect(page.getByText('Ulik Bezmatek')).toBeVisible();
    await expect(page.getByText('Ulik Wygryzienie Dziś')).toBeVisible();
    await expect(page.getByText('Ulik Unasiennienie Dziś')).toBeVisible();
    await expect(page.getByText('Ulik Przeterminowany')).toBeVisible();
    await expect(page.getByText('Ulik W Przyszłości')).toBeVisible();
    await expect(page.getByText('Ulik Pusty')).toBeVisible();

    // 6. Nawigacja do uliku i powrót (brak modyfikacji danych)
    await page.getByText('Ulik Wygryzienie Dziś').click();
    await expect(page.getByText('Ulik Weselny: Ulik Wygryzienie Dziś')).toBeVisible();
    await page.getByRole('button', { name: '← Powrót' }).click();
    await expect(page.getByText('Trutowisko: Trutowisko Filtr Akcji')).toBeVisible();

    const storedData = await page.evaluate(() => JSON.parse(localStorage.getItem('__E2E_STATE__')));
    expect(storedData.uliki['filter-action-apiary']).toHaveLength(6);
  });

  test('8. Type-specific apiary views', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Pasieka Towarowa
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Pasieka Towarowa');
    await page.selectOption('div[style*="position: fixed"] select', 'towarowe');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Pasieka Towarowa')).toBeVisible();

    // Dodaj Trutowisko Filtr
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Filtr');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Filtr')).toBeVisible();

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Pasieczyska towarowe' }).click();
    await expect(page.locator('text=Pasieka Towarowa')).toBeVisible();
    await expect(page.locator('text=Trutowisko Filtr')).not.toBeVisible();

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    await expect(page.locator('text=Trutowisko Filtr')).toBeVisible();
    await expect(page.locator('text=Pasieka Towarowa')).not.toBeVisible();
  });

  test('9. Filtr stanów ulików weselnych', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Trutowisko
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Stanów');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Stanów')).toBeVisible();

    // Wejdź do trutowiska
    await page.click('text=Trutowisko Stanów');
    await expect(page.locator('text=Trutowisko: Trutowisko Stanów')).toBeVisible();

    // Dodaj Ulik 1 (zostaje Bezmatek)
    await page.click('text=+ Dodaj Ulik Weselny');
    await page.fill('input[placeholder="np. Ulik #01"]', 'Ulik Bezmatek');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ulik Bezmatek')).toBeVisible();

    // Dodaj Ulik 2
    await page.click('text=+ Dodaj Ulik Weselny');
    await page.fill('input[placeholder="np. Ulik #01"]', 'Ulik Z Matecznikiem');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ulik Z Matecznikiem')).toBeVisible();

    // Zmień stan Ulik Z Matecznikiem na (M) Matecznik
    await page.click('text=Ulik Z Matecznikiem');
    await page.click('text=➕ Poddano matecznik (M)');
    await page.click('button:has-text("Zapisz")');
    await page.click('text=← Powrót');

    // Przetestuj filtr stanów: Bezmatek
    await page.selectOption('div:has-text("Filtruj stan:") select', 'bezmatek');
    await expect(page.locator('text=Ulik Bezmatek')).toBeVisible();
    await expect(page.locator('text=Ulik Z Matecznikiem')).not.toBeVisible();

    // Przetestuj filtr stanów: Z matecznikiem
    await page.selectOption('div:has-text("Filtruj stan:") select', 'z_matecznikiem');
    await expect(page.locator('text=Ulik Z Matecznikiem')).toBeVisible();
    await expect(page.locator('text=Ulik Bezmatek')).not.toBeVisible();

    // Przetestuj filtr stanów: Wszystkie
    await page.selectOption('div:has-text("Filtruj stan:") select', 'all');
    await expect(page.locator('text=Ulik Bezmatek')).toBeVisible();
    await expect(page.locator('text=Ulik Z Matecznikiem')).toBeVisible();
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

  test('11. Edytowalna lista ras i linii matek oraz wybór w uliku weselnym', async ({ page }) => {
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
    await page.getByTestId('settings-section-toggle-trutowiska').click();

    // Dodaj nową rasę/linię matek
    await page.fill('input[placeholder="Nowa rasa/linia (np. car. Galicja)"]', 'car. Testowa Linia');
    await page.click('button:has-text("Dodaj"):near(input[placeholder="Nowa rasa/linia (np. car. Galicja)"])');
    await expect(page.locator('text=car. Testowa Linia')).toBeVisible();

    // Powrót do pasieczysk
    await page.click('button:has-text("← Powrót")');

    // Dodaj Trutowisko
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Rasy');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Rasy')).toBeVisible();

    // Wejdź do trutowiska i dodaj ulik
    await page.click('text=Trutowisko Rasy');
    await page.click('text=+ Dodaj Ulik Weselny');
    await page.fill('input[placeholder="np. Ulik #01"]', 'Ulik Wybór Rasy');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ulik Wybór Rasy')).toBeVisible();

    // Wejdź w ulik, zaznacz że jest matka i wybierz dodaną rasę
    await page.click('text=Ulik Wybór Rasy');
    await page.selectOption('select:has-text("Tak")', { value: 'true' });
    await page.selectOption('select:has-text("car. Galicja")', { value: 'car. Testowa Linia' });
    await expect(page.locator('select:has-text("car. Testowa Linia")')).toHaveValue('car. Testowa Linia');
  });

  test('12. Przenoszenie ulika weselnego między trutowiskami', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Trutowisko 1
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Źródłowe');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Źródłowe')).toBeVisible();

    // Dodaj Trutowisko 2
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Docelowe');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Docelowe')).toBeVisible();

    // Wejdź do Trutowisko Źródłowe i dodaj ulik
    await page.click('text=Trutowisko Źródłowe');
    await page.click('text=+ Dodaj Ulik Weselny');
    await page.fill('input[placeholder="np. Ulik #01"]', 'Ulik do Przeniesienia');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ulik do Przeniesienia')).toBeVisible();

    // Wejdź w szczegóły uliku żeby pobrać NFC link
    await page.click('text=Ulik do Przeniesienia');
    const nfcInput = page.locator('label:has-text("Link do NFC:") + div input[readonly]');
    await expect(nfcInput).toBeVisible();
    const originalNfcLink = await nfcInput.inputValue();
    expect(originalNfcLink).toContain('#ulik/');

    // Powrót do listy ulików w Trutowisko Źródłowe
    await page.click('button:has-text("← Powrót")');

    // Kliknij przycisk przeniesienia (🚚) na uliku
    await page.getByTestId('MoveMatingHive').evaluate(button => button.click());
    await expect(page.locator('text=Przenieś ulik: Ulik do Przeniesienia')).toBeVisible();

    // Wybierz docelowe trutowisko i kliknij Przenieś
    await page.selectOption('div[style*="position: fixed"] select', { label: 'Trutowisko Docelowe' });
    await page.getByTestId('submit-move-mating-hive').click();

    // Modal powinien zniknąć, a ulik powinien zniknąć z Trutowisko Źródłowe
    await expect(page.locator('text=Przenieś ulik: Ulik do Przeniesienia')).not.toBeVisible();
    await expect(page.locator('h3:has-text("Ulik do Przeniesienia")')).not.toBeVisible();

    // Powrót do listy pasieczysk i wejście do Trutowisko Docelowe
    await page.click('button:has-text("← Powrót")');
    await page.click('text=Trutowisko Docelowe');
    await expect(page.locator('text=Ulik do Przeniesienia')).toBeVisible();

    // Wejdź w szczegóły ulika w nowym trutowisku i zweryfikuj, że link NFC nie uległ zmianie
    await page.click('text=Ulik do Przeniesienia');
    await expect(nfcInput).toBeVisible();
    const movedNfcLink = await nfcInput.inputValue();
    expect(movedNfcLink).toEqual(originalNfcLink);
  });

  test('13. Przenoszenie ulika weselnego z poziomu szczegółów uliku', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Trutowisko 1
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Src');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Src')).toBeVisible();

    // Dodaj Trutowisko 2
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Dest');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Dest')).toBeVisible();

    // Wejdź do Trutowisko Src i dodaj ulik
    await page.click('text=Trutowisko Src');
    await page.click('text=+ Dodaj Ulik Weselny');
    await page.fill('input[placeholder="np. Ulik #01"]', 'Ulik Szczegóły Move');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Ulik Szczegóły Move')).toBeVisible();

    // Wejdź w szczegóły uliku
    await page.click('text=Ulik Szczegóły Move');
    await expect(page.locator('text=Ulik Weselny: Ulik Szczegóły Move')).toBeVisible();

    // Kliknij przycisk zmiany pasieczyska w szczegółach uliku
    await page.getByTestId('MoveMatingHive').click();
    await expect(page.locator('text=Przenieś ulik: Ulik Szczegóły Move')).toBeVisible();

    // Wybierz docelowe trutowisko i kliknij Przenieś
    await page.selectOption('div[style*="position: fixed"] select', { label: 'Trutowisko Dest' });
    await page.getByTestId('submit-move-mating-hive').click();

    // Nie powinien wisieć na "Ładowanie uliku", powinien wrócić do listy ulików w Trutowisko Src
    await expect(page.locator('text=Trutowisko: Trutowisko Src')).toBeVisible();
    await expect(page.locator('text=Ładowanie uliku')).not.toBeVisible();

    // Powrót do listy pasieczysk i wejście do Trutowisko Dest
    await page.click('button:has-text("← Powrót")');
    await page.click('text=Trutowisko Dest');
    await expect(page.locator('text=Ulik Szczegóły Move')).toBeVisible();
  });

  test('14. Poddanie matki nieunasiennionej z opcjonalnym opalitkiem', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Trutowisko
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Opalit');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Trutowisko Opalit')).toBeVisible();

    // Wejdź do trutowiska
    await page.click('text=Trutowisko Opalit');
    await page.click('text=+ Dodaj Ulik Weselny');
    await page.fill('input[placeholder="np. Ulik #01"]', 'Ulik Opalitkowy');
    await page.click('button:has-text("Zapisz")');

    // Wejdź do szczegółów uliku
    await page.click('text=Ulik Opalitkowy');
    await expect(page.locator('text=Aktualny stan: (B) Bezmatek')).toBeVisible();

    // Poddaj matkę nieunasiennioną z opalitkiem = Tak
    await page.click('text=➕ Poddano matkę nieunasiennioną (N)');
    await page.locator('div[style*="position: fixed"] select').nth(1).selectOption('Tak');
    await page.locator('div[style*="position: fixed"] select').nth(2).selectOption('Żółty');
    await page.fill('input[placeholder="np. 42"]', '123');
    await page.click('button:has-text("Zapisz")');

    await expect(page.locator('text=Aktualny stan: (N) Matka nieunasienniona')).toBeVisible();
    await expect(page.locator('text=Opalit Żółty #123')).toBeVisible();
  });

  test('15. Generowanie linku NFC, pole readonly oraz kopiowanie', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Pasieczysko
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Pasieka NFC');
    await page.click('button:has-text("Zapisz")');
    await page.click('text=Pasieka NFC');

    // Dodaj Ul
    await page.click('text=+ Dodaj Nowy Ul');
    await page.fill('input[placeholder="np. Ul #04"]', 'Ul NFC');
    await page.click('button:has-text("Zapisz")');
    await page.click('text=Ul NFC');

    // Sprawdź, czy pole linku NFC jest widoczne i ma wygenerowany link zawierający #hive/
    const nfcInput = page.locator('label:has-text("Link do NFC:") + div input[readonly]');
    await expect(nfcInput).toBeVisible();
    const linkVal = await nfcInput.inputValue();
    expect(linkVal).toContain('#hive/');

    // Sprawdź przycisk kopiowania
    await page.click('button:has-text("📋 Kopiuj link do NFC")');
  });

  test('16. Powrót z poziomu uliku weselnego po przeniesieniu na inne trutowisko i użyciu linku', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Trutowisko Źródłowe
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Źródło');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');

    // Dodaj Trutowisko Docelowe
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Trutowisko Cel');
    await page.selectOption('div[style*="position: fixed"] select', 'trutowisko');
    await page.click('button:has-text("Zapisz")');

    // Wejdź do Trutowisko Źródło i dodaj ulik
    await page.click('text=Trutowisko Źródło');
    await page.click('text=+ Dodaj Ulik Weselny');
    await page.fill('input[placeholder="np. Ulik #01"]', 'Ulik Powrót Test');
    await page.click('button:has-text("Zapisz")');

    // Przenieś ulik do Trutowisko Cel
    await page.getByTestId('MoveMatingHive').evaluate(button => button.click());
    await page.selectOption('div[style*="position: fixed"] select', { label: 'Trutowisko Cel' });
    await page.click('button:has-text("Przenieś")');

    // Wróć do listy pasieczysk i wejście do Trutowisko Cel
    await page.click('button:has-text("← Powrót")');
    await page.click('text=Trutowisko Cel');

    // Otwórz szczegóły uliku w Trutowisko Cel
    await page.click('text=Ulik Powrót Test');
    await expect(page.locator('text=Ulik Weselny: Ulik Powrót Test')).toBeVisible();

    // Kliknij przycisk "← Powrót" i sprawdź, czy wracamy do Trutowisko Cel (a nie Źródło)
    await page.click('button:has-text("← Powrót")');
    await expect(page.locator('text=Trutowisko: Trutowisko Cel')).toBeVisible();
  });

  test('16. Opcjonalne pasieczyska towarowe', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj Pasieka Towarowa
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Pasieka Testowa Opcjonalna');
    await page.selectOption('div[style*="position: fixed"] select', 'towarowe');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Pasieka Testowa Opcjonalna')).toBeVisible();

    // Przejdź do ustawień i wyłącz Pasieczyska Towarowe
    const settingsBtn = page.getByRole('button', { name: '⚙️ Ustawienia' });
    if (!(await settingsBtn.isVisible())) {
      await page.getByTestId('main-menu-toggle').click();
    }
    await settingsBtn.click();
    await expect(page.locator('text=⚙️ Ustawienia')).toBeVisible();
    if (!(await page.getByTestId('commercial-apiaries-toggle').isVisible())) {
      await page.getByTestId('settings-section-toggle-pasieczyska').click();
    }
    await page.getByTestId('commercial-apiaries-toggle').uncheck();
    await page.click('button:has-text("← Powrót")');

    // Sprawdź czy Pasieka Testowa Opcjonalna zniknęła z listy
    await expect(page.locator('text=Pasieka Testowa Opcjonalna')).not.toBeVisible();

    // Wróć do ustawień i włącz ponownie Pasieczyska Towarowe
    if (!(await settingsBtn.isVisible())) {
      await page.getByTestId('main-menu-toggle').click();
    }
    await settingsBtn.click();
    const commercialSettingsSection = page.getByTestId('settings-section-toggle-pasieczyska');
    if ((await commercialSettingsSection.getAttribute('aria-expanded')) !== 'true') {
      await commercialSettingsSection.click();
    }
    const commercialToggle = page.getByTestId('commercial-apiaries-toggle');
    await expect(commercialToggle).toBeVisible();
    await commercialToggle.evaluate(element => element.click());
    await expect(commercialToggle).toBeChecked();
    await page.click('button:has-text("← Powrót")');

    // Sprawdź czy Pasieka Testowa Opcjonalna znów jest widoczna
    await expect(page.locator('text=Pasieka Testowa Opcjonalna')).toBeVisible();
  });

  test('17. Edytor korpusów w ulu towarowym', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await page.evaluate(() => {
      if (window.app && window.app.ports && window.app.ports.authStateChanged) {
        window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
      }
    });

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Dodaj pasieczysko towarowe
    await page.click('text=+ Dodaj Pasieczysko');
    await page.fill('input[placeholder="Nazwa pasieczyska"]', 'Pasieka Korpusowa');
    await page.click('button:has-text("Zapisz")');
    await page.click('text=Pasieka Korpusowa');

    // Dodaj ul
    await page.click('text=+ Dodaj Nowy Ul');
    await page.fill('input[placeholder="np. Ul #04"]', 'Ul Korpusowy');
    await page.click('button:has-text("Zapisz")');
    await page.click('text=Ul Korpusowy');

    await expect(page.locator('text=Edytor Korpusów (Stan Ula)')).toBeVisible();
    await expect(page.locator('text=Korpus #1')).toBeVisible();

    const korpusOrder = async () => page.locator('[data-korpus-id]').evaluateAll(
      nodes => nodes.map(node => node.getAttribute('data-korpus-id'))
    );
    const dragKorpusTo = async (sourceSelector, targetSelector) => {
      const sourceLocator = page.locator(sourceSelector).locator('[data-korpus-drag-handle]');
      const targetLocator = page.locator(targetSelector);
      await sourceLocator.scrollIntoViewIfNeeded();
      const source = await sourceLocator.boundingBox();
      await page.mouse.move(source.x + source.width / 2, source.y + source.height / 2);
      await page.mouse.down();
      await targetLocator.scrollIntoViewIfNeeded();
      const target = await targetLocator.boundingBox();
      await page.mouse.move(target.x + target.width / 2, target.y + target.height / 2, { steps: 8 });
      await page.mouse.up();
    };

    await expect.poll(korpusOrder).toEqual(['1']);

    // Dodanie nad wskazanym korpusem (również gdy nie jest pierwszy).
    await page.locator('[data-korpus-id="1"] button[title="Dodaj korpus nad"]').click();
    await expect.poll(korpusOrder).toEqual(['2', '1']);

    // Dodanie pod wskazanym korpusem.
    await page.locator('[data-korpus-id="2"] button[title="Dodaj korpus pod"]').click();
    await expect.poll(korpusOrder).toEqual(['2', '3', '1']);

    // Dodanie nad i pod korpusem ze środka stosu.
    await page.locator('[data-korpus-id="3"] button[title="Dodaj korpus nad"]').click();
    await expect.poll(korpusOrder).toEqual(['2', '4', '3', '1']);
    await page.locator('[data-korpus-id="4"] button[title="Dodaj korpus pod"]').click();
    await expect.poll(korpusOrder).toEqual(['2', '4', '5', '3', '1']);
    await expect(page.locator('[data-korpus-id="1"]')).toContainText('Korpus #1');

    // Dane matki i kraty pozostają przy tym samym korpusie.
    const korpus3 = page.locator('[data-korpus-id="3"]');
    await korpus3.locator('label:has-text("Matka") input[type="checkbox"]').check();
    await korpus3.locator('label:has-text("Krata") input[type="checkbox"]').check();
    await korpus3.locator('label:has-text("Folia na korpusie") input[type="checkbox"]').check();
    await korpus3.locator('label:has-text("Otwarty wylotek w korpusie") input[type="checkbox"]').check();
    await expect(korpus3.locator('label:has-text("Matka") input[type="checkbox"]')).toBeChecked();
    await expect(korpus3.locator('label:has-text("Krata") input[type="checkbox"]')).toBeChecked();
    await expect(korpus3.locator('label:has-text("Folia na korpusie") input[type="checkbox"]')).toBeChecked();
    await expect(korpus3.locator('label:has-text("Otwarty wylotek w korpusie") input[type="checkbox"]')).toBeChecked();
    await expect(korpus3).toContainText('Szczelna folia nad korpusem');
    await page.locator('button[title="Zapisz pełny stan ula jako notatkę"]').click();
    await expect(page.locator('body')).toContainText('Korpusy (od góry):');
    await expect(page.locator('body')).toContainText('Korpus #3: matka tak, krata nad korpusem tak, folia nad korpusem tak, otwarty wylotek tak');

    // Usunięcie korpusu ze środka usuwa jego ID, nie najniższy korpus.
    await page.locator('[data-korpus-id="4"] button[title="Usuń ten korpus"]').click();
    await expect.poll(korpusOrder).toEqual(['2', '5', '3', '1']);
    await expect(page.locator('[data-korpus-id="3"] label:has-text("Matka") input[type="checkbox"]')).toBeChecked();
    await expect(page.locator('[data-korpus-id="3"] label:has-text("Krata") input[type="checkbox"]')).toBeChecked();
    await expect(page.locator('[data-korpus-id="3"] label:has-text("Folia na korpusie") input[type="checkbox"]')).toBeChecked();
    await expect(page.locator('[data-korpus-id="3"] label:has-text("Otwarty wylotek w korpusie") input[type="checkbox"]')).toBeChecked();

    // Upuszczenie w górnej strefie przesuwa korpus nad cel.
    await dragKorpusTo('[data-korpus-id="1"]', '[data-korpus-id="3"] [data-korpus-drop$="|before"]');
    await expect.poll(korpusOrder).toEqual(['2', '5', '1', '3']);
    await expect(page.locator('[data-korpus-id="1"]')).toContainText('Korpus #1');

    // Upuszczenie w dolnej strefie przenosi Korpus #1 na dół bez zmiany jego nazwy.
    await dragKorpusTo('[data-korpus-id="1"]', '[data-korpus-id="3"] [data-korpus-drop$="|after"]');
    await expect.poll(korpusOrder).toEqual(['2', '5', '3', '1']);
    await expect(page.locator('[data-korpus-id="1"]')).toContainText('Korpus #1');

    // Pozostałe usunięcia oraz blokada usunięcia ostatniego korpusu.
    await page.locator('[data-korpus-id="3"] button[title="Usuń ten korpus"]').click();
    await expect.poll(korpusOrder).toEqual(['2', '5', '1']);
    await page.locator('[data-korpus-id="1"] button[title="Usuń ten korpus"]').click();
    await expect.poll(korpusOrder).toEqual(['2', '5']);
    await page.locator('[data-korpus-id="2"] button[title="Usuń ten korpus"]').click();
    await expect.poll(korpusOrder).toEqual(['5']);
    await expect(page.locator('[data-korpus-id="5"] button[disabled]')).toHaveCount(1);
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

  test('drag and drop reorders apiaries, commercial hives, and filtered mating hives persistently', async ({ page }) => {
    await page.setViewportSize({ width: 1280, height: 1200 });
    const hive = (id, name, apiaryId, order) => ({ id, name, apiaryId, order, hiveType: 'korpusowy', frameType: 'Wielkopolska' });
    const ulik = (id, name, apiaryId, state, order) => ({ id, name, apiaryId, state, order, hiveType: 'Mini plus', hasQueen: state !== 'bezmatek', history: [] });
    await page.evaluate(({ hives, uliki }) => {
      localStorage.setItem('__E2E_STATE__', JSON.stringify({
        apiaries: [
          { id: 'mating-a', name: 'Mating A', apiaryType: 'trutowisko', adminId: 'order-user', order: 0 },
          { id: 'mating-b', name: 'Mating B', apiaryType: 'trutowisko', adminId: 'order-user', order: 1 },
          { id: 'commercial-a', name: 'Commercial A', apiaryType: 'towarowe', adminId: 'order-user', order: 2 },
          { id: 'commercial-b', name: 'Commercial B', apiaryType: 'towarowe', adminId: 'order-user', order: 3 }
        ],
        hives: { 'commercial-a': hives, 'commercial-b': [ { id: 'hive-other', name: 'Other Apiary Hive', apiaryId: 'commercial-b', order: 0 } ] },
        uliki,
        notes: {},
        queenRearing: { breederQueens: [], starterColonies: [], finisherColonies: [], rearingBatches: [], sequences: {} }
      }));
    }, {
      hives: [hive('hive-a', 'Hive A', 'commercial-a', 0), hive('hive-b', 'Hive B', 'commercial-a', 1), hive('hive-c', 'Hive C', 'commercial-a', 2)],
      uliki: { 'mating-a': [
        ulik('ulik-a', 'Ulik A', 'mating-a', 'bezmatek', 0),
        ulik('ulik-hidden', 'Ulik Hidden', 'mating-a', 'pusty_ulik', 1),
        ulik('ulik-b', 'Ulik B', 'mating-a', 'bezmatek', 2)
      ], 'mating-b': [ulik('ulik-other', 'Ulik Other Apiary', 'mating-b', 'bezmatek', 0)] }
    });
    await page.reload();
    page.on('console', msg => console.log('PAGE:', msg.text()));
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'order-user', email: 'order@beelog.test' }));

    const dragCardTo = async (source, target, after) => {
      const box = await target.boundingBox();
      console.log('DRAGGING', await source.getAttribute('data-order-id'), 'TO', await target.getAttribute('data-order-id'), 'box:', box);
      await source.dragTo(target, {
        targetPosition: { x: box.width / 2, y: box.height * (after ? 0.8 : 0.2) },
        steps: 8
      });
    };
    const idsIn = async (selector, attr) => page.locator(selector).evaluateAll((nodes, attribute) => nodes.map(node => node.getAttribute(attribute)), attr);

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    const matingOrder = () => idsIn('[data-testid="apiary-card"]', 'data-apiary-id');
    await expect.poll(matingOrder).toEqual(['mating-a', 'mating-b']);
    await expect(page.locator('[data-testid="apiary-card"] button[title*="lewo"], [data-testid="apiary-card"] button[title*="prawo"]')).toHaveCount(0);
    await dragCardTo(page.locator('[data-testid="apiary-card"][data-apiary-id="mating-a"]'), page.locator('[data-testid="apiary-card"][data-apiary-id="mating-b"]'), true);
    await expect.poll(matingOrder).toEqual(['mating-b', 'mating-a']);
    await page.reload();
    page.on('console', msg => console.log('PAGE:', msg.text()));
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'order-user', email: 'order@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    await expect.poll(matingOrder).toEqual(['mating-b', 'mating-a']);

    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Pasieczyska towarowe' }).click();
    await page.getByText('Commercial A').click();
    const hiveOrder = () => idsIn('[data-testid="commercial-hive-card"]', 'data-hive-id');
    await expect.poll(hiveOrder).toEqual(['hive-a', 'hive-b', 'hive-c']);
    await expect(page.locator('[data-testid="commercial-hive-card"] button[title*="górę"], [data-testid="commercial-hive-card"] button[title*="dół"]')).toHaveCount(0);
    await dragCardTo(page.locator('[data-testid="commercial-hive-card"][data-hive-id="hive-a"]'), page.locator('[data-testid="commercial-hive-card"][data-hive-id="hive-b"]'), true);
    await expect.poll(hiveOrder).toEqual(['hive-b', 'hive-a', 'hive-c']);
    await dragCardTo(page.locator('[data-testid="commercial-hive-card"][data-hive-id="hive-a"]'), page.locator('[data-testid="commercial-hive-card"][data-hive-id="hive-c"]'), true);
    await expect.poll(hiveOrder).toEqual(['hive-b', 'hive-c', 'hive-a']);
    await expect.poll(() => page.evaluate(() => JSON.parse(localStorage.getItem('__E2E_STATE__')).hives['commercial-b'].map(item => item.id))).toEqual(['hive-other']);
    await expect(page.getByRole('heading', { name: 'Pasieka: Commercial A' })).toBeVisible();
    await page.reload();
    page.on('console', msg => console.log('PAGE:', msg.text()));
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'order-user', email: 'order@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Pasieczyska towarowe' }).click();
    await page.getByText('Commercial A').click();
    await expect.poll(hiveOrder).toEqual(['hive-b', 'hive-c', 'hive-a']);

    await page.getByRole('button', { name: '← Powrót' }).click();
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    await page.getByText('Mating A').click();
    await page.locator('select').selectOption('bezmatek');
    const visibleUlikOrder = () => idsIn('[data-testid="mating-hive-card"]', 'data-ulik-id');
    await expect.poll(visibleUlikOrder).toEqual(['ulik-a', 'ulik-b']);
    await expect(page.locator('[data-testid="mating-hive-card"] button[title="Przesuń w górę"], [data-testid="mating-hive-card"] button[title="Przesuń w dół"]')).toHaveCount(0);
    await dragCardTo(page.locator('[data-testid="mating-hive-card"][data-ulik-id="ulik-a"]'), page.locator('[data-testid="mating-hive-card"][data-ulik-id="ulik-b"]'), true);
    await expect.poll(visibleUlikOrder).toEqual(['ulik-b', 'ulik-a']);
    await expect.poll(() => page.evaluate(() => JSON.parse(localStorage.getItem('__E2E_STATE__')).uliki['mating-b'].map(item => item.id))).toEqual(['ulik-other']);
    await expect(page.getByRole('heading', { name: 'Trutowisko: Mating A' })).toBeVisible();
    await page.reload();
    page.on('console', msg => console.log('PAGE:', msg.text()));
    await page.evaluate(() => window.app.ports.authStateChanged.send({ uid: 'order-user', email: 'order@beelog.test' }));
    await page.getByTestId('main-menu-toggle').click();
    await page.getByRole('button', { name: 'Trutowiska' }).click();
    await page.getByText('Mating A').click();
    await expect.poll(() => idsIn('[data-testid="mating-hive-card"]', 'data-ulik-id')).toEqual(['ulik-b', 'ulik-hidden', 'ulik-a']);
    await expect(page.locator('[data-testid="mating-hive-card"][data-ulik-id="ulik-hidden"]')).toContainText('Ulik Hidden');
  });

});
