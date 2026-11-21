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
    const breederSection = page.getByTestId('qr-resource-section-breederQueens');
    await page.getByTestId('qr-input-breedLine').selectOption('car. Galicja');
    await page.getByTestId('qr-input-markingColor').selectOption('blue');
    await breederSection.getByTestId('qr-input-breederQueens-markingCode').fill('17');
    await breederSection.getByTestId('qr-input-breederQueens-hiveNumber').fill('1');
    await page.getByTestId('qr-resource-save-breederQueens').click();
    await expect(page.getByText('1 · car. Galicja · 🔵 Niebieski 17')).toBeVisible();

    await page.getByTestId('qr-resource-toggle-starterColonies').click();
    const starterSection = page.getByTestId('qr-resource-section-starterColonies');
    await starterSection.getByTestId('qr-input-starterColonies-hiveNumber').fill('2');
    await starterSection.getByTestId('qr-resource-save-starterColonies').click();
    await expect(page.getByText('2', { exact: true })).toBeVisible();

    await page.getByTestId('qr-resource-toggle-finisherColonies').click();
    const finisherSection = page.getByTestId('qr-resource-section-finisherColonies');
    await finisherSection.getByTestId('qr-input-finisherColonies-hiveNumber').fill('3');
    await finisherSection.getByTestId('qr-resource-save-finisherColonies').click();
    await expect(page.getByText('3', { exact: true })).toBeVisible();

    await page.getByRole('button', { name: '← Hodowla matek' }).click();

    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const batch = page.locator('[data-testid^="qr-batch-"]').first();
    await expect(batch).toContainText('1 · Zaplanowana');
    await expect(batch).toContainText('Data przełożenia larw:');
    await expect(batch).toContainText('Planowane wygryzienie:');
    await expect(batch.locator('select')).toHaveCount(0);
    await batch.click();
    await batch.locator('select[data-testid^="qr-breeder-"]').selectOption({ label: '1 · car. Galicja' });
    await expect(batch.locator('select[data-testid^="qr-starter-"]')).toBeVisible();
    await batch.locator('select[data-testid^="qr-starter-"]').selectOption({ label: '2' });
    await page.getByTestId('qr-input-graftCount').fill('24');
    await batch.getByTestId('qr-input-graftedAt').fill('2026-05-10');
    await batch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await expect(batch).toContainText('W starterze');
    await expect(batch).toContainText('Przeniesienie do startera: 2026-05-11');

    await page.getByTestId('qr-input-count').fill('10.5');
    await page.getByTestId('qr-finisher-select').selectOption({ label: '3' });
    await batch.getByRole('button', { name: 'Przenieś do finishera' }).click();
    await expect(batch).toContainText('W starterze');
    await expect(page.getByText('Podaj całkowitą liczbę dla tego etapu.')).toBeVisible();
    await page.getByText('✕').click();
    await page.getByTestId('qr-input-count').fill('25');
    await batch.getByRole('button', { name: 'Przenieś do finishera' }).click();
    await expect(batch).toContainText('W starterze');
    await expect(page.getByText('Liczba przyjętych mateczników musi wynosić od 1 do liczby przełożonych larw.')).toBeVisible();
    await page.getByText('✕').click();

    await page.getByTestId('qr-input-count').fill('20');
    await batch.getByRole('button', { name: 'Przenieś do finishera' }).click();
    await expect(batch).toContainText('W finisherze');
    await page.getByTestId('qr-input-count').fill('5');
    await batch.getByRole('button', { name: 'Zakończ bezpośrednio' }).click();
    await expect(batch).toContainText('Zakończona');
    await expect(batch).toContainText('Wygryzione: 5');
    await page.getByRole('button', { name: 'Zasoby' }).click();
    await expect(page.getByText('2', { exact: true })).toBeVisible();
    await expect(page.getByText('3', { exact: true })).toBeVisible();
    await page.getByRole('button', { name: '← Hodowla matek' }).click();

    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const plannedBatches = () => page.locator('[data-testid^="qr-batch-"]').filter({ hasText: 'Zaplanowana' });
    const zeroBatchId = await plannedBatches().first().getAttribute('data-testid');
    const zeroBatch = page.getByTestId(zeroBatchId);
    await expect(zeroBatch).toContainText('Zaplanowana');
    await zeroBatch.click();
    await zeroBatch.locator('select[data-testid^="qr-breeder-"]').selectOption({ label: '1 · car. Galicja' });
    await zeroBatch.locator('select[data-testid^="qr-starter-"]').selectOption({ label: '2' });
    await page.getByTestId('qr-input-graftCount').fill('24');
    await page.getByTestId('qr-input-graftedAt').fill('2026-05-11');
    await zeroBatch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await expect(zeroBatch).toContainText('W starterze');
    await page.getByTestId('qr-input-count').fill('0');
    await zeroBatch.getByRole('button', { name: 'Zakończ bez przyjętych mateczników' }).click();
    await expect(zeroBatch).toContainText('Zakończona');
    await page.getByRole('button', { name: '← Lista serii' }).click();

    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const incubatorBatchId = await plannedBatches().first().getAttribute('data-testid');
    const incubatorBatch = page.getByTestId(incubatorBatchId);
    await incubatorBatch.click();
    await incubatorBatch.locator('select[data-testid^="qr-breeder-"]').selectOption({ label: '1 · car. Galicja' });
    await incubatorBatch.locator('select[data-testid^="qr-starter-"]').selectOption({ label: '2' });
    await page.getByTestId('qr-input-graftCount').fill('24');
    await page.getByTestId('qr-input-graftedAt').fill('2026-05-12');
    await incubatorBatch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await page.getByTestId('qr-input-count').fill('10');
    await page.getByTestId('qr-finisher-select').selectOption({ label: '3' });
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

test('queen-rearing batches sort by series number and show urgency', async ({ page }) => {
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
          breederQueens: [{ id: 'queen', breed: 'Carniolan', line: 'Galicja', hiveNumber: 1, active: true }],
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
    await expect(rows.nth(0)).toHaveAttribute('data-testid', 'qr-batch-completed');
    await expect(rows.nth(1)).toHaveAttribute('data-testid', 'qr-batch-planned');
    await expect(rows.nth(2)).toHaveAttribute('data-testid', 'qr-batch-future');
    await expect(rows.nth(3)).toHaveAttribute('data-testid', 'qr-batch-soon');
    await expect(rows.nth(4)).toHaveAttribute('data-testid', 'qr-batch-overdue');
    const overdue = page.getByTestId('qr-batch-overdue');
    await expect(overdue.locator('select')).toHaveCount(0);
    await overdue.click();
    await expect(page.getByTestId('qr-next-action-overdue')).toContainText('Opóźnienie:');
    await expect(page.getByTestId('qr-next-action-overdue')).toContainText('2 h');
    await expect(page.getByTestId('qr-next-action-overdue')).toHaveCSS('background-color', 'rgb(231, 76, 60)');
    await page.getByRole('button', { name: '← Lista serii' }).click();
    await page.getByTestId('qr-batch-soon').click();
    await expect(page.getByTestId('qr-next-action-soon')).toContainText('Termin za 2 h');
    await expect(page.getByTestId('qr-next-action-soon')).toHaveCSS('background-color', 'rgb(241, 196, 15)');
    await page.getByRole('button', { name: '← Lista serii' }).click();
    await page.getByTestId('qr-batch-future').click();
    await expect(page.getByTestId('qr-next-action-future')).toContainText('Termin za 3 d');
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
    const breederSection = page.getByTestId('qr-resource-section-breederQueens');
    await page.getByTestId('qr-input-breedLine').selectOption('car. Galicja');
    await breederSection.getByTestId('qr-input-breederQueens-hiveNumber').fill('7');
    await page.getByTestId('qr-resource-save-breederQueens').click();
    let queenRow = page.locator('[data-testid^="qr-resource-qr-"]').filter({ hasText: '7' });
    const queenId = await queenRow.getAttribute('data-testid').then(id => id.replace('qr-resource-', ''));
    await queenRow.getByTestId(`qr-resource-open-${queenId}`).click();
    await page.getByTestId('qr-resource-edit').click();
    await page.getByTestId('qr-input-breedLine').selectOption('cau. M');
    await page.getByTestId('qr-resource-save-breederQueens').click();
    await expect(page.getByTestId('qr-breeder-queen-detail')).toContainText('cau. M');
    await page.getByRole('button', { name: /Zasoby/ }).click();

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
    await starterSection.getByTestId('qr-input-starterColonies-hiveNumber').fill('7');
    await starterSection.getByTestId('qr-resource-save-starterColonies').click();
    const starterRow = starterSection.locator('[data-testid^="qr-resource-qr-"]').filter({ hasText: '7' });
    const starterId = await starterRow.getAttribute('data-testid').then(id => id.replace('qr-resource-', ''));

    await page.getByRole('button', { name: '← Hodowla matek' }).click();
    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const batch = page.locator('[data-testid^="qr-batch-"]').nth(0);
    const batchTestId = await batch.getAttribute('data-testid');
    await batch.click();
    await batch.locator('select[data-testid^="qr-breeder-"]').selectOption(queenId);
    await batch.locator('select[data-testid^="qr-starter-"]').selectOption(starterId);
    await page.getByRole('button', { name: '← Lista serii' }).click();
    await page.getByRole('button', { name: 'Utwórz zaplanowaną serię' }).click();
    const batchCards = page.locator('[data-testid^="qr-batch-"]');
    await expect(batchCards).toHaveCount(2);
    const conflictingBatchTestId = await batchCards.evaluateAll((cards, existingId) => cards.map(card => card.getAttribute('data-testid')).find(id => id !== existingId), batchTestId);
    const conflictingBatch = page.getByTestId(conflictingBatchTestId);
    await conflictingBatch.click();
    await conflictingBatch.locator('select[data-testid^="qr-breeder-"]').selectOption(queenId);
    await conflictingBatch.locator('select[data-testid^="qr-starter-"]').selectOption(starterId);
    await page.getByRole('button', { name: '← Lista serii' }).click();
    await page.getByTestId(batchTestId).click();
    await page.getByTestId('qr-input-graftCount').fill('24');
    await batch.getByTestId('qr-input-graftedAt').fill('2026-05-10');
    await batch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await expect(batch).toContainText('W starterze');
    await page.getByRole('button', { name: '← Lista serii' }).click();
    await page.getByTestId(conflictingBatchTestId).click();
    await page.getByTestId('qr-input-graftCount').fill('24');
    await conflictingBatch.getByTestId('qr-input-graftedAt').fill('2026-05-11');
    await conflictingBatch.getByRole('button', { name: 'Rozpocznij serię' }).click();
    await expect(conflictingBatch).toContainText('Zaplanowana');
    await expect(page.getByText('Wybrany starter jest już zarezerwowany.')).toBeVisible();

    await page.getByRole('button', { name: 'Zasoby' }).click();
    queenRow = page.locator(`[data-testid="qr-resource-${queenId}"]`);
    await queenRow.getByRole('button', { name: 'Usuń' }).click();
    await expect(page.getByText('Nie można usunąć matki reprodukcyjnej powiązanej z serią. Zamiast tego ją wycofaj.')).toBeVisible();
    await expect(queenRow).toBeVisible();
    await starterRow.getByRole('button', { name: 'Usuń' }).click();
    await expect(page.getByText('Ten ulik jest zarezerwowany przez aktywną serię.')).toBeVisible();
    await expect(starterRow).toBeVisible();

    await page.getByRole('button', { name: '← Hodowla matek' }).click();
    await page.getByTestId(batchTestId).click();
    await page.getByTestId(batchTestId).getByTitle('Usuń serię').click();
    await expect(page.getByTestId(batchTestId)).toHaveCount(0);
    // Deleting a batch navigates back to the batch list automatically.
    await expect(page.getByRole('button', { name: 'Utwórz zaplanowaną serię' })).toBeVisible();
    await page.getByTestId(conflictingBatchTestId).click();
    await page.getByTestId(conflictingBatchTestId).getByTitle('Usuń serię').click();
    await expect(page.getByTestId(conflictingBatchTestId)).toHaveCount(0);
    await expect(page.getByRole('button', { name: 'Utwórz zaplanowaną serię' })).toBeVisible();
    await page.getByRole('button', { name: 'Zasoby' }).click();
    const releasedStarter = page.locator(`[data-testid="qr-resource-${starterId}"]`);
    const releasedQueen = page.locator(`[data-testid="qr-resource-${queenId}"]`);
    await expect(releasedStarter).toBeVisible();
    await releasedStarter.getByRole('button', { name: 'Usuń' }).click();
    await expect(releasedStarter).toHaveCount(0);
    await releasedQueen.getByRole('button', { name: 'Usuń' }).click();
    await expect(releasedQueen).toHaveCount(0);
  });
