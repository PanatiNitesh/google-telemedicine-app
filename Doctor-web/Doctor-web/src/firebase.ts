import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: 'AIzaSyDHlxciXmBtCx7v7wM3OGXXdj3P_QjHRmk',
  appId: '1:709701253315:web:a7db414e7e5ddadd810a76',
  messagingSenderId: '709701253315',
  projectId: 'telemedicine-ai-api',
  authDomain: 'telemedicine-ai-api.firebaseapp.com',
  storageBucket: 'telemedicine-ai-api.firebasestorage.app',
  measurementId: 'G-D7S9QR294P',
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);