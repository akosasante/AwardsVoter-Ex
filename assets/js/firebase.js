// Firebase App (the core Firebase SDK) is always required and must be listed first
import firebase from "firebase/app";

// Add the Firebase products that you want to use
import "firebase/auth";

// Pulled from firebase config settings
// For Firebase JavaScript SDK v7.20.0 and later, `measurementId` is an optional field
const firebaseConfig = {
    apiKey: "AIzaSyCJjzIEEjytte644CoqerQRCsRoTnS_VqA",
    authDomain: "awardsvoter.firebaseapp.com",
    projectId: "awardsvoter",
    storageBucket: "awardsvoter.appspot.com",
    messagingSenderId: "706770339906",
    appId: "1:706770339906:web:0811fe4e27c58a2235c5db"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

const auth = firebase.auth();

export function signInWithEmailPassword(email, password) {
    return auth.createUserWithEmailAndPassword(email, password).then(userCredential => {
        console.log('signed up')
        return userCredential
    }).catch(err => {
        if (err.code === 'auth/email-already-in-use') {
            console.log('just signing in')
            return auth.signInWithEmailAndPassword(email, password).then(userCredential => {
                return userCredential
            })
        } else {
            throw err
        }
    });
}
