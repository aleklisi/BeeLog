// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider, signInWithPopup, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut } from "firebase/auth";
import { getFirestore, collection, doc, getDoc, setDoc, addDoc, updateDoc, deleteDoc, query, where, getDocs, onSnapshot } from "firebase/firestore";

// Your web app's Firebase configuration using Vite environment variables
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "AIzaSyBPtzXqSclzeMaRvV7WZnewJdH16lKCj88",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "beelog-4ec14.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "beelog-4ec14",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "beelog-4ec14.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "463631392264",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "1:463631392264:web:fab829b78cd5b4bfe23bbd",
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID || "G-VR1CYQ0V4V"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);
const googleProvider = new GoogleAuthProvider();

export { 
  app, 
  auth, 
  db, 
  googleProvider, 
  signInWithPopup, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signOut,
  collection,
  doc,
  getDoc,
  setDoc,
  addDoc,
  updateDoc,
  deleteDoc,
  query,
  where,
  getDocs,
  onSnapshot
};
