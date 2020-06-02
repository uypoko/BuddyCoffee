const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

exports.createProfile = functions.auth.user().onCreate((user) => {
  const userObject = {
      email : user.email,
      points: 0,
      latestPoints: 0
  };
  return db.collection('users').doc(user.uid).set(userObject, { merge: true });
});

exports.getPointsForLatestOrder = functions.firestore.
document('users/{userId}/order-history/{order}')
.onCreate((snap, context) => {
  // Get an object representing the document
  // e.g. {'name': 'Marie', 'age': 66}
  const order = snap.data();

  // access a particular field as you would any JS property
  const total = order.total;
  const latestPoints = Math.round(total/10000);
  return db.collection('users').doc(context.params.userId).set({latestPoints: latestPoints}, { merge: true });
});

exports.updatePoints = functions.firestore.document('users/{userId}')
  .onUpdate((change, context) => {
    // The previous value before this update
    const previousData = change.before.data();
    const newData = change.after.data();
    if (newData.latestPoints === 0) {
      return 0
    }
    const currentPoints = previousData.points;
    const latestPoints = newData.latestPoints;
    const newUserData = {
      points: currentPoints + latestPoints,
      latestPoints: 0
    };
    return db.collection('users').doc(context.params.userId).set(newUserData, { merge: true });
});
// return db.collection('users').doc(context.params.userId).set({points: +pointsForOrder}, { merge: true });