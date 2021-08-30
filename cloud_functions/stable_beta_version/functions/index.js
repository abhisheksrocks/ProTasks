const functions = require("firebase-functions");
const admin = require("firebase-admin");
const client = require("firebase-tools");
admin.initializeApp();
const cldfirestore = admin.firestore();
const groupCollection = "groups";

exports.leaveFromGroup = functions.https.onCall((data, context) => {
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
      if (memberIndex !== -1) {
        presentMemberList.splice(memberIndex, 1);
        if (presentMemberList.length === 1) {
          const lastMemberOfGroup = presentMemberList[0];
          if (lastMemberOfGroup === "DEFAULT_TASKBOOK_UID") {
            return client.firestore.delete(docRefPath.path, {
              project: "todoapp-developer",
              recursive: true,
              yes: true,
            }).then(()=>{
              return "deleted whole document as only default user was left";
            });
          }
        }
      } else {
        throw new functions.https.HttpsError("permission-denied",
            "User not part of the group", "hence declined");
      }
      const adminIndex = presentAdminList.indexOf(authUID);
      if (adminIndex !== -1) {
        presentAdminList.splice(adminIndex, 1);
        if (presentAdminList.length === 0) {
          if (presentMemberList.length !== 0) {
            presentAdminList.push(presentMemberList[0]);
            return docRefPath.update({
              admins: presentAdminList,
              members: presentMemberList,
              updatedOn: admin.firestore.FieldValue.serverTimestamp(),
            }).then(()=>{
              return "updated admins and members";
            });
          } else {
            return client.firestore.delete(docRefPath.path, {
              project: "todoapp-developer",
              recursive: true,
              yes: true,
            }).then(()=>{
              return "deleted whole document";
            });
          }
        } else {
          return docRefPath.update({
            admins: presentAdminList,
            members: presentMemberList,
            updatedOn: admin.firestore.FieldValue.serverTimestamp(),
          }).then(()=>{
            return "updated admins and members";
          });
        }
      } else {
        return docRefPath.update({
          members: presentMemberList,
          updatedOn: admin.firestore.FieldValue.serverTimestamp(),
        }).then(()=>{
          return "updated members";
        });
      }
    } else {
      throw new functions.https.HttpsError("data-loss",
          "current admins or members in bad format", "hence declined.");
    }
  }).catch((error) => console.log("Error: "+error));
});
