import { Elm } from './Main.elm';
import './styles.css';
import { auth, db, googleProvider, signInWithPopup, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut, deleteUser, collection, doc, getDoc, setDoc, addDoc, updateDoc, deleteDoc, query, where, getDocs, onSnapshot, runTransaction, Timestamp } from '../../src/firebase.js';
import { onAuthStateChanged } from 'firebase/auth';

function getE2EState() {
    let state = { apiaries: [], hives: {}, notes: {}, queenRearing: { breederQueens: [], starterColonies: [], finisherColonies: [], rearingBatches: [], sequences: {} } };
    if (window.__E2E__) {
        const saved = localStorage.getItem('__E2E_STATE__');
        if (saved) {
            try {
                state = JSON.parse(saved);
                state.queenRearing = { breederQueens: [], starterColonies: [], finisherColonies: [], rearingBatches: [], sequences: {}, ...(state.queenRearing || {}) };
            } catch (e) {}
        }
    }
    return state;
}

function saveE2EState(state) {
    if (window.__E2E__) {
        localStorage.setItem('__E2E_STATE__', JSON.stringify(state));
    }
}

const savedDarkMode = localStorage.getItem('beelog_darkMode') === 'true';
const savedLanguage = localStorage.getItem('beelog_language') === 'en' ? 'en' : 'pl';

function applyDarkMode(enabled) {
    document.documentElement.classList.toggle('dark', Boolean(enabled));
}

applyDarkMode(savedDarkMode);

let savedConsent = null;
try {
    const rawConsent = localStorage.getItem('beelog_consent');
    if (rawConsent) savedConsent = JSON.parse(rawConsent);
} catch (e) {}
const consentDecided = savedConsent !== null && typeof savedConsent === 'object';
const consentAnalytics = savedConsent ? Boolean(savedConsent.analytics) : false;

const initialHash = window.location.hash || "";
const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: {
        darkMode: savedDarkMode,
        language: savedLanguage,
        initialHash: initialHash,
        consentDecided: consentDecided,
        consentAnalytics: consentAnalytics
    }
});
window.app = app;

if (app.ports && app.ports.jsSaveConsent) {
    app.ports.jsSaveConsent.subscribe(consent => {
        localStorage.setItem('beelog_consent', JSON.stringify({
            necessary: true,
            analytics: Boolean(consent.analytics),
            decidedAt: new Date().toISOString()
        }));
    });
}

let activeOrderDrag = null;
let activeOrderTarget = null;
let activeOrderList = null;
const orderCardFromTarget = target => target?.closest?.('[data-order-collection][data-order-id]');
const orderDropTarget = (card, clientY) => {
    const bounds = card.getBoundingClientRect();
    const cards = [...card.parentElement.children].filter(child => child.matches?.('[data-order-collection][data-order-id]'));
    return {
        targetId: card.dataset.orderId,
        after: cards[cards.length - 1] === card || clientY >= bounds.top + bounds.height / 2
    };
};
document.addEventListener('dragstart', event => {
    const card = orderCardFromTarget(event.target);
    if (!card) return;
    activeOrderDrag = {
        collection: card.dataset.orderCollection,
        apiaryId: card.dataset.orderApiaryId || '',
        draggedId: card.dataset.orderId
    };
    activeOrderTarget = null;
    activeOrderList = card.parentElement;
    if (event.dataTransfer) {
        event.dataTransfer.effectAllowed = 'move';
        event.dataTransfer.setData('text/plain', activeOrderDrag.draggedId);
    }
}, true);
document.addEventListener('dragover', event => {
    const hit = document.elementFromPoint(event.clientX, event.clientY);
    let card = orderCardFromTarget(hit) || orderCardFromTarget(event.target);
    if (!card && activeOrderList) {
        const bounds = activeOrderList.getBoundingClientRect();
        const cards = [...activeOrderList.children].filter(child => child.matches?.('[data-order-collection][data-order-id]'));
        if (cards.length && event.clientX >= bounds.left && event.clientX <= bounds.right && event.clientY >= bounds.top && event.clientY <= bounds.bottom) {
            card = cards[cards.length - 1];
            activeOrderTarget = { targetId: card.dataset.orderId, after: true };
            event.preventDefault();
            return;
        }
    }
    if (!card) return;
    event.preventDefault();
    activeOrderTarget = orderDropTarget(card, event.clientY);
}, true);
document.addEventListener('drop', event => {
    let card = orderCardFromTarget(document.elementFromPoint(event.clientX, event.clientY)) || orderCardFromTarget(event.target);
    if (!activeOrderDrag || !app.ports.orderDropReceived) return;
    if (!card && activeOrderList) {
        const bounds = activeOrderList.getBoundingClientRect();
        const cards = [...activeOrderList.children].filter(child => child.matches?.('[data-order-collection][data-order-id]'));
        if (cards.length && event.clientX >= bounds.left && event.clientX <= bounds.right && event.clientY >= bounds.top && event.clientY <= bounds.bottom) {
            card = cards[cards.length - 1];
            activeOrderTarget = { targetId: card.dataset.orderId, after: true };
        }
    }
    const target = card ? orderDropTarget(card, event.clientY) : activeOrderTarget;
    if (!target) return;
    event.preventDefault();
    app.ports.orderDropReceived.send({
        ...activeOrderDrag,
        ...target
    });
}, true);
document.addEventListener('dragend', () => {
    activeOrderDrag = null;
    activeOrderTarget = null;
    activeOrderList = null;
}, true);

// Touch browsers implicitly capture pointers on the pressed element. Resolve
// the actual drop target from the pointer coordinates instead of the event target.
let activeKorpusDrag = null;
document.addEventListener('pointerdown', (event) => {
    const handle = event.target.closest?.('[data-korpus-drag-handle]');
    if (handle) activeKorpusDrag = { id: handle.dataset.korpusDragHandle, pointerId: event.pointerId };
});
document.addEventListener('pointerup', (event) => {
    if (!activeKorpusDrag || activeKorpusDrag.pointerId !== event.pointerId) return;
    activeKorpusDrag = null;
    const hit = document.elementFromPoint(event.clientX, event.clientY);
    const zone = hit?.closest('[data-korpus-drop]');
    const card = hit?.closest('[data-korpus-card]');
    if (!zone && !card) {
        app.ports.korpusDropReceived.send({});
        return;
    }
    let apiaryId;
    let hiveId;
    let korpusId;
    let after;
    if (zone) {
        [apiaryId, hiveId, korpusId] = zone.dataset.korpusDrop.split('|');
        after = zone.dataset.korpusDrop.endsWith('|after');
    } else {
        [apiaryId, hiveId, korpusId] = card.dataset.korpusCard.split('|');
        after = event.clientY > card.getBoundingClientRect().top + card.getBoundingClientRect().height / 2;
    }
    app.ports.korpusDropReceived.send({ apiaryId, hiveId, korpusId, after });
});
document.addEventListener('pointercancel', () => {
    if (activeKorpusDrag) app.ports.korpusDropReceived.send({});
    activeKorpusDrag = null;
});

function sendQueenRearingState(data) {
    if (app.ports.queenRearingReceived) {
        const rearingBatches = (data.rearingBatches || []).map(batch => ({ ...batch, deadlineEpoch: computeBatchDeadline(batch) }));
        app.ports.queenRearingReceived.send({ ...data, rearingBatches });
    }
}

function localDateTimeToDate(localDateTime, timeZone) {
    const match = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/.exec(localDateTime || '');
    if (!match) throw new Error('Enter a valid local graft date and time.');
    const [, year, month, day, hour, minute] = match.map(Number);
    const wanted = Date.UTC(year, month - 1, day, hour, minute);
    let result = wanted;
    for (let i = 0; i < 4; i += 1) {
        const parts = new Intl.DateTimeFormat('en-CA', { timeZone, year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).formatToParts(new Date(result));
        const values = Object.fromEntries(parts.map(part => [part.type, part.value]));
        const represented = Date.UTC(Number(values.year), Number(values.month) - 1, Number(values.day), Number(values.hour), Number(values.minute));
        const adjustment = wanted - represented;
        result += adjustment;
        if (adjustment === 0) break;
    }
    return new Date(result);
}

function dateToLocalDateTime(date, timeZone) {
    const parts = new Intl.DateTimeFormat('en-CA', { timeZone: timeZone || 'UTC', year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hourCycle: 'h23' }).formatToParts(date);
    const values = Object.fromEntries(parts.map(part => [part.type, part.value]));
    return `${values.year}-${values.month}-${values.day}T${values.hour}:${values.minute}`;
}

function normalizeRearingBatch(batch) {
    const zone = batch.timeZone || 'UTC';
    const normalized = { ...batch };
    for (const key of ['graftedAt', 'starterTransferAt', 'isolationAt', 'emergenceAt']) {
        if (normalized[key] && typeof normalized[key].toDate === 'function') normalized[key] = dateToLocalDateTime(normalized[key].toDate(), zone);
    }
    return normalized;
}

function computeBatchDeadline(batch) {
    const field = batch.status === 'W_STARTERZE' ? 'starterTransferAt' : batch.status === 'W_FINISHERZE' ? 'isolationAt' : batch.status === 'W_CIEPLARCE' ? 'emergenceAt' : null;
    if (!field || !batch[field]) return null;
    const date = typeof batch[field].toDate === 'function'
        ? batch[field].toDate()
        : localDateTimeToDate(batch[field], batch.timeZone || 'UTC');
    return Number.isFinite(date.getTime()) ? date.getTime() : null;
}

const todayStr = new Date().toISOString().split('T')[0];
if (app.ports.todayReceived) {
    app.ports.todayReceived.send(todayStr);
}
if (app.ports.currentEpochReceived) {
    app.ports.currentEpochReceived.send(Date.now());
    window.setInterval(() => app.ports.currentEpochReceived.send(Date.now()), 60000);
}

// Auth state observer
onAuthStateChanged(auth, (user) => {
    if (window.__E2E__) return;
    if (user) {
        app.ports.authStateChanged.send({
            uid: user.uid,
            email: user.email || ""
        });
    } else {
        app.ports.authStateChanged.send({
            uid: "",
            email: ""
        });
    }
});

// Outgoing port handlers from Elm
app.ports.jsLoginGoogle.subscribe(async () => {
    try {
        await signInWithPopup(auth, googleProvider);
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsLogout.subscribe(async () => {
    try {
        await signOut(auth);
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteAccount.subscribe(async (confirmation) => {
    try {
        if (confirmation !== 'Tak, usuwam konto!') {
            throw Object.assign(new Error('Invalid confirmation phrase.'), { code: 'invalid-confirmation' });
        }
        const user = auth.currentUser;
        if (!user) throw new Error('No authenticated user.');

        const removeCollection = async (collectionRef) => {
            const snapshot = await getDocs(collectionRef);
            await Promise.all(snapshot.docs.map((item) => deleteDoc(item.ref)));
        };

        const uid = user.uid;
        const apiaries = await getDocs(query(collection(db, 'pasieczyska'), where('adminId', '==', uid)));
        for (const apiary of apiaries.docs) {
            const hives = await getDocs(query(collection(db, 'hives'), where('apiaryId', '==', apiary.id)));
            for (const hive of hives.docs) {
                await removeCollection(collection(db, 'hives', hive.id, 'notes'));
                await deleteDoc(hive.ref);
            }
            await deleteDoc(apiary.ref);
        }

        for (const name of ['breederQueens', 'starterColonies', 'finisherColonies', 'rearingBatches', 'rearingSequences']) {
            await removeCollection(collection(db, 'users', uid, name));
        }
        await deleteDoc(doc(db, 'users', uid));
        await deleteUser(user);
        app.ports.accountDeletionResult.send({ success: true, error: '' });
    } catch (error) {
        const isEnglish = localStorage.getItem('beelog_language') === 'en';
        const message = error.code === 'invalid-confirmation'
            ? (isEnglish ? 'The confirmation phrase is incorrect.' : 'Wpisana fraza jest nieprawidłowa.')
            : (error.code === 'auth/requires-recent-login'
                ? (isEnglish ? 'Please sign in again, then retry account deletion.' : 'Zaloguj się ponownie, a następnie spróbuj usunąć konto jeszcze raz.')
                : (isEnglish ? 'Account deletion failed. You can retry.' : 'Nie udało się usunąć konta. Możesz spróbować ponownie.'));
        app.ports.accountDeletionResult.send({ success: false, error: message });
    }
});

app.ports.jsLoadUserSettings.subscribe(async ({ uid, email }) => {
    let currentDarkMode = localStorage.getItem('beelog_darkMode') === 'true';
    let currentLanguage = localStorage.getItem('beelog_language') === 'en' ? 'en' : 'pl';
    const defaultFrameTypes = ["Wielkopolska", "Wielkopolska 18", "Wielkopolska 1/2", "Warszawska zwykła", "MiniPlus", "Dadant"];
    const defaultUlikTypes = ["Mini plus", "Odkład wielkopolski", "Apidea"];
    const defaultBreedLines = ["car. Galicja", "cau. M", "cau. KP", "cau. Woźnica", "car. Słowenka"];
    const defaultHatchingToMatingDays = 12;
    const defaultMaxUlikHistoryLimit = 40;
    const defaultEnableTrutowiska = true;
    const defaultEnablePasieczyskaTowarowe = true;
    const defaultEnableQueenRearing = false;
    const defaultGraftCount = 24;
    const defaultStarterDurationDays = 2;
    const defaultIsolationDay = 10;
    const defaultEmergenceDay = 11;
    if (window.__E2E__) {
        const state = getE2EState();
        const settings = state.userSettings || {
            frameTypes: defaultFrameTypes,
            ulikTypes: defaultUlikTypes,
            breedLines: defaultBreedLines,
            darkMode: currentDarkMode,
            language: currentLanguage,
            hatchingToMatingDays: defaultHatchingToMatingDays,
            maxUlikHistoryLimit: defaultMaxUlikHistoryLimit,
            enableTrutowiska: defaultEnableTrutowiska,
            enablePasieczyskaTowarowe: defaultEnablePasieczyskaTowarowe
            , enableQueenRearing: defaultEnableQueenRearing
            , defaultGraftCount, starterDurationDays: defaultStarterDurationDays
            , isolationDay: defaultIsolationDay, emergenceDay: defaultEmergenceDay
        };
        localStorage.setItem('beelog_darkMode', settings.darkMode ? 'true' : 'false');
        applyDarkMode(settings.darkMode);
        localStorage.setItem('beelog_language', settings.language === 'en' ? 'en' : 'pl');
        app.ports.userSettingsReceived.send(settings);
        return;
    }
    try {
        const docRef = doc(db, "users", uid);
        const docSnap = await getDoc(docRef);
        let frameTypesVal = defaultFrameTypes;
        let ulikTypesVal = defaultUlikTypes;
        let breedLinesVal = defaultBreedLines;
        let hatchingToMatingDaysVal = defaultHatchingToMatingDays;
        let maxUlikHistoryLimitVal = defaultMaxUlikHistoryLimit;
        let enableTrutowiskaVal = defaultEnableTrutowiska;
        let enablePasieczyskaTowaroweVal = defaultEnablePasieczyskaTowarowe;
        let enableQueenRearingVal = defaultEnableQueenRearing;
        let defaultGraftCountVal = defaultGraftCount;
        let starterDurationDaysVal = defaultStarterDurationDays;
        let isolationDayVal = defaultIsolationDay;
        let emergenceDayVal = defaultEmergenceDay;
        let languageVal = currentLanguage;
        const emailToSave = email || (auth.currentUser ? auth.currentUser.email : "");
        if (docSnap.exists()) {
            const data = docSnap.data();
            if (data.frameTypes) frameTypesVal = data.frameTypes;
            if (data.ulikTypes) ulikTypesVal = data.ulikTypes;
            if (data.breedLines) breedLinesVal = data.breedLines;
            if (data.hatchingToMatingDays !== undefined) hatchingToMatingDaysVal = data.hatchingToMatingDays;
            if (data.maxUlikHistoryLimit !== undefined) maxUlikHistoryLimitVal = data.maxUlikHistoryLimit;
            if (data.enableTrutowiska !== undefined) enableTrutowiskaVal = data.enableTrutowiska;
            if (data.enablePasieczyskaTowarowe !== undefined) enablePasieczyskaTowaroweVal = data.enablePasieczyskaTowarowe;
            if (data.enableQueenRearing !== undefined) enableQueenRearingVal = data.enableQueenRearing;
            if (data.defaultGraftCount !== undefined) defaultGraftCountVal = data.defaultGraftCount;
            if (data.starterDurationDays !== undefined) starterDurationDaysVal = data.starterDurationDays;
            if (data.isolationDay !== undefined) isolationDayVal = data.isolationDay;
            if (data.emergenceDay !== undefined) emergenceDayVal = data.emergenceDay;
            if (data.language === 'en' || data.language === 'pl') languageVal = data.language;
            const missingQueenDefaults = {};
            if (data.enableQueenRearing === undefined) missingQueenDefaults.enableQueenRearing = defaultEnableQueenRearing;
            if (data.defaultGraftCount === undefined) missingQueenDefaults.defaultGraftCount = defaultGraftCount;
            if (data.starterDurationDays === undefined) missingQueenDefaults.starterDurationDays = defaultStarterDurationDays;
            if (data.isolationDay === undefined) missingQueenDefaults.isolationDay = defaultIsolationDay;
            if (data.emergenceDay === undefined) missingQueenDefaults.emergenceDay = defaultEmergenceDay;
            if (Object.keys(missingQueenDefaults).length) await setDoc(docRef, missingQueenDefaults, { merge: true });
            if (data.language === undefined) await setDoc(docRef, { language: languageVal }, { merge: true });
            if (data.darkMode !== undefined) {
                currentDarkMode = data.darkMode;
            } else {
                await setDoc(docRef, { darkMode: currentDarkMode, email: emailToSave }, { merge: true });
            }
            if (emailToSave && data.email !== emailToSave) {
                await setDoc(docRef, { email: emailToSave }, { merge: true });
            }
        } else {
            await setDoc(docRef, { email: emailToSave, frameTypes: frameTypesVal, ulikTypes: ulikTypesVal, breedLines: breedLinesVal, darkMode: currentDarkMode, language: languageVal, hatchingToMatingDays: hatchingToMatingDaysVal, maxUlikHistoryLimit: maxUlikHistoryLimitVal, enableTrutowiska: enableTrutowiskaVal, enablePasieczyskaTowarowe: enablePasieczyskaTowaroweVal, enableQueenRearing: defaultEnableQueenRearing, defaultGraftCount, starterDurationDays: defaultStarterDurationDays, isolationDay: defaultIsolationDay, emergenceDay: defaultEmergenceDay });
        }
        localStorage.setItem('beelog_darkMode', currentDarkMode ? 'true' : 'false');
        applyDarkMode(currentDarkMode);
        localStorage.setItem('beelog_language', languageVal);
        app.ports.userSettingsReceived.send({ frameTypes: frameTypesVal, ulikTypes: ulikTypesVal, breedLines: breedLinesVal, darkMode: currentDarkMode, language: languageVal, hatchingToMatingDays: hatchingToMatingDaysVal, maxUlikHistoryLimit: maxUlikHistoryLimitVal, enableTrutowiska: enableTrutowiskaVal, enablePasieczyskaTowarowe: enablePasieczyskaTowaroweVal, enableQueenRearing: enableQueenRearingVal, defaultGraftCount: defaultGraftCountVal, starterDurationDays: starterDurationDaysVal, isolationDay: isolationDayVal, emergenceDay: emergenceDayVal });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsSaveUserSettings.subscribe(async ({ uid, email, frameTypes, ulikTypes, breedLines, darkMode, language, hatchingToMatingDays, maxUlikHistoryLimit, enableTrutowiska, enablePasieczyskaTowarowe, enableQueenRearing, defaultGraftCount, starterDurationDays, isolationDay, emergenceDay }) => {
    if (darkMode !== undefined) {
        localStorage.setItem('beelog_darkMode', darkMode ? 'true' : 'false');
        applyDarkMode(darkMode);
    }
    if (language !== undefined) localStorage.setItem('beelog_language', language === 'en' ? 'en' : 'pl');
    const defaultFrameTypes = ["Wielkopolska", "Wielkopolska 18", "Wielkopolska 1/2", "Warszawska zwykła", "MiniPlus", "Dadant"];
    const defaultUlikTypes = ["Mini plus", "Odkład wielkopolski", "Apidea"];
    const defaultBreedLines = ["car. Galicja", "cau. M", "cau. KP", "cau. Woźnica", "car. Słowenka"];
    const defaultHatchingToMatingDays = 12;
    const defaultMaxUlikHistoryLimit = 40;
    const defaultEnableTrutowiska = true;
    const defaultEnablePasieczyskaTowarowe = true;
    if (window.__E2E__) {
        const state = getE2EState();
        state.userSettings = {
            frameTypes: frameTypes !== undefined ? frameTypes : (state.userSettings ? state.userSettings.frameTypes : defaultFrameTypes),
            ulikTypes: ulikTypes !== undefined ? ulikTypes : (state.userSettings ? state.userSettings.ulikTypes : defaultUlikTypes),
            breedLines: breedLines !== undefined ? breedLines : (state.userSettings ? state.userSettings.breedLines : defaultBreedLines),
            darkMode: darkMode !== undefined ? darkMode : (state.userSettings ? state.userSettings.darkMode : false),
            language: language !== undefined ? language : (state.userSettings ? (state.userSettings.language || 'pl') : 'pl'),
            hatchingToMatingDays: hatchingToMatingDays !== undefined ? hatchingToMatingDays : (state.userSettings ? state.userSettings.hatchingToMatingDays : defaultHatchingToMatingDays),
            maxUlikHistoryLimit: maxUlikHistoryLimit !== undefined ? maxUlikHistoryLimit : (state.userSettings ? state.userSettings.maxUlikHistoryLimit : defaultMaxUlikHistoryLimit),
            enableTrutowiska: enableTrutowiska !== undefined ? enableTrutowiska : (state.userSettings ? state.userSettings.enableTrutowiska : defaultEnableTrutowiska),
            enablePasieczyskaTowarowe: enablePasieczyskaTowarowe !== undefined ? enablePasieczyskaTowarowe : (state.userSettings ? state.userSettings.enablePasieczyskaTowarowe : defaultEnablePasieczyskaTowarowe)
            , enableQueenRearing: enableQueenRearing !== undefined ? enableQueenRearing : (state.userSettings ? state.userSettings.enableQueenRearing : false)
            , defaultGraftCount: defaultGraftCount ?? (state.userSettings?.defaultGraftCount ?? 24)
            , starterDurationDays: starterDurationDays ?? (state.userSettings?.starterDurationDays ?? 2)
            , isolationDay: isolationDay ?? (state.userSettings?.isolationDay ?? 10)
            , emergenceDay: emergenceDay ?? (state.userSettings?.emergenceDay ?? 11)
        };
        saveE2EState(state);
        return;
    }
    try {
        const docRef = doc(db, "users", uid);
        const dataToSave = {};
        const emailToSave = email || (auth.currentUser ? auth.currentUser.email : "");
        if (emailToSave) dataToSave.email = emailToSave;
        if (frameTypes !== undefined) dataToSave.frameTypes = frameTypes;
        if (ulikTypes !== undefined) dataToSave.ulikTypes = ulikTypes;
        if (breedLines !== undefined) dataToSave.breedLines = breedLines;
        if (darkMode !== undefined) dataToSave.darkMode = darkMode;
        if (language !== undefined) dataToSave.language = language === 'en' ? 'en' : 'pl';
        if (hatchingToMatingDays !== undefined) dataToSave.hatchingToMatingDays = hatchingToMatingDays;
        if (maxUlikHistoryLimit !== undefined) dataToSave.maxUlikHistoryLimit = maxUlikHistoryLimit;
        if (enableTrutowiska !== undefined) dataToSave.enableTrutowiska = enableTrutowiska;
        if (enablePasieczyskaTowarowe !== undefined) dataToSave.enablePasieczyskaTowarowe = enablePasieczyskaTowarowe;
        if (enableQueenRearing !== undefined) dataToSave.enableQueenRearing = enableQueenRearing;
        if (defaultGraftCount !== undefined) dataToSave.defaultGraftCount = defaultGraftCount;
        if (starterDurationDays !== undefined) dataToSave.starterDurationDays = starterDurationDays;
        if (isolationDay !== undefined) dataToSave.isolationDay = isolationDay;
        if (emergenceDay !== undefined) dataToSave.emergenceDay = emergenceDay;
        await setDoc(docRef, dataToSave, { merge: true });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

const queenCollections = ['breederQueens', 'starterColonies', 'finisherColonies', 'rearingBatches'];
const newLocalId = () => `qr-${Date.now()}-${Math.random().toString(36).slice(2, 9)}`;

app.ports.jsLoadQueenRearing?.subscribe(async (uid) => {
    if (window.__E2E__) {
        const state = getE2EState();
        sendQueenRearingState(state.queenRearing);
        return;
    }
    try {
        const data = {};
        await Promise.all(queenCollections.map(async (name) => {
            const snapshot = await getDocs(collection(db, 'users', uid, name));
            data[name] = snapshot.docs.map(item => {
                const record = { id: item.id, ...item.data() };
                return name === 'rearingBatches' ? normalizeRearingBatch(record) : record;
            });
        }));
        sendQueenRearingState(data);
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsCreateQueenResource?.subscribe(async ({ uid, kind, fields }) => {
    if (!queenCollections.slice(0, 3).includes(kind)) return;
    const id = newLocalId();
    const record = { ...fields, id };
    try {
        if (window.__E2E__) {
            const state = getE2EState();
            state.queenRearing[kind] = [...(state.queenRearing[kind] || []), record];
            saveE2EState(state);
            sendQueenRearingState(state.queenRearing);
            return;
        }
        await setDoc(doc(db, 'users', uid, kind, id), record);
        app.ports.successMessageReceived.send('Queen-rearing resource saved.');
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsUpdateQueenResource?.subscribe(async ({ uid, kind, id, fields }) => {
    if (!queenCollections.slice(0, 3).includes(kind)) return;
    try {
        if (window.__E2E__) {
            const state = getE2EState();
            state.queenRearing[kind] = (state.queenRearing[kind] || []).map(item => item.id === id ? { ...item, ...fields } : item);
            saveE2EState(state);
            sendQueenRearingState(state.queenRearing);
            return;
        }
        await updateDoc(doc(db, 'users', uid, kind, id), fields);
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteQueenResource?.subscribe(async ({ uid, kind, id }) => {
    if (!queenCollections.slice(0, 3).includes(kind)) return;
    try {
        if (window.__E2E__) {
            const state = getE2EState();
            const resource = (state.queenRearing[kind] || []).find(item => item.id === id);
            if (resource?.activeBatchId) throw new Error('This colony is reserved by an active batch.');
            if (kind === 'breederQueens' && state.queenRearing.rearingBatches.some(batch => batch.breederQueenId === id)) throw new Error('A breeder queen referenced by a batch cannot be deleted. Retire it instead.');
            state.queenRearing[kind] = (state.queenRearing[kind] || []).filter(item => item.id !== id);
            saveE2EState(state);
            sendQueenRearingState(state.queenRearing);
            return;
        }
        await runTransaction(db, async (transaction) => {
            const resourceRef = doc(db, 'users', uid, kind, id);
            const resourceQuery = kind === 'breederQueens' ? query(collection(db, 'users', uid, 'rearingBatches'), where('breederQueenId', '==', id)) : null;
            const [resource, batches] = await Promise.all([transaction.get(resourceRef), resourceQuery ? transaction.get(resourceQuery) : Promise.resolve(null)]);
            if (!resource.exists()) return;
            if (resource.data().activeBatchId) throw new Error('This colony is reserved by an active batch.');
            if (batches && !batches.empty) throw new Error('A breeder queen referenced by a batch cannot be deleted. Retire it instead.');
            transaction.delete(resourceRef);
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsCreatePlannedRearingBatch?.subscribe(async ({ uid, year, fields }) => {
    const batchId = newLocalId();
    try {
        if (window.__E2E__) {
            const state = getE2EState();
            const queen = state.queenRearing.breederQueens.find(item => item.id === fields.breederQueenId && item.active !== false);
            if (!queen) throw new Error('Select an active breeder queen.');
            const nextNumber = (state.queenRearing.sequences[year] || 0) + 1;
            state.queenRearing.sequences[year] = nextNumber;
            state.queenRearing.rearingBatches.push({ ...fields, id: batchId, number: `${year}/${String(nextNumber).padStart(2, '0')}`, status: 'ZAPLANOWANA' });
            saveE2EState(state);
            sendQueenRearingState(state.queenRearing);
            return;
        }
        await runTransaction(db, async (transaction) => {
            const sequenceRef = doc(db, 'users', uid, 'rearingSequences', String(year));
            const breederRef = doc(db, 'users', uid, 'breederQueens', fields.breederQueenId);
            const [sequence, breeder] = await Promise.all([transaction.get(sequenceRef), transaction.get(breederRef)]);
            if (!breeder.exists() || breeder.data().active === false) throw new Error('Select an active breeder queen.');
            const nextNumber = (sequence.exists() ? sequence.data().lastNumber || 0 : 0) + 1;
            const batchRef = doc(db, 'users', uid, 'rearingBatches', batchId);
            transaction.set(sequenceRef, { lastNumber: nextNumber, year });
            transaction.set(batchRef, { ...fields, id: batchId, number: `${year}/${String(nextNumber).padStart(2, '0')}`, status: 'ZAPLANOWANA' });
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsStartRearingBatch?.subscribe(async ({ uid, batchId, starterId, graftedAt, timeZone, starterDurationDays, isolationDay, emergenceDay, schedule }) => {
    try {
        if (window.__E2E__) {
            const state = getE2EState();
            const batch = state.queenRearing.rearingBatches.find(item => item.id === batchId);
            const starter = state.queenRearing.starterColonies.find(item => item.id === starterId);
            if (!batch || batch.status !== 'ZAPLANOWANA' || !starter || starter.availability !== 'PUSTY' || starter.activeBatchId) throw new Error('Batch or starter is unavailable.');
            Object.assign(batch, { status: 'W_STARTERZE', starterColonyId: starterId, graftedAt, timeZone, starterDurationDays, isolationDay, emergenceDay, ...schedule });
            Object.assign(starter, { availability: 'ZAJETY', activeBatchId: batchId });
            saveE2EState(state);
            sendQueenRearingState(state.queenRearing);
            return;
        }
        const graftDate = localDateTimeToDate(graftedAt, timeZone);
        const timestamps = Object.fromEntries(Object.entries(schedule).map(([key, value]) => [key, Timestamp.fromDate(localDateTimeToDate(value, timeZone))]));
        await runTransaction(db, async (transaction) => {
            const batchRef = doc(db, 'users', uid, 'rearingBatches', batchId);
            const starterRef = doc(db, 'users', uid, 'starterColonies', starterId);
            const [batch, starter] = await Promise.all([transaction.get(batchRef), transaction.get(starterRef)]);
            if (!batch.exists() || batch.data().status !== 'ZAPLANOWANA') throw new Error('Only a planned batch can be started.');
            if (!starter.exists() || starter.data().availability !== 'PUSTY' || starter.data().activeBatchId) throw new Error('The selected starter is already reserved.');
            transaction.update(batchRef, { status: 'W_STARTERZE', starterColonyId: starterId, graftedAt: Timestamp.fromDate(graftDate), timeZone, starterDurationDays, isolationDay, emergenceDay, ...timestamps });
            transaction.update(starterRef, { availability: 'ZAJETY', activeBatchId: batchId });
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsTransitionRearingBatch?.subscribe(async ({ uid, batchId, action, colonyId, count, incubatorBar }) => {
    const stages = { starter: 'starterColonies', finisher: 'finisherColonies' };
    try {
        if (window.__E2E__) {
            const state = getE2EState();
            const batch = state.queenRearing.rearingBatches.find(item => item.id === batchId);
            if (!batch) throw new Error('Batch not found.');
            const release = (kind, increment) => {
                if (!batch[`${kind}ColonyId`]) return;
                const colony = state.queenRearing[stages[kind]].find(item => item.id === batch[`${kind}ColonyId`]);
                if (colony) Object.assign(colony, { availability: 'PUSTY', activeBatchId: null, completedSeries: (colony.completedSeries || 0) + (increment ? 1 : 0) });
            };
            if (action === 'toFinisher') {
                if (batch.status !== 'W_STARTERZE' || !Number.isInteger(count) || count < 1 || count > batch.graftCount) throw new Error('Accepted cell count must be between 1 and the graft count.');
                const finisher = state.queenRearing.finisherColonies.find(item => item.id === colonyId);
                if (!finisher || finisher.availability === 'ZAJETY') throw new Error('The selected finisher is already reserved.');
                release('starter', true);
                Object.assign(finisher, { availability: 'ZAJETY', activeBatchId: batchId });
                Object.assign(batch, { status: 'W_FINISHERZE', acceptedCount: count, finisherColonyId: colonyId });
            } else if (action === 'zeroComplete') {
                if (batch.status !== 'W_STARTERZE' || count !== 0) throw new Error('Only a zero-acceptance starter batch can complete this way.');
                release('starter', true);
                Object.assign(batch, { status: 'ZAKONCZONA', acceptedCount: 0 });
            } else if (action === 'toIncubator') {
                if (batch.status !== 'W_FINISHERZE' || !batch.acceptedCount || !incubatorBar?.trim()) throw new Error('Enter an incubator bar number for an accepted batch.');
                release('finisher', true);
                Object.assign(batch, { status: 'W_CIEPLARCE', incubatorBar, finisherColonyId: null });
            } else if (action === 'completeDirect' || action === 'completeIncubator') {
                const maxCount = batch.acceptedCount;
                if (!['W_FINISHERZE', 'W_CIEPLARCE'].includes(batch.status) || !Number.isInteger(count) || count < 0 || count > maxCount) throw new Error('Emergence count is outside the accepted count.');
                if (action === 'completeDirect') release('finisher', true);
                Object.assign(batch, { status: 'ZAKONCZONA', emergedCount: count, incubatorBar: action === 'completeDirect' ? null : batch.incubatorBar });
            } else {
                throw new Error('Unsupported batch transition.');
            }
            saveE2EState(state);
            sendQueenRearingState(state.queenRearing);
            return;
        }
        await runTransaction(db, async (transaction) => {
            const batchRef = doc(db, 'users', uid, 'rearingBatches', batchId);
            const batchSnap = await transaction.get(batchRef);
            if (!batchSnap.exists()) throw new Error('Batch not found.');
            const batch = batchSnap.data();
            const resourceIds = [batch.starterColonyId, batch.finisherColonyId, action === 'toFinisher' ? colonyId : null].filter(Boolean);
            const resourceRefs = resourceIds.map(id => doc(db, 'users', uid, id === colonyId && action === 'toFinisher' ? 'finisherColonies' : (batch.finisherColonyId === id ? 'finisherColonies' : 'starterColonies'), id));
            const resources = await Promise.all(resourceRefs.map(ref => transaction.get(ref)));
            const byId = new Map(resources.map((item, index) => [resourceIds[index], { ref: resourceRefs[index], snap: item }]));
            const release = (kind, increment) => {
                const id = batch[`${kind}ColonyId`];
                if (!id) return;
                const resource = byId.get(id);
                if (!resource || !resource.snap.exists() || resource.snap.data().activeBatchId !== batchId) throw new Error('Batch resource reservation is inconsistent.');
                transaction.update(resource.ref, { availability: 'PUSTY', activeBatchId: null, completedSeries: (resource.snap.data().completedSeries || 0) + (increment ? 1 : 0) });
            };
            if (action === 'toFinisher') {
                if (batch.status !== 'W_STARTERZE' || !Number.isInteger(count) || count < 1 || count > batch.graftCount) throw new Error('Accepted cell count must be between 1 and the graft count.');
                const finisher = byId.get(colonyId);
                if (!finisher || !finisher.snap.exists() || finisher.snap.data().availability === 'ZAJETY' || finisher.snap.data().activeBatchId) throw new Error('The selected finisher is already reserved.');
                release('starter', true);
                transaction.update(finisher.ref, { availability: 'ZAJETY', activeBatchId: batchId });
                transaction.update(batchRef, { status: 'W_FINISHERZE', acceptedCount: count, finisherColonyId: colonyId });
            } else if (action === 'zeroComplete') {
                if (batch.status !== 'W_STARTERZE' || count !== 0) throw new Error('Only a zero-acceptance starter batch can complete this way.');
                release('starter', true);
                transaction.update(batchRef, { status: 'ZAKONCZONA', acceptedCount: 0 });
            } else if (action === 'toIncubator') {
                if (batch.status !== 'W_FINISHERZE' || !batch.acceptedCount || !incubatorBar?.trim()) throw new Error('Enter an incubator bar number for an accepted batch.');
                release('finisher', true);
                transaction.update(batchRef, { status: 'W_CIEPLARCE', incubatorBar, finisherColonyId: null });
            } else if (action === 'completeDirect' || action === 'completeIncubator') {
                const maxCount = batch.acceptedCount;
                if (!['W_FINISHERZE', 'W_CIEPLARCE'].includes(batch.status) || !Number.isInteger(count) || count < 0 || count > maxCount) throw new Error('Emergence count is outside the accepted count.');
                if (action === 'completeDirect') release('finisher', true);
                transaction.update(batchRef, { status: 'ZAKONCZONA', emergedCount: count, incubatorBar: action === 'completeDirect' ? null : batch.incubatorBar });
            } else {
                throw new Error('Unsupported batch transition.');
            }
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteRearingBatch?.subscribe(async ({ uid, batchId }) => {
    try {
        if (window.__E2E__) {
            const state = getE2EState();
            const batch = state.queenRearing.rearingBatches.find(item => item.id === batchId);
            if (batch?.starterColonyId) {
                const starter = state.queenRearing.starterColonies.find(item => item.id === batch.starterColonyId);
                if (starter?.activeBatchId === batchId) Object.assign(starter, { availability: 'PUSTY', activeBatchId: null });
            }
            if (batch?.finisherColonyId) {
                const finisher = state.queenRearing.finisherColonies.find(item => item.id === batch.finisherColonyId);
                if (finisher?.activeBatchId === batchId) Object.assign(finisher, { availability: 'PUSTY', activeBatchId: null });
            }
            state.queenRearing.rearingBatches = state.queenRearing.rearingBatches.filter(item => item.id !== batchId);
            saveE2EState(state);
            sendQueenRearingState(state.queenRearing);
            return;
        }
        await runTransaction(db, async (transaction) => {
            const batchRef = doc(db, 'users', uid, 'rearingBatches', batchId);
            const batchSnap = await transaction.get(batchRef);
            if (!batchSnap.exists()) return;
            const batch = batchSnap.data();
            const assigned = [];
            if (batch.starterColonyId) assigned.push(['starterColonies', batch.starterColonyId]);
            if (batch.finisherColonyId) assigned.push(['finisherColonies', batch.finisherColonyId]);
            const refs = assigned.map(([kind, id]) => doc(db, 'users', uid, kind, id));
            const snaps = await Promise.all(refs.map(ref => transaction.get(ref)));
            snaps.forEach((snap, index) => {
                if (snap.exists() && snap.data().activeBatchId === batchId) transaction.update(refs[index], { availability: 'PUSTY', activeBatchId: null });
            });
            transaction.delete(batchRef);
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsLoadApiaries.subscribe(async (uid) => {
    if (window.__E2E__) {
        const state = getE2EState();
        const apiaries = (state.apiaries || []).map(a => {
            let uliki = a.uliki || (state.uliki && state.uliki[a.id]) || [];
            let hives = a.hives || (state.hives && state.hives[a.id]) || [];
            return { ...a, uliki: uliki, hives: hives };
        });
        app.ports.apiariesReceived.send(apiaries);
        return;
    }
    try {
        const q = query(collection(db, "pasieczyska"), where("adminId", "==", uid));
        onSnapshot(q, async (snapshot) => {
            const apiaries = await Promise.all(snapshot.docs.map(async (docSnap) => {
                const data = docSnap.data();
                const apiaryId = docSnap.id;
                    const apiaryType = data.apiaryType || "towarowe";
                    const baseUrl = window.location.href.split('#')[0];
                    let uliki = [];
                    let hives = [];
                    try {
                        const hivesQuery = query(collection(db, "hives"), where("apiaryId", "==", apiaryId));
                        const hivesSnap = await getDocs(hivesQuery);
                        hivesSnap.forEach(hDoc => {
                            const hData = hDoc.data();
                            if (apiaryType === "trutowisko") {
                                uliki.push({
                                    id: hDoc.id,
                                    name: hData.name || "",
                                    hiveType: hData.hiveType || "Mini plus",
                                    hasQueen: !!hData.hasQueen,
                                    queen: hData.queen || { breedLine: "", hasOpalit: false, color: "", number: "" },
                                    state: hData.state || "bezmatek",
                                    expectedHatchDate: hData.expectedHatchDate || "",
                                    expectedMatingDate: hData.expectedMatingDate || "",
                                    nfcLink: hData.nfcLink || hData.nfcTagId || (baseUrl + '#ulik/' + apiaryId + '/' + hDoc.id),
                                    order: hData.order !== undefined ? hData.order : 0,
                                    history: hData.history || []
                                });
                            } else {
                                hives.push({
                                    id: hDoc.id,
                                    apiaryId: apiaryId,
                                    name: hData.name || "",
                                    hiveType: hData.hiveType || "korpusowy",
                                    frameType: hData.frameType || "Wielkopolska",
                                    broodFrameType: hData.broodFrameType || "Wielkopolska",
                                    broodFrameCount: hData.broodFrameCount !== undefined ? hData.broodFrameCount : 10,
                                    maxBroodFrames: hData.maxBroodFrames !== undefined ? hData.maxBroodFrames : 24,
                                    hasSuper: hData.hasSuper === true || hData.hasSuper === 'true',
                                    superFrameType: hData.superFrameType || "Wielkopolska 1/2",
                                    superCount: hData.superCount !== undefined ? hData.superCount : 1,
                                    superFrameCount: hData.superFrameCount !== undefined ? hData.superFrameCount : 10,
                                    maxSuperFrames: hData.maxSuperFrames !== undefined ? hData.maxSuperFrames : 18,
                                    nfcLink: hData.nfcLink || hData.nfcTagId || (baseUrl + '#hive/' + apiaryId + '/' + hDoc.id),
                                    queen: hData.queen || { hasOpalit: false, color: "biały", number: "" },
                                    pollenTrap: hData.pollenTrap || "brak",
                                    order: hData.order !== undefined ? hData.order : 0,
                                    korpusy: hData.korpusy || [{ id: "1", hasQueen: false, hasExcluderAbove: false, hasFoilAbove: false, hasOpenEntrance: false }]
                                });
                            }
                        });
                    } catch (err) {
                        console.error("Error loading hives/uliki for apiary", apiaryId, err);
                    }
                    return {
                        id: apiaryId,
                        name: data.name || "",
                        apiaryType: apiaryType,
                        adminId: data.adminId || "",
                        order: data.order !== undefined ? data.order : 0,
                        uliki: uliki,
                        hives: hives
                    };
            }));
            apiaries.sort((a, b) => a.order - b.order);
            app.ports.apiariesReceived.send(apiaries);
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsSaveApiaryOrders.subscribe(async (apiaries) => {
    if (window.__E2E__) {
        const state = getE2EState();
        state.apiaries = apiaries;
        saveE2EState(state);
        app.ports.apiariesReceived.send(state.apiaries);
        return;
    }
    try {
        for (let i = 0; i < apiaries.length; i++) {
            const docRef = doc(db, "pasieczyska", apiaries[i].id);
            await updateDoc(docRef, { order: i });
        }
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsCreateApiary.subscribe(async ({ name, apiaryType, uid }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        state.apiaries.push({
            id: 'apiary-' + Math.random().toString(36).substr(2, 9),
            name: name,
            apiaryType: apiaryType || "towarowe",
            adminId: uid,
            order: state.apiaries.length
        });
        saveE2EState(state);
        app.ports.apiariesReceived.send(state.apiaries);
        return;
    }
    try {
        const newRef = doc(collection(db, "pasieczyska"));
        await setDoc(newRef, {
            name: name,
            apiaryType: apiaryType || "towarowe",
            adminId: uid,
            order: 0
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsLoadUliki.subscribe(async ({ apiaryId, deepLinkId }) => {
    const baseUrl = window.location.href.split('#')[0];
    if (window.__E2E__) {
        const state = getE2EState();
        if (!state.uliki) state.uliki = {};
        let targetApiaryId = apiaryId;
        if (deepLinkId) {
            let found = (state.uliki[apiaryId] || []).some(u => u.id === deepLinkId);
            if (!found) {
                for (const aId in state.uliki) {
                    if ((state.uliki[aId] || []).some(u => u.id === deepLinkId)) {
                        targetApiaryId = aId;
                        break;
                    }
                }
            }
            if (targetApiaryId !== apiaryId) {
                window.location.hash = '#ulik/' + targetApiaryId + '/' + deepLinkId;
            }
        }
        app.ports.ulikiReceived.send(state.uliki[targetApiaryId] || []);
        return;
    }
    try {
        let targetApiaryId = apiaryId;
        if (deepLinkId) {
            const hSnap = await getDoc(doc(db, "hives", deepLinkId));
            if (hSnap.exists()) {
                targetApiaryId = hSnap.data().apiaryId || apiaryId;
            }
            if (targetApiaryId !== apiaryId) {
                window.location.hash = '#ulik/' + targetApiaryId + '/' + deepLinkId;
            }
        }
        const q = query(collection(db, "hives"), where("apiaryId", "==", targetApiaryId));
        onSnapshot(q, (snapshot) => {
            const uliki = [];
            snapshot.forEach((docSnap) => {
                const data = docSnap.data();
                uliki.push({
                    id: docSnap.id,
                    apiaryId: data.apiaryId || targetApiaryId,
                    name: data.name || "",
                    hiveType: data.hiveType || "Mini plus",
                    hasQueen: !!data.hasQueen,
                    queen: data.queen || { breedLine: "", hasOpalit: false, color: "", number: "" },
                    state: data.state || "bezmatek",
                    expectedHatchDate: data.expectedHatchDate || "",
                    expectedMatingDate: data.expectedMatingDate || "",
                    nfcLink: data.nfcLink || data.nfcTagId || "",
                    order: data.order !== undefined ? data.order : 0,
                    history: data.history || []
                });
            });
            uliki.sort((a, b) => a.order - b.order);
            app.ports.ulikiReceived.send(uliki);
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsSaveUlikOrders.subscribe(async ({ apiaryId, uliki }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (!state.uliki) state.uliki = {};
        state.uliki[apiaryId] = uliki;
        saveE2EState(state);
        app.ports.ulikiReceived.send(state.uliki[apiaryId]);
        return;
    }
    try {
        for (let i = 0; i < uliki.length; i++) {
            const docRef = doc(db, "hives", uliki[i].id);
            await updateDoc(docRef, { order: i });
        }
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsCreateUlik.subscribe(async ({ apiaryId, name, hiveType }) => {
    const baseUrl = window.location.href.split('#')[0];
    if (window.__E2E__) {
        const state = getE2EState();
        if (!state.uliki) state.uliki = {};
        if (!state.uliki[apiaryId]) state.uliki[apiaryId] = [];
        const ulikId = 'ulik-' + Math.random().toString(36).substr(2, 9);
        const nfcLink = baseUrl + '#ulik/' + apiaryId + '/' + ulikId;
        state.uliki[apiaryId].push({
            id: ulikId,
            name: name,
            hiveType: hiveType || "Mini plus",
            hasQueen: false,
            queen: { breedLine: "", hasOpalit: false, color: "", number: "" },
            state: "bezmatek",
            expectedHatchDate: "",
            expectedMatingDate: "",
            nfcLink: nfcLink,
            order: state.uliki[apiaryId].length,
            history: []
        });
        saveE2EState(state);
        app.ports.ulikiReceived.send(state.uliki[apiaryId]);
        return;
    }
    try {
        const newDocRef = doc(collection(db, "hives"));
        const ulikId = newDocRef.id;
        const nfcLink = baseUrl + '#ulik/' + apiaryId + '/' + ulikId;
        await setDoc(newDocRef, {
            apiaryId: apiaryId,
            name: name,
            hiveType: hiveType || "Mini plus",
            hasQueen: false,
            queen: { breedLine: "", hasOpalit: false, color: "", number: "" },
            state: "bezmatek",
            expectedHatchDate: "",
            expectedMatingDate: "",
            nfcLink: nfcLink,
            order: 0,
            history: []
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsUpdateUlik.subscribe(async ({ apiaryId, ulikId, field, value }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.uliki && state.uliki[apiaryId]) {
            state.uliki[apiaryId] = state.uliki[apiaryId].map(u => {
                if (u.id === ulikId) {
                    if (field.startsWith('queen.')) {
                        const qField = field.split('.')[1];
                        return { ...u, queen: { ...u.queen, [qField]: value } };
                    }
                    if (field === 'hasOpalit' || field === 'hasQueen') {
                        const boolVal = value === true || value === "true";
                        return { ...u, [field]: boolVal };
                    }
                    return { ...u, [field]: value };
                }
                return u;
            });
            saveE2EState(state);
            app.ports.ulikiReceived.send(state.uliki[apiaryId]);
        }
        return;
    }
    try {
        let val = value;
        if (field === 'hasOpalit' || field === 'hasQueen') {
            val = value === true || value === "true";
        }
        const docRef = doc(db, "hives", ulikId);
        await updateDoc(docRef, { [field]: val });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsUpdateUlikFull.subscribe(async ({ apiaryId, ulikId, fields }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.uliki && state.uliki[apiaryId]) {
            state.uliki[apiaryId] = state.uliki[apiaryId].map(u => {
                if (u.id === ulikId) {
                    return { ...u, ...fields };
                }
                return u;
            });
            saveE2EState(state);
            app.ports.ulikiReceived.send(state.uliki[apiaryId]);
        }
        return;
    }
    try {
        const docRef = doc(db, "hives", ulikId);
        await updateDoc(docRef, fields);
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsUpdateUlikName.subscribe(async ({ apiaryId, ulikId, newName }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.uliki && state.uliki[apiaryId]) {
            state.uliki[apiaryId] = state.uliki[apiaryId].map(u => u.id === ulikId ? { ...u, name: newName } : u);
            saveE2EState(state);
            app.ports.ulikiReceived.send(state.uliki[apiaryId]);
        }
        return;
    }
    try {
        const docRef = doc(db, "hives", ulikId);
        await updateDoc(docRef, { name: newName });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteUlik.subscribe(async ({ apiaryId, ulikId }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.uliki && state.uliki[apiaryId]) {
            state.uliki[apiaryId] = state.uliki[apiaryId].filter(u => u.id !== ulikId);
            saveE2EState(state);
            app.ports.ulikiReceived.send(state.uliki[apiaryId]);
        }
        return;
    }
    try {
        await deleteDoc(doc(db, "hives", ulikId));
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsMoveUlik.subscribe(async ({ sourceApiaryId, targetApiaryId, ulikId }) => {
    const baseUrl = window.location.href.split('#')[0];
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.uliki && state.uliki[sourceApiaryId]) {
            const ulikIndex = state.uliki[sourceApiaryId].findIndex(u => u.id === ulikId);
            if (ulikIndex !== -1) {
                const ulik = state.uliki[sourceApiaryId][ulikIndex];
                state.uliki[sourceApiaryId].splice(ulikIndex, 1);
                if (!state.uliki[targetApiaryId]) state.uliki[targetApiaryId] = [];
                const existingNfcLink = ulik.nfcLink || (baseUrl + '#ulik/' + sourceApiaryId + '/' + ulikId);
                state.uliki[targetApiaryId].push({ ...ulik, nfcLink: existingNfcLink, order: state.uliki[targetApiaryId].length });
                saveE2EState(state);
                app.ports.ulikiReceived.send(state.uliki[sourceApiaryId]);
            }
        }
        return;
    }
    try {
        const docRef = doc(db, "hives", ulikId);
        await updateDoc(docRef, { apiaryId: targetApiaryId });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsUpdateApiary.subscribe(async ({ apiaryId, name }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        state.apiaries = state.apiaries.map(a => a.id === apiaryId ? { ...a, name } : a);
        saveE2EState(state);
        app.ports.apiariesReceived.send(state.apiaries);
        return;
    }
    try {
        const docRef = doc(db, "pasieczyska", apiaryId);
        await updateDoc(docRef, { name: name });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteApiary.subscribe(async ({ apiaryId }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        state.apiaries = state.apiaries.filter(a => a.id !== apiaryId);
        delete state.hives[apiaryId];
        saveE2EState(state);
        app.ports.apiariesReceived.send(state.apiaries);
        return;
    }
    try {
        await deleteDoc(doc(db, "pasieczyska", apiaryId));
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsLoadHives.subscribe(async ({ apiaryId, deepLinkId }) => {
    const baseUrl = window.location.href.split('#')[0];
    if (window.__E2E__) {
        const state = getE2EState();
        if (!state.hives) state.hives = {};
        let targetApiaryId = apiaryId;
        if (deepLinkId) {
            let found = (state.hives[apiaryId] || []).some(h => h.id === deepLinkId);
            if (!found) {
                for (const aId in state.hives) {
                    if ((state.hives[aId] || []).some(h => h.id === deepLinkId)) {
                        targetApiaryId = aId;
                        break;
                    }
                }
            }
            if (targetApiaryId !== apiaryId) {
                window.location.hash = '#hive/' + targetApiaryId + '/' + deepLinkId;
            }
        }
        app.ports.hivesReceived.send(state.hives[targetApiaryId] || []);
        return;
    }
    try {
        let targetApiaryId = apiaryId;
        if (deepLinkId) {
            const hSnap = await getDoc(doc(db, "hives", deepLinkId));
            if (hSnap.exists()) {
                targetApiaryId = hSnap.data().apiaryId || apiaryId;
            }
            if (targetApiaryId !== apiaryId) {
                window.location.hash = '#hive/' + targetApiaryId + '/' + deepLinkId;
            }
        }
        const q = query(collection(db, "hives"), where("apiaryId", "==", targetApiaryId));
        onSnapshot(q, (snapshot) => {
            const hives = [];
            snapshot.forEach((docSnap) => {
                const data = docSnap.data();
                hives.push({
                    id: docSnap.id,
                    apiaryId: targetApiaryId,
                    name: data.name || "",
                    hiveType: data.hiveType || "korpusowy",
                    frameType: data.frameType || "Wielkopolska",
                    broodFrameType: data.broodFrameType || "Wielkopolska",
                    broodFrameCount: data.broodFrameCount !== undefined ? data.broodFrameCount : 10,
                    maxBroodFrames: data.maxBroodFrames !== undefined ? data.maxBroodFrames : 24,
                    hasSuper: data.hasSuper === true || data.hasSuper === 'true',
                    superFrameType: data.superFrameType || "Wielkopolska 1/2",
                    superCount: data.superCount !== undefined ? data.superCount : 1,
                    superFrameCount: data.superFrameCount !== undefined ? data.superFrameCount : 10,
                    maxSuperFrames: data.maxSuperFrames !== undefined ? data.maxSuperFrames : 18,
                    nfcLink: data.nfcLink || data.nfcTagId || "",
                    queen: data.queen || { hasOpalit: false, color: "biały", number: "" },
                    pollenTrap: data.pollenTrap || "brak",
                    order: data.order !== undefined ? data.order : 0,
                    korpusy: data.korpusy || [{ id: "1", hasQueen: false, hasExcluderAbove: false, hasFoilAbove: false, hasOpenEntrance: false }]
                });
            });
            hives.sort((a, b) => a.order - b.order);
            app.ports.hivesReceived.send(hives);
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsSaveHiveOrders.subscribe(async ({ apiaryId, hives }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        state.hives[apiaryId] = hives;
        saveE2EState(state);
        app.ports.hivesReceived.send(state.hives[apiaryId]);
        return;
    }
    try {
        for (let i = 0; i < hives.length; i++) {
            const docRef = doc(db, "hives", hives[i].id);
            await updateDoc(docRef, { order: i });
        }
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsCreateHive.subscribe(async ({ apiaryId, name, hiveType, frameType, broodFrameType, broodFrameCount, maxBroodFrames, hasSuper, superFrameType, superCount, superFrameCount, maxSuperFrames }) => {
    const baseUrl = window.location.href.split('#')[0];
    const hType = hiveType || "korpusowy";
    const fType = frameType || "Wielkopolska";
    const bType = broodFrameType || "Wielkopolska";
    const maxB = maxBroodFrames !== undefined ? Number(maxBroodFrames) : 24;
    const bCount = broodFrameCount !== undefined ? Math.min(Math.max(1, Number(broodFrameCount)), maxB) : Math.min(10, maxB);
    const hasSup = hasSuper === true || hasSuper === 'true';
    const sType = superFrameType || "Wielkopolska 1/2";
    const sCount = superCount !== undefined ? Math.max(0, Number(superCount)) : 1;
    const maxS = maxSuperFrames !== undefined ? Number(maxSuperFrames) : 18;
    const sFCount = superFrameCount !== undefined ? Math.min(Math.max(1, Number(superFrameCount)), maxS) : Math.min(10, maxS);
    const korpusyVal = hType === "korpusowy" ? [{ id: "1", hasQueen: false, hasExcluderAbove: false, hasFoilAbove: false, hasOpenEntrance: false }] : [];
    if (window.__E2E__) {
        const state = getE2EState();
        if (!state.hives[apiaryId]) state.hives[apiaryId] = [];
        const hiveId = 'hive-' + Math.random().toString(36).substr(2, 9);
        const nfcLink = baseUrl + '#hive/' + apiaryId + '/' + hiveId;
        state.hives[apiaryId].push({
            id: hiveId,
            apiaryId: apiaryId,
            name: name,
            hiveType: hType,
            frameType: fType,
            broodFrameType: bType,
            broodFrameCount: bCount,
            maxBroodFrames: maxB,
            hasSuper: hasSup,
            superFrameType: sType,
            superCount: sCount,
            superFrameCount: sFCount,
            maxSuperFrames: maxS,
            nfcLink: nfcLink,
            queen: { hasOpalit: false, color: "Biały", number: "" },
            pollenTrap: "brak",
            order: state.hives[apiaryId].length,
            korpusy: korpusyVal
        });
        saveE2EState(state);
        app.ports.hivesReceived.send(state.hives[apiaryId]);
        return;
    }
    try {
        const newDocRef = doc(collection(db, "hives"));
        const hiveId = newDocRef.id;
        const nfcLink = baseUrl + '#hive/' + apiaryId + '/' + hiveId;
        await setDoc(newDocRef, {
            apiaryId: apiaryId,
            name: name,
            hiveType: hType,
            frameType: fType,
            broodFrameType: bType,
            broodFrameCount: bCount,
            maxBroodFrames: maxB,
            hasSuper: hasSup,
            superFrameType: sType,
            superCount: sCount,
            superFrameCount: sFCount,
            maxSuperFrames: maxS,
            nfcLink: nfcLink,
            queen: { hasOpalit: false, color: "biały", number: "" },
            pollenTrap: "brak",
            order: 0,
            korpusy: korpusyVal
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

if (app.ports.jsUpdateHiveFull) {
    app.ports.jsUpdateHiveFull.subscribe(async ({ apiaryId, hiveId, fields }) => {
        if (window.__E2E__) {
            const state = getE2EState();
            if (state.hives && state.hives[apiaryId]) {
                state.hives[apiaryId] = state.hives[apiaryId].map(h => {
                    if (h.id === hiveId) {
                        return { ...h, ...fields };
                    }
                    return h;
                });
                saveE2EState(state);
                app.ports.hivesReceived.send(state.hives[apiaryId]);
            }
            return;
        }
        try {
            const docRef = doc(db, "hives", hiveId);
            await updateDoc(docRef, fields);
        } catch (error) {
            app.ports.operationError.send(error.message);
        }
    });
}

app.ports.jsUpdateNote.subscribe(async ({ apiaryId, hiveId, noteId, text }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.notes[hiveId]) {
            state.notes[hiveId] = state.notes[hiveId].map(n => n.id === noteId ? { ...n, text } : n);
            saveE2EState(state);
            app.ports.notesReceived.send(state.notes[hiveId]);
        }
        return;
    }
    try {
        const docRef = doc(db, "hives", hiveId, "notes", noteId);
        await updateDoc(docRef, { text: text });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteNote.subscribe(async ({ apiaryId, hiveId, noteId }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.notes[hiveId]) {
            state.notes[hiveId] = state.notes[hiveId].filter(n => n.id !== noteId);
            saveE2EState(state);
            app.ports.notesReceived.send(state.notes[hiveId]);
        }
        return;
    }
    try {
        const docRef = doc(db, "hives", hiveId, "notes", noteId);
        await deleteDoc(docRef);
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsUpdateHive.subscribe(async ({ apiaryId, hiveId, field, value }) => {
    let parsedVal = value;
    if (['broodFrameCount', 'maxBroodFrames', 'superCount', 'superFrameCount', 'maxSuperFrames'].includes(field)) {
        parsedVal = parseInt(value, 10);
        if (isNaN(parsedVal)) parsedVal = value;
    } else if (field === 'hasSuper') {
        parsedVal = value === true || value === 'true';
    }
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.hives[apiaryId]) {
            state.hives[apiaryId] = state.hives[apiaryId].map(h => {
                if (h.id === hiveId) {
                    if (field.startsWith('queen.')) {
                        const qField = field.split('.')[1];
                        return { ...h, queen: { ...h.queen, [qField]: value } };
                    }
                    return { ...h, [field]: parsedVal };
                }
                return h;
            });
            saveE2EState(state);
            app.ports.hivesReceived.send(state.hives[apiaryId]);
        }
        return;
    }
    try {
        const docRef = doc(db, "hives", hiveId);
        await updateDoc(docRef, { [field]: parsedVal });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});



app.ports.jsStartSpeechRecognition.subscribe(() => {
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (SpeechRecognition) {
        const recognition = new SpeechRecognition();
        recognition.lang = 'pl-PL';
        recognition.interimResults = false;
        recognition.onresult = (event) => {
            const text = event.results[0][0].transcript;
            app.ports.speechRecognized.send(text);
        };
        recognition.onerror = (event) => {
            app.ports.operationError.send("Błąd rozpoznawania mowy: " + event.error);
        };
        recognition.start();
    } else {
        app.ports.operationError.send("Web Speech API nie jest obsługiwane w tej przeglądarce.");
    }
});

app.ports.jsLoadNotes.subscribe(async ({ apiaryId, hiveId }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        app.ports.notesReceived.send(state.notes[hiveId] || []);
        return;
    }
    try {
        const q = collection(db, "hives", hiveId, "notes");
        onSnapshot(q, (snapshot) => {
            const notes = [];
            snapshot.forEach((docSnap) => {
                const data = docSnap.data();
                const ts = data.timestamp;
                let dateObj = null;
                let rawTimestamp = 0;
                if (ts) {
                    if (typeof ts.toDate === 'function') {
                        dateObj = ts.toDate();
                        rawTimestamp = dateObj.getTime();
                    } else if (ts.seconds) {
                        rawTimestamp = ts.seconds * 1000;
                        dateObj = new Date(rawTimestamp);
                    } else {
                        dateObj = new Date(ts);
                        rawTimestamp = dateObj.getTime();
                        if (isNaN(rawTimestamp)) {
                            rawTimestamp = 0;
                        }
                    }
                }
                notes.push({
                    id: docSnap.id,
                    text: data.text || "",
                    authorId: data.authorId || "",
                    authorEmail: data.authorEmail || "",
                    timestamp: dateObj ? dateObj.toLocaleString() : (typeof ts === 'string' ? ts : ""),
                    rawTimestamp: rawTimestamp
                });
            });
            notes.sort((a, b) => b.rawTimestamp - a.rawTimestamp);
            const cleanedNotes = notes.map(n => ({
                id: n.id,
                text: n.text,
                authorId: n.authorId,
                authorEmail: n.authorEmail,
                timestamp: n.timestamp
            }));
            app.ports.notesReceived.send(cleanedNotes);
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsSaveNote.subscribe(async ({ apiaryId, hiveId, text, authorId, authorEmail }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (!state.notes[hiveId]) state.notes[hiveId] = [];
        state.notes[hiveId].unshift({
            id: 'note-' + Math.random().toString(36).substr(2, 9),
            text: text,
            authorId: authorId,
            authorEmail: authorEmail,
            timestamp: new Date().toLocaleString()
        });
        saveE2EState(state);
        app.ports.notesReceived.send(state.notes[hiveId]);
        return;
    }
    try {
        await addDoc(collection(db, "hives", hiveId, "notes"), {
            text: text,
            authorId: authorId,
            authorEmail: authorEmail,
            timestamp: new Date()
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsUpdateHiveName.subscribe(async ({ apiaryId, hiveId, newName }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.hives[apiaryId]) {
            state.hives[apiaryId] = state.hives[apiaryId].map(h => h.id === hiveId ? { ...h, name: newName } : h);
            saveE2EState(state);
            app.ports.hivesReceived.send(state.hives[apiaryId]);
        }
        return;
    }
    try {
        const docRef = doc(db, "hives", hiveId);
        await updateDoc(docRef, { name: newName });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteHive.subscribe(async ({ apiaryId, hiveId }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.hives[apiaryId]) {
            state.hives[apiaryId] = state.hives[apiaryId].filter(h => h.id !== hiveId);
            delete state.notes[hiveId];
            saveE2EState(state);
            app.ports.hivesReceived.send(state.hives[apiaryId]);
        }
        return;
    }
    try {
        const docRef = doc(db, "hives", hiveId);
        await deleteDoc(docRef);
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsCopyText.subscribe(async (text) => {
    try {
        if (navigator.clipboard && navigator.clipboard.writeText) {
            await navigator.clipboard.writeText(text);
        } else {
            const textArea = document.createElement("textarea");
            textArea.value = text;
            textArea.style.position = "fixed";
            document.body.appendChild(textArea);
            textArea.focus();
            textArea.select();
            document.execCommand('copy');
            document.body.removeChild(textArea);
        }
        if (app.ports.successMessageReceived) {
            app.ports.successMessageReceived.send("Skopiowano ID pasiecznika do schowka!");
        } else {
            alert("Skopiowano ID do schowka: " + text);
        }
    } catch (e) {
        prompt("Skopiuj ID pasiecznika (zaznacz i skopiuj):", text);
    }
});
