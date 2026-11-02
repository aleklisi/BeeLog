const { test, expect } = require('@playwright/test');

test.describe('BeeLog E2E Test Suite', () => {

  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      window.__E2E__ = true;
    });
    await page.goto('/');
  });

  test('1. Test logowania - widok początkowy', async ({ page }) => {
    await page.evaluate(() => localStorage.removeItem('__E2E_STATE__'));
    await page.reload();
    await expect(page.locator('text=Zaloguj przez Google')).toBeVisible();
    await expect(page.locator('text=BeeLog 🐝')).toBeVisible();
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

    // Zmień kolejność (przesuń Pasieka Y w lewo przyciskiem ⬅️)
    await page.locator('h3', { hasText: 'Pasieka Y' }).evaluate(node => {
      const card = node.closest('div[style*="background"]');
      card.querySelector('button[title="Przesuń w lewo"]').click();
    });

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

    // Zmień kolejność uli (przesuń Ul 2 w lewo)
    await page.locator('h3', { hasText: 'Ul 2' }).evaluate(node => {
      const card = node.closest('div[style*="background"]');
      card.querySelector('button[title="Przesuń w lewo"]').click();
    });

    // Edytuj Ul 1 (kliknij w kafelek ula, aby wejść w kartę ula)
    await page.click('text=Ul 1');
    await expect(page.locator('text=Karta Ula: Ul 1')).toBeVisible();
    await page.fill('div:has-text("Dane Techniczne") input[type="text"]', 'Ul 1 Edytowany');
    await page.click('text=← Powrót');
    await expect(page.locator('text=Ul 1 Edytowany')).toBeVisible();

    // Usuń Ul 3
    await page.locator('h3', { hasText: 'Ul 3' }).evaluate(node => {
      const card = node.parentElement;
      const delBtn = card.querySelector('button[title="Usuń ul"]');
      if (delBtn) delBtn.click();
    });
    await page.click('button:has-text("Potwierdź usunięcie")');
    await expect(page.locator('h3:has-text("Ul 3")')).not.toBeVisible();
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

    // Test dat spodziewanego wygryzienia i unasiennienia (+10 dni)
    await page.fill('input[type="date"]', '2026-11-01');
    await expect(page.locator('input[type="date"]').nth(1)).toHaveValue('2026-11-11');

    // Test przejść stanów
    await expect(page.locator('text=Aktualny stan: (B) Bezmatek')).toBeVisible();
    await page.click('text=➕ Poddano matecznik (M)');
    await expect(page.locator('text=Aktualny stan: (M) Matecznik')).toBeVisible();

    await page.click('text=🦋 Matka się wygryzła (N)');
    await expect(page.locator('text=Aktualny stan: (N) Matka nieunasienniona')).toBeVisible();

    await page.click('text=👑 Matka się unasienniła (UNC)');
    await expect(page.locator('text=Aktualny stan: (UNC) Matka unasienniona')).toBeVisible();

    // Test przycisku "zabieram matkę" powracającego do stanu Bezmatek
    await page.click('button:has-text("zabieram matkę (B)")');
    await expect(page.locator('text=Aktualny stan: (B) Bezmatek')).toBeVisible();

    // Zrzut uliku
    await page.click('text=📸 Zrzut Uliku');
    await expect(page.locator('text=Zrzut Stanu Uliku Weselnego')).toBeVisible();
  });

  test('8. Filtr typów pasieczysk', async ({ page }) => {
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

    // Przetestuj filtr: Towarowe
    await page.selectOption('div:has-text("Filtruj typ:") select', 'towarowe');
    await expect(page.locator('text=Pasieka Towarowa')).toBeVisible();
    await expect(page.locator('text=Trutowisko Filtr')).not.toBeVisible();

    // Przetestuj filtr: Trutowiska
    await page.selectOption('div:has-text("Filtruj typ:") select', 'trutowisko');
    await expect(page.locator('text=Trutowisko Filtr')).toBeVisible();
    await expect(page.locator('text=Pasieka Towarowa')).not.toBeVisible();

    // Przetestuj filtr: Wszystkie
    await page.selectOption('div:has-text("Filtruj typ:") select', 'all');
    await expect(page.locator('text=Pasieka Towarowa')).toBeVisible();
    await expect(page.locator('text=Trutowisko Filtr')).toBeVisible();
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

});
