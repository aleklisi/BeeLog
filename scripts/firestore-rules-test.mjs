import { deleteApp, initializeApp } from 'firebase/app';
import { connectAuthEmulator, createUserWithEmailAndPassword, getAuth, signOut } from 'firebase/auth';
import { connectFirestoreEmulator, deleteDoc, doc, getDoc, getFirestore, runTransaction, setDoc } from 'firebase/firestore';

const projectId = 'demo-beelog';
const config = { apiKey: 'demo-api-key', authDomain: `${projectId}.firebaseapp.com`, projectId };
const ownerApp = initializeApp(config, 'owner-test');
const otherApp = initializeApp(config, 'other-test');
const ownerAuth = getAuth(ownerApp);
const otherAuth = getAuth(otherApp);
connectAuthEmulator(ownerAuth, 'http://127.0.0.1:9099', { disableWarnings: true });
connectAuthEmulator(otherAuth, 'http://127.0.0.1:9099', { disableWarnings: true });
const ownerDb = getFirestore(ownerApp);
const otherDb = getFirestore(otherApp);
connectFirestoreEmulator(ownerDb, '127.0.0.1', 8080);
connectFirestoreEmulator(otherDb, '127.0.0.1', 8080);

function assert(condition, message) {
    if (!condition) throw new Error(message);
}

async function denied(operation, message) {
    try {
        await operation();
    } catch (error) {
        assert(error.code === 'permission-denied', `${message}: expected permission-denied, got ${error.code}`);
        return;
    }
    throw new Error(`${message}: access unexpectedly succeeded`);
}

try {
    await createUserWithEmailAndPassword(ownerAuth, 'owner@beelog.test', 'test-password-123');
    await createUserWithEmailAndPassword(otherAuth, 'other@beelog.test', 'test-password-123');
    const ownerUid = ownerAuth.currentUser.uid;
    const otherUid = otherAuth.currentUser.uid;
    const collections = ['breederQueens', 'starterColonies', 'finisherColonies', 'rearingBatches', 'rearingSequences'];

    for (const name of collections) {
        const ownerRef = doc(ownerDb, 'users', ownerUid, name, 'authorized-record');
        await setDoc(ownerRef, { ownerUid, kind: name });
        assert((await getDoc(ownerRef)).exists(), `${name}: owner could not read their document`);

        await denied(
            () => getDoc(doc(otherDb, 'users', ownerUid, name, 'authorized-record')),
            `${name}: another user read an owner's document`
        );
        await denied(
            () => setDoc(doc(otherDb, 'users', ownerUid, name, 'cross-user-write'), { ownerUid: otherUid }),
            `${name}: another user wrote to an owner's collection`
        );
    }

    const sequenceRef = doc(ownerDb, 'users', ownerUid, 'rearingSequences', '2026');
    await setDoc(sequenceRef, { year: 2026, lastNumber: 0 });
    const allocations = await Promise.all(['batch-a', 'batch-b'].map((batchId) => runTransaction(ownerDb, async (transaction) => {
        const current = await transaction.get(sequenceRef);
        const nextNumber = (current.exists() ? current.data().lastNumber : 0) + 1;
        transaction.set(sequenceRef, { year: 2026, lastNumber: nextNumber });
        transaction.set(doc(ownerDb, 'users', ownerUid, 'rearingBatches', batchId), { number: `2026/${String(nextNumber).padStart(2, '0')}` });
        return nextNumber;
    })));
    assert(new Set(allocations).size === 2, 'Concurrent batch allocations reused a sequence number');
    assert((await getDoc(sequenceRef)).data().lastNumber === 2, 'Concurrent batch allocations lost a sequence update');

    const starterRef = doc(ownerDb, 'users', ownerUid, 'starterColonies', 'contended-starter');
    await setDoc(starterRef, { availability: 'PUSTY' });
    const reservations = await Promise.allSettled(['reservation-a', 'reservation-b'].map((batchId) => runTransaction(ownerDb, async (transaction) => {
        const starter = await transaction.get(starterRef);
        if (!starter.exists() || starter.data().availability !== 'PUSTY' || starter.data().activeBatchId) {
            throw new Error('Starter is already reserved');
        }
        transaction.update(starterRef, { availability: 'ZAJETY', activeBatchId: batchId });
        transaction.set(doc(ownerDb, 'users', ownerUid, 'rearingBatches', batchId), { status: 'W_STARTERZE', starterColonyId: 'contended-starter' });
    })));
    assert(reservations.filter((result) => result.status === 'fulfilled').length === 1, 'Concurrent starter reservation did not have exactly one winner');
    const winnerId = (await getDoc(starterRef)).data().activeBatchId;
    assert((await getDoc(doc(ownerDb, 'users', ownerUid, 'rearingBatches', winnerId))).exists(), 'Starter reservation committed without its batch record');
    const loserId = winnerId === 'reservation-a' ? 'reservation-b' : 'reservation-a';
    assert(!(await getDoc(doc(ownerDb, 'users', ownerUid, 'rearingBatches', loserId))).exists(), 'Losing reservation left a partial batch record');

    await signOut(ownerAuth);
    await denied(
        () => getDoc(doc(ownerDb, 'users', ownerUid, 'breederQueens', 'authorized-record')),
        'Unauthenticated user read a queen-rearing document'
    );
    await signOut(otherAuth);
    console.log('Firestore owner and cross-user rules passed for all queen-rearing collections.');
} finally {
    await deleteApp(ownerApp);
    await deleteApp(otherApp);
}
