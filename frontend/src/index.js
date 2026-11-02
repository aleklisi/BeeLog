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

const app = Elm.Main.init({
    node: document.getElementById('app')
});
window.app = app;

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

app.ports.jsLoadApiaries.subscribe(async (uid) => {
    if (window.__E2E__) {
        const state = getE2EState();
        app.ports.apiariesReceived.send(state.apiaries || []);
        return;
    }
    try {
        const q = query(collection(db, "apiaries"));
        onSnapshot(q, (snapshot) => {
            const apiaries = [];
            snapshot.forEach((docSnap) => {
                const data = docSnap.data();
                if (data.adminId === uid || (data.members && data.members[uid])) {
                    apiaries.push({
                        id: docSnap.id,
                        name: data.name || "",
                        adminId: data.adminId || "",
                        members: data.members || {},
                        order: data.order !== undefined ? data.order : 0
                    });
                }
            });
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
            const docRef = doc(db, "apiaries", apiaries[i].id);
            await updateDoc(docRef, { order: i });
        }
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsCreateApiary.subscribe(async ({ name, uid }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        state.apiaries.push({
            id: 'apiary-' + Math.random().toString(36).substr(2, 9),
            name: name,
            adminId: uid,
            members: { [uid]: 'owner' },
            order: state.apiaries.length
        });
        saveE2EState(state);
        app.ports.apiariesReceived.send(state.apiaries);
        return;
    }
    try {
        await addDoc(collection(db, "apiaries"), {
            name: name,
            adminId: uid,
            members: {
                [uid]: "owner"
            },
            order: 0
        });
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
        const docRef = doc(db, "apiaries", apiaryId);
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
        await deleteDoc(doc(db, "apiaries", apiaryId));
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsLoadHives.subscribe(async ({ apiaryId }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        app.ports.hivesReceived.send(state.hives[apiaryId] || []);
        return;
    }
    try {
        const q = collection(db, "apiaries", apiaryId, "yards", "default_yard", "hives");
        onSnapshot(q, (snapshot) => {
            const hives = [];
            snapshot.forEach((docSnap) => {
                const data = docSnap.data();
                hives.push({
                    id: docSnap.id,
                    name: data.name || "",
                    frameType: data.frameType || "Wielkopolska",
                    nfcTagId: data.nfcTagId || "",
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
            const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hives[i].id);
            await updateDoc(docRef, { order: i });
        }
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsCreateHive.subscribe(async ({ apiaryId, name, frameType }) => {
    if (window.__E2E__) {
        const state = getE2EState();
        if (!state.hives[apiaryId]) state.hives[apiaryId] = [];
        state.hives[apiaryId].push({
            id: 'hive-' + Math.random().toString(36).substr(2, 9),
            name: name,
            frameType: frameType || "Wielkopolska",
            nfcTagId: "",
            queen: { hasOpalit: false, color: "Biały", number: "" },
            pollenTrap: "brak",
            order: state.hives[apiaryId].length
        });
        saveE2EState(state);
        app.ports.hivesReceived.send(state.hives[apiaryId]);
        return;
    }
    try {
        await addDoc(collection(db, "apiaries", apiaryId, "yards", "default_yard", "hives"), {
            name: name,
            frameType: frameType,
            nfcTagId: "",
            queen: { hasOpalit: false, color: "biały", number: "" },
            pollenTrap: "brak",
            order: 0
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

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
        const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId, "notes", noteId);
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
        const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId, "notes", noteId);
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
        const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId);
        await updateDoc(docRef, { [field]: value });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsStartNfcScan.subscribe(async () => {
    if ('NDEFReader' in window) {
        try {
            const ndef = new NDEFReader();
            await ndef.scan();
            ndef.onreading = event => {
                const decoder = new TextDecoder();
                for (const record of event.message.records) {
                    if (record.recordType === "text") {
                        const text = decoder.decode(record.data);
                        app.ports.nfcScanned.send(text);
                        break;
                    }
                }
                if (event.serialNumber) {
                    app.ports.nfcScanned.send(event.serialNumber);
                }
            };
        } catch (error) {
            app.ports.operationError.send("Błąd NFC: " + error.message);
        }
    } else {
        app.ports.operationError.send("Web NFC nie jest obsługiwane w tej przeglądarce.");
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
        const q = collection(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId, "notes");
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
        await addDoc(collection(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId, "notes"), {
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
        const docRef = doc(db, "apiaries", apiaryId);
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
            const data = docSnap.data();
            const members = data.members || {};
            members[email] = role;
            await updateDoc(docRef, { members: members });
        }
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsRemoveMember.subscribe(async ({ apiaryId, memberKey }) => {
    try {
        const docRef = doc(db, "apiaries", apiaryId);
        const docSnap = await getDoc(docRef);
        if (docSnap.exists()) {
            const data = docSnap.data();
            const members = data.members || {};
            delete members[memberKey];
            await updateDoc(docRef, { members: members });
        }
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
        const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId);
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
        const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId);
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
