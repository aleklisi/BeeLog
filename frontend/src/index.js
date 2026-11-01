import { Elm } from './Main.elm';
import { auth, db, googleProvider, signInWithPopup, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut, collection, doc, getDoc, setDoc, addDoc, updateDoc, deleteDoc, query, where, getDocs, onSnapshot } from '../../src/firebase.js';
import { onAuthStateChanged } from 'firebase/auth';

const app = Elm.Main.init({
    node: document.getElementById('app')
});

// Auth state observer
onAuthStateChanged(auth, (user) => {
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
    try {
        const docRef = doc(db, "apiaries", apiaryId);
        await updateDoc(docRef, { name: name });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteApiary.subscribe(async ({ apiaryId }) => {
    try {
        await deleteDoc(doc(db, "apiaries", apiaryId));
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsLoadHives.subscribe(async ({ apiaryId }) => {
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
    try {
        const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId, "notes", noteId);
        await updateDoc(docRef, { text: text });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteNote.subscribe(async ({ apiaryId, hiveId, noteId }) => {
    try {
        const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId, "notes", noteId);
        await deleteDoc(docRef);
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsUpdateHive.subscribe(async ({ apiaryId, hiveId, field, value }) => {
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
    try {
        const q = collection(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId, "notes");
        onSnapshot(q, (snapshot) => {
            const notes = [];
            snapshot.forEach((docSnap) => {
                const data = docSnap.data();
                notes.push({
                    id: docSnap.id,
                    text: data.text || "",
                    authorId: data.authorId || "",
                    authorEmail: data.authorEmail || "",
                    timestamp: data.timestamp ? data.timestamp.toDate().toLocaleString() : ""
                });
            });
            app.ports.notesReceived.send(notes);
        });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsSaveNote.subscribe(async ({ apiaryId, hiveId, text, authorId, authorEmail }) => {
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
    try {
        const docRef = doc(db, "apiaries", apiaryId, "yards", "default_yard", "hives", hiveId);
        await updateDoc(docRef, { name: newName });
    } catch (error) {
        app.ports.operationError.send(error.message);
    }
});

app.ports.jsDeleteHive.subscribe(async ({ apiaryId, hiveId }) => {
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
