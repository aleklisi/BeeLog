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

    await expect(page.locator('text=Edytor Korpusów')).toBeVisible();
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

    // Przy aktualnym zachowaniu ula upuszczenie pod korpusem z matką nie zmienia kolejności.
    await dragKorpusTo('[data-korpus-id="1"]', '[data-korpus-id="3"] [data-korpus-drop$="|after"]');
    await expect.poll(korpusOrder).toEqual(['2', '5', '1', '3']);
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

test('commercial hive notes accept recognized speech text', async ({ page }) => {
  await page.addInitScript(() => {
    window.__E2E__ = true;
    localStorage.setItem('beelog_language', 'pl');
  });
  await page.goto('/');
  const consentButton = page.getByTestId('consent-necessary');
  if (await consentButton.isVisible()) await consentButton.click();
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
