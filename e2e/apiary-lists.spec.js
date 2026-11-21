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
    await expect(page.getByTestId('google-signin-button')).toBeVisible();
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
