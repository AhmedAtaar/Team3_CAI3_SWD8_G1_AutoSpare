
"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();


function towStatusAr(status) {
  switch (status) {
    case "pending":
      return "قيد المراجعة";
    case "accepted":
      return "مقبول";
    case "onTheWay":
      return "في الطريق";
    case "completed":
      return "تمت الخدمة";
    case "cancelled":
      return "ملغي";
    case "rejected":
      return "مرفوض";
    default:
      return status || "";
  }
}


function extractTokens(fcmTokensField) {
  if (!fcmTokensField) {
    return [];
  }

  if (Array.isArray(fcmTokensField)) {
    return fcmTokensField.filter((t) => typeof t === "string");
  }

  if (typeof fcmTokensField === "object") {
    return Object.keys(fcmTokensField)
      .filter((k) => fcmTokensField[k] === true || fcmTokensField[k] === 1);
  }

  return [];
}


exports.onTowRequestCreated = functions.firestore
  .document("tow_requests/{requestId}")
  .onCreate(async (snap, context) => {
    const data = snap.data();
    const requestId = context.params.requestId;

    if (!data) {
      console.log("No data in new tow_request", requestId);
      return;
    }

    const companyId = data.companyId;
    if (!companyId) {
      console.log("No companyId in tow_request", requestId);
      return;
    }

    try {
      const companyDoc = await db
        .collection("tow_companies")
        .doc(companyId)
        .get();

      if (!companyDoc.exists) {
        console.log("Company not found for request", requestId, companyId);
        return;
      }

      const company = companyDoc.data();
      const tokens = extractTokens(company.fcmTokens);

      if (!tokens.length) {
        console.log("No FCM tokens for company", companyId);
        return;
      }

      const vehicle = data.vehicle || "مركبة";
      const title = "طلب سحب جديد";
      const body = "عميل جديد طلب خدمة سحب للمركبة: " + vehicle;

      const message = {
        tokens: tokens,
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: "tow_new",
          requestId: requestId,
          companyId: companyId,
        },
      };

      const resp = await admin.messaging().sendEachForMulticast(message);
      console.log(
        "Sent new tow_request notification",
        requestId,
        "success:",
        resp.successCount,
        "fail:",
        resp.failureCount,
      );
    } catch (err) {
      console.error("Error sending company notification", err);
    }
  });


exports.onTowRequestStatusChanged = functions.firestore
  .document("tow_requests/{requestId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const requestId = context.params.requestId;

    if (!before || !after) {
      console.log("Missing data in tow_request update", requestId);
      return;
    }

    if (before.status === after.status) {
      console.log("Status did not change for request", requestId);
      return;
    }

    const userId = after.userId;
    if (!userId) {
      console.log("No userId in tow_request", requestId);
      return;
    }

    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (!userDoc.exists) {
        console.log("User not found for tow_request", requestId, userId);
        return;
      }

      const user = userDoc.data();
      const tokens = extractTokens(user.fcmTokens);

      if (!tokens.length) {
        console.log("No FCM tokens for user", userId);
        return;
      }

      const companyName = after.companyNameSnapshot || "شركة الونش";
      const newStatus = towStatusAr(after.status);
      const title = "تحديث طلب السحب";
      const body =
        "تم تحديث حالة طلب السحب مع " +
        companyName +
        " إلى: " +
        newStatus;

      const message = {
        tokens: tokens,
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: "tow_status",
          requestId: requestId,
          status: after.status || "",
        },
      };

      const resp = await admin.messaging().sendEachForMulticast(message);
      console.log(
        "Sent status update notification",
        requestId,
        "success:",
        resp.successCount,
        "fail:",
        resp.failureCount,
      );
    } catch (err) {
      console.error("Error sending user notification", err);
    }
  });
