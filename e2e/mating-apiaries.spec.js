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
    await expect(page.getByTestId('mating-hive-current-status')).toHaveCSS('background-color', 'rgb(231, 76, 60)');
    await page.click('text=➕ Poddano matecznik (M)');
    await page.click('button:has-text("Zapisz")');
    await expect(page.locator('text=Aktualny stan: (M) Matecznik')).toBeVisible();
    await expect(page.getByTestId('mating-hive-current-status')).toHaveCSS('background-color', 'rgb(247, 220, 111)');
    await expect(page.locator('text=(B) - Poddano Matecznik -> (M)')).toBeVisible();

    await page.click('text=🦋 Matka się wygryzła (N)');
    await expect(page.locator('text=Aktualny stan: (N) Matka nieunasienniona')).toBeVisible();
    await expect(page.getByTestId('mating-hive-current-status')).toHaveCSS('background-color', 'rgb(212, 172, 13)');
    await expect(page.locator('text=(M) - Matka się wygryzła -> (N)')).toBeVisible();

    await page.click('text=👑 Matka się unasienniła (UNC)');
    await expect(page.locator('text=Aktualny stan: (UNC) Matka unasienniona')).toBeVisible();
    await expect(page.getByTestId('mating-hive-current-status')).toHaveCSS('background-color', 'rgb(39, 174, 96)');
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
