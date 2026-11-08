import { Elm } from './Main.elm';
import { auth, db, googleProvider, signInWithPopup, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut, collection, doc, getDoc, setDoc, addDoc, updateDoc, deleteDoc, query, where, getDocs, onSnapshot } from '../../src/firebase.js';
import { onAuthStateChanged } from 'firebase/auth';

function getE2EState() {
    let state = { apiaries: [], hives: {}, notes: {} };
    if (window.__E2E__) {
        const saved = localStorage.getItem('__E2E_STATE__');
        if (saved) {
            try {
                state = JSON.parse(saved);
                if (state.apiaries) {
                    state.apiaries = normalizeApiariesForE2E(state.apiaries);
                }
            } catch (e) {}
        }
    }
    return state;
}

function normalizeApiariesForE2E(apiaries) {
    return apiaries.map(a => {
        let membersObj = {};
        if (Array.isArray(a.members)) {
            a.members.forEach(item => {
                if (Array.isArray(item) && item.length === 2) {
                    membersObj[item[0]] = item[1];
                }
            });
        } else if (a.members && typeof a.members === 'object') {
            membersObj = a.members;
        }
        return { ...a, members: membersObj };
    });
}

function saveE2EState(state) {
    if (window.__E2E__) {
        if (state.apiaries) {
            state.apiaries = normalizeApiariesForE2E(state.apiaries);
        }
        localStorage.setItem('__E2E_STATE__', JSON.stringify(state));
    }
}

const savedDarkMode = localStorage.getItem('beelog_darkMode') === 'true';
const initialHash = window.location.hash || "";
const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: { darkMode: savedDarkMode, initialHash: initialHash }
});
window.app = app;

const todayStr = new Date().toISOString().split('T')[0];
if (app.ports.todayReceived) {
    app.ports.todayReceived.send(todayStr);
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

app.ports.jsLoadUserSettings.subscribe(async ({ uid, email }) => {
    let currentDarkMode = localStorage.getItem('beelog_darkMode') === 'true';
    const defaultFrameTypes = ["Wielkopolska", "Wielkopolska 18", "Wielkopolska 1/2", "Warszawska zwykła", "MiniPlus", "Dadant"];
    const defaultUlikTypes = ["Mini plus", "Odkład wielkopolski", "Apidea"];
    const defaultBreedLines = ["car. Galicja", "cau. M", "cau. KP", "cau. Woźnica", "car. Słowenka"];
    const defaultHatchingToMatingDays = 12;
    const defaultMaxUlikHistoryLimit = 40;
    const defaultEnableTrutowiska = true;
    const defaultEnablePasieczyskaTowarowe = true;
    if (window.__E2E__) {
        const state = getE2EState();
        const settings = state.userSettings || {
            frameTypes: defaultFrameTypes,
            ulikTypes: defaultUlikTypes,
            breedLines: defaultBreedLines,
            darkMode: currentDarkMode,
            hatchingToMatingDays: defaultHatchingToMatingDays,
            maxUlikHistoryLimit: defaultMaxUlikHistoryLimit,
            enableTrutowiska: defaultEnableTrutowiska,
            enablePasieczyskaTowarowe: defaultEnablePasieczyskaTowarowe
        };
        localStorage.setItem('beelog_darkMode', settings.darkMode ? 'true' : 'false');
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
            if (data.darkMode !== undefined) {
                currentDarkMode = data.darkMode;
            } else {
                await setDoc(docRef, { darkMode: currentDarkMode, email: emailToSave }, { merge: true });
            }
            if (emailToSave && data.email !== emailToSave) {
                await setDoc(docRef, { email: emailToSave }, { merge: true });
            }
        } else {
            await setDoc(docRef, { email: emailToSave, frameTypes: frameTypesVal, ulikTypes: ulikTypesVal, breedLines: breedLinesVal, darkMode: currentDarkMode, hatchingToMatingDays: hatchingToMatingDaysVal, maxUlikHistoryLimit: maxUlikHistoryLimitVal, enableTrutowiska: enableTrutowiskaVal, enablePasieczyskaTowarowe: enablePasieczyskaTowaroweVal });
        }
        localStorage.setItem('beelog_darkMode', currentDarkMode ? 'true' : 'false');
        app.ports.userSettingsReceived.send({ frameTypes: frameTypesVal, ulikTypes: ulikTypesVal, breedLines: breedLinesVal, darkMode: currentDarkMode, hatchingToMatingDays: hatchingToMatingDaysVal, maxUlikHistoryLimit: maxUlikHistoryLimitVal, enableTrutowiska: enableTrutowiskaVal, enablePasieczyskaTowarowe: enablePasieczyskaTowaroweVal });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsSaveUserSettings.subscribe(async ({ uid, email, frameTypes, ulikTypes, breedLines, darkMode, hatchingToMatingDays, maxUlikHistoryLimit, enableTrutowiska, enablePasieczyskaTowarowe }) => {
    if (darkMode !== undefined) {
        localStorage.setItem('beelog_darkMode', darkMode ? 'true' : 'false');
    }
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
            hatchingToMatingDays: hatchingToMatingDays !== undefined ? hatchingToMatingDays : (state.userSettings ? state.userSettings.hatchingToMatingDays : defaultHatchingToMatingDays),
            maxUlikHistoryLimit: maxUlikHistoryLimit !== undefined ? maxUlikHistoryLimit : (state.userSettings ? state.userSettings.maxUlikHistoryLimit : defaultMaxUlikHistoryLimit),
            enableTrutowiska: enableTrutowiska !== undefined ? enableTrutowiska : (state.userSettings ? state.userSettings.enableTrutowiska : defaultEnableTrutowiska),
            enablePasieczyskaTowarowe: enablePasieczyskaTowarowe !== undefined ? enablePasieczyskaTowarowe : (state.userSettings ? state.userSettings.enablePasieczyskaTowarowe : defaultEnablePasieczyskaTowarowe)
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
        if (hatchingToMatingDays !== undefined) dataToSave.hatchingToMatingDays = hatchingToMatingDays;
        if (maxUlikHistoryLimit !== undefined) dataToSave.maxUlikHistoryLimit = maxUlikHistoryLimit;
        if (enableTrutowiska !== undefined) dataToSave.enableTrutowiska = enableTrutowiska;
        if (enablePasieczyskaTowarowe !== undefined) dataToSave.enablePasieczyskaTowarowe = enablePasieczyskaTowarowe;
        await setDoc(docRef, dataToSave, { merge: true });
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
        const q = query(collection(db, "pasieczyska"));
        onSnapshot(q, async (snapshot) => {
            const apiaries = [];
            for (const docSnap of snapshot.docs) {
                const data = docSnap.data();
                const apiaryId = docSnap.id;
                const collaboratorsSnap = await getDocs(collection(db, "pasieczyska", apiaryId, "collaborators"));
                const members = {};
                collaboratorsSnap.forEach(cDoc => {
                    const cData = cDoc.data();
                    members[cDoc.id] = cData.role || "editor";
                });
                if (data.adminId === uid || members[uid]) {
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
                                    name: hData.name || "",
                                    frameType: hData.frameType || "Wielkopolska",
                                    nfcLink: hData.nfcLink || hData.nfcTagId || (baseUrl + '#hive/' + apiaryId + '/' + hDoc.id),
                                    queen: hData.queen || { hasOpalit: false, color: "biały", number: "" },
                                    pollenTrap: hData.pollenTrap || "brak",
                                    order: hData.order !== undefined ? hData.order : 0,
                                    korpusy: hData.korpusy || []
                                });
                            }
                        });
                    } catch (err) {
                        console.error("Error loading hives/uliki for apiary", apiaryId, err);
                    }
                    apiaries.push({
                        id: apiaryId,
                        name: data.name || "",
                        apiaryType: apiaryType,
                        adminId: data.adminId || "",
                        members: members,
                        order: data.order !== undefined ? data.order : 0,
                        uliki: uliki,
                        hives: hives
                    });
                }
            }
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
            members: { [uid]: 'owner' },
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
        await setDoc(doc(db, "pasieczyska", newRef.id, "collaborators", uid), {
            role: "owner"
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
                    name: data.name || "",
                    frameType: data.frameType || "Wielkopolska",
                    nfcLink: data.nfcLink || data.nfcTagId || "",
                    queen: data.queen || { hasOpalit: false, color: "biały", number: "" },
                    pollenTrap: data.pollenTrap || "brak",
                    order: data.order !== undefined ? data.order : 0
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

app.ports.jsCreateHive.subscribe(async ({ apiaryId, name, frameType }) => {
    const baseUrl = window.location.href.split('#')[0];
    if (window.__E2E__) {
        const state = getE2EState();
        if (!state.hives[apiaryId]) state.hives[apiaryId] = [];
        const hiveId = 'hive-' + Math.random().toString(36).substr(2, 9);
        const nfcLink = baseUrl + '#hive/' + apiaryId + '/' + hiveId;
        state.hives[apiaryId].push({
            id: hiveId,
            name: name,
            frameType: frameType || "Wielkopolska",
            nfcLink: nfcLink,
            queen: { hasOpalit: false, color: "Biały", number: "" },
            pollenTrap: "brak",
            order: state.hives[apiaryId].length,
            korpusy: [{ id: "1", hasQueen: false, hasExcluderAbove: false }]
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
            frameType: frameType,
            nfcLink: nfcLink,
            queen: { hasOpalit: false, color: "biały", number: "" },
            pollenTrap: "brak",
            order: 0,
            korpusy: [{ id: "1", hasQueen: false, hasExcluderAbove: false }]
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
    if (window.__E2E__) {
        const state = getE2EState();
        if (state.hives[apiaryId]) {
            state.hives[apiaryId] = state.hives[apiaryId].map(h => {
                if (h.id === hiveId) {
                    if (field.startsWith('queen.')) {
                        const qField = field.split('.')[1];
                        return { ...h, queen: { ...h.queen, [qField]: value } };
                    }
                    return { ...h, [field]: value };
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
        await updateDoc(docRef, { [field]: value });
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

app.ports.jsShareApiary.subscribe(async ({ apiaryId, email, role }) => {
    try {
        await setDoc(doc(db, "pasieczyska", apiaryId, "collaborators", email), {
            role: role
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsRemoveMember.subscribe(async ({ apiaryId, memberKey }) => {
    try {
        await deleteDoc(doc(db, "pasieczyska", apiaryId, "collaborators", memberKey));
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
