// The Cloud Functions for Firebase SDK to create Cloud Functions
// and setup triggers.
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const admin = require("firebase-admin");

const client = require("firebase-tools");

admin.initializeApp();
const cldfirestore = admin.firestore();

const groupCollection = "groups";
// const tasksCollection = "tasks";
// const chatsCollection = "chats";
// const usersCollection = "users";

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//     functions.logger.info("Hello logs!", { structuredData: true });
//     response.send("Hello from Firebase!");
// });

exports.leaveFromGroup = functions.https.onCall((data, context) => {
  // context.app will be undefined if the request doesn't include a valid
  // App Check token.
  if (context.app == undefined) {
    throw new functions.https.HttpsError(
        "failed-precondition",
        "The function must be called from an App Check verified app.");
  }
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated",
        "The function must be called ", "while authenticated.");
  }
  const authUID = context.auth.uid;
  const groupToLeave = data.groupId;
  if (typeof groupToLeave !== "string" || groupToLeave.length === 0) {
    throw new functions.https.HttpsError("invalid-argument",
        "'groupId' property not provided / invalid", "hence declined.");
  }
  const docRefPath = cldfirestore.collection(groupCollection).doc(groupToLeave);
  return docRefPath.get().then((defaultDocRef) => {
    const presentAdminList = defaultDocRef.get("admins");
    const presentMemberList = defaultDocRef.get("members");
    if (Array.isArray(presentAdminList) && Array.isArray(presentMemberList)) {
      const memberIndex = presentMemberList.indexOf(authUID);
      console.log("presentMemberList: "+presentMemberList);
      console.log("presentAdminList: "+presentAdminList);
      console.log("memberIndex: "+memberIndex);
      if (memberIndex !== -1) {
        presentMemberList.splice(memberIndex, 1);
        console.log("updated presentMemberList: "+presentMemberList);
        if (presentMemberList.length === 1) {
          const lastMemberOfGroup = presentMemberList[0];
          if (lastMemberOfGroup === "DEFAULT_TASKBOOK_UID") {
            return client.firestore.delete(docRefPath.path, {
              project: "todoapp-developer",
              recursive: true,
              yes: true,
            }).then(()=>{
              console.log("deleted whole document");
              return "deleted whole document as only default user was left";
            });
          }
        }
      } else {
        throw new functions.https.HttpsError("permission-denied",
            "User not part of the group", "hence declined");
      }
      const adminIndex = presentAdminList.indexOf(authUID);
      console.log("adminIndex: "+adminIndex);
      if (adminIndex !== -1) {
        presentAdminList.splice(adminIndex, 1);
        console.log("updated presentAdminList: "+presentAdminList);
        if (presentAdminList.length === 0) {
          if (presentMemberList.length !== 0) {
            presentAdminList.push(presentMemberList[0]);
            return docRefPath.update({
              admins: presentAdminList,
              members: presentMemberList,
              updatedOn: admin.firestore.FieldValue.serverTimestamp(),
            }).then(()=>{
              console.log("updated admins and members");
              return "updated admins and members";
            });
          } else {
            console.log("since there are no members, so deleting document");
            return client.firestore.delete(docRefPath.path, {
              project: "todoapp-developer",
              recursive: true,
              yes: true,
            }).then(()=>{
              console.log("deleted whole document");
              return "deleted whole document";
            });
          }
        } else {
          return docRefPath.update({
            admins: presentAdminList,
            members: presentMemberList,
            updatedOn: admin.firestore.FieldValue.serverTimestamp(),
          }).then(()=>{
            console.log("updated admins and members");
            return "updated admins and members";
          });
        }
      } else {
        console.log("updating just members");
        return docRefPath.update({
          members: presentMemberList,
          updatedOn: admin.firestore.FieldValue.serverTimestamp(),
        }).then(()=>{
          console.log("updated members");
          return "updated members";
        });
      }
    } else {
      throw new functions.https.HttpsError("data-loss",
          "current admins or members in bad format", "hence declined.");
    }
  }).catch((error) => console.log("Error: "+error));
});
