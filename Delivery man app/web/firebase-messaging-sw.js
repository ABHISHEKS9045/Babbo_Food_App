importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/7.20.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyBMgCW7DOPoNZNCtYduwQsKBiKG1ClX9p4",
  authDomain: "babbo-food.firebaseapp.com",
  projectId: "babbo-food",
  storageBucket: "babbo-food.appspot.com",
  messagingSenderId: "103865240807",
  appId: "1:103865240807:web:b84223ff9192c794caa642",
  databaseURL: "...",
});

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});