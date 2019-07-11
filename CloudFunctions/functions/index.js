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
  var userObject = {
      email : user.email,
      points: 0
  };
  return db.collection('users').doc(user.uid).set(userObject);
});

exports.createUserName = functions.firestore
    .document('users/{userId}')
    .onCreate((snap, context) => {
      // Get an object representing the document
      // e.g. {'name': 'Marie', 'age': 66}
    
        const userid = context.params.userId;
        const data = snap.data();
        // We'll only update if the name has changed.
        // This is crucial to prevent infinite loops.
        if (data.name !== null) return null;
        var displayName = '';
        displayName = admin.auth().getUser(userid)
        .then(function(userRecord) {
            return userRecord.displayName;
        })
        .catch(function(error) {
         console.log('Error fetching user data:', error);
        });

        return db.collection('users').doc(userid).set({
            name: displayName
          }, {merge: true});
    });
/*
exports.addNameForUserProfile = functions.firestore
      .document('users/{userId}')
      .onUpdate((change, context) => {
        // Retrieve the current and previous value
        const data = change.after.data();
        const previousData = change.before.data();

        const userid = context.params.userId;
        // We'll only update if the name has changed.
        // This is crucial to prevent infinite loops.
        if (data.name != null) return null;
        var displayName = '';
        displayName = admin.auth().getUser(userid)
        .then(function(userRecord) {
            return userRecord.displayName;
        })
        .catch(function(error) {
         console.log('Error fetching user data:', error);
        });

        // Then return a promise of a set operation to update the count
        return change.after.ref.set({
          name: displayName
        }, {merge: true});
      });
      */