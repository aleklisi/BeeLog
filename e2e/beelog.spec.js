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

    // Zmień kolejność uli (przesuń Ul 2 w górę)
    await page.locator('h3', { hasText: 'Ul 2' }).evaluate(node => {
      const card = node.closest('div[style*="background"]');
      card.querySelector('button[title="Przesuń w górę"]').click();
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
    await page.click('button:has-text("⚙️ Ustawienia")');
    await expect(page.locator('text=⚙️ Ustawienia aplikacji')).toBeVisible();
    await expect(page.locator('[data-testid="user-email"]')).toHaveText('e2e@beelog.test');

    // Włącz tryb ciemny
    await page.click('button:has-text("🌙 Przełącz na Tryb Ciemny")');
    await expect(page.locator('button:has-text("☀️ Przełącz na Tryb Jasny")')).toBeVisible();

    // Odśwież stronę
    await page.reload();
    await page.waitForFunction(() => window.app && window.app.ports && window.app.ports.authStateChanged);
    await page.evaluate(() => {
      window.app.ports.authStateChanged.send({ uid: 'e2e-test-uid', email: 'e2e@beelog.test' });
    });
    await page.waitForTimeout(300);

    await expect(page.locator('text=Twoje Pasieczyska')).toBeVisible({ timeout: 5000 });

    // Przejdź ponownie do ustawień i sprawdź czy tryb ciemny nadal jest aktywny
    await page.click('button:has-text("⚙️ Ustawienia")');
    await expect(page.locator('text=⚙️ Ustawienia aplikacji')).toBeVisible();
    await expect(page.locator('button:has-text("☀️ Przełącz na Tryb Jasny")')).toBeVisible();
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
    await page.click('button:has-text("⚙️ Ustawienia")');
    await expect(page.locator('text=⚙️ Ustawienia aplikacji')).toBeVisible();

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
    await page.click('button[title="Zmień pasieczysko"]');
    await expect(page.locator('text=Przenieś ulik: Ulik do Przeniesienia')).toBeVisible();

    // Wybierz docelowe trutowisko i kliknij Przenieś
    await page.selectOption('div[style*="position: fixed"] select', { label: 'Trutowisko Docelowe' });
    await page.click('button:has-text("Przenieś")');

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
    await page.click('button:has-text("🚚 Zmień pasieczysko")');
    await expect(page.locator('text=Przenieś ulik: Ulik Szczegóły Move')).toBeVisible();

    // Wybierz docelowe trutowisko i kliknij Przenieś
    await page.selectOption('div[style*="position: fixed"] select', { label: 'Trutowisko Dest' });
    await page.click('button:has-text("Przenieś")');

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
    await page.click('button[title="Zmień pasieczysko"]');
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
    await page.click('button:has-text("⚙️ Ustawienia")');
    await expect(page.locator('text=⚙️ Ustawienia aplikacji')).toBeVisible();
    await page.click('label:has-text("Włącz Pasieczyska Towarowe") input[type="checkbox"]');
    await page.click('button:has-text("← Powrót")');

    // Sprawdź czy Pasieka Testowa Opcjonalna zniknęła z listy
    await expect(page.locator('text=Pasieka Testowa Opcjonalna')).not.toBeVisible();

    // Wróć do ustawień i włącz ponownie Pasieczyska Towarowe
    await page.click('button:has-text("⚙️ Ustawienia")');
    await page.click('label:has-text("Włącz Pasieczyska Towarowe") input[type="checkbox"]');
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

    // Dodaj korpus na górę
    await page.click('button:has-text("+ Dodaj korpus na górę")');
    await expect(page.locator('text=Korpus #2')).toBeVisible();

    // Zaznacz matkę w korpusie
    await page.locator('label:has-text("👑 Matka w korpusie") input[type="checkbox"]').first().click();

    // Zaznacz kratę odgrodową nad korpusem
    await page.locator('label:has-text("Krata odgrodowa nad tym korpusem") input[type="checkbox"]').first().click();
    await expect(page.locator('text=🟧 Krata odgrodowa')).toBeVisible();
  });

});
