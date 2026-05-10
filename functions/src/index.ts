import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as logger from "firebase-functions/logger";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();

const DATABASE_ID = "teamup-db";

/**
 * On notification doc creation, look up the recipient user's FCM tokens
 * and dispatch a push. The in-app `NotificationToastListener` already
 * handles the foreground case via Firestore listeners — here we only
 * need to surface things at the OS level when the app is backgrounded
 * or closed.
 */
export const onNotificationCreated = onDocumentCreated(
  {
    document: "notifications/{notificationId}",
    database: DATABASE_ID,
    region: "us-central1",
  },
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const notif = snap.data();
    const recipientId: string | undefined = notif.recipientId;
    const title: string = notif.title ?? "TeamUp";
    const body: string = notif.body ?? "";
    const bookingId: string | undefined = notif.bookingId;
    const conversationId: string | undefined = notif.conversationId;

    if (!recipientId) {
      logger.warn("Notification missing recipientId", {
        id: event.params.notificationId,
      });
      return;
    }

    const db = getFirestore(DATABASE_ID);
    const userSnap = await db.collection("users").doc(recipientId).get();
    if (!userSnap.exists) {
      logger.warn("Recipient user not found", { recipientId });
      return;
    }

    const tokens: string[] = userSnap.data()?.fcmTokens ?? [];
    if (tokens.length === 0) {
      logger.info("Recipient has no registered FCM tokens", { recipientId });
      return;
    }

    const dataPayload: Record<string, string> = {};
    if (bookingId) dataPayload.bookingId = bookingId;
    if (conversationId) dataPayload.conversationId = conversationId;

    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: dataPayload,
    });

    // Prune tokens that FCM has rejected as invalid.
    const invalid: string[] = [];
    response.responses.forEach((r, i) => {
      if (!r.success) {
        const code = r.error?.code ?? "";
        if (
          code === "messaging/registration-token-not-registered" ||
          code === "messaging/invalid-registration-token"
        ) {
          invalid.push(tokens[i]);
        } else {
          logger.warn("FCM send failed for token", {
            token: tokens[i],
            code,
          });
        }
      }
    });
    if (invalid.length > 0) {
      await db
        .collection("users")
        .doc(recipientId)
        .update({
          fcmTokens: tokens.filter((t) => !invalid.includes(t)),
        });
    }

    logger.info("Push dispatched", {
      recipientId,
      success: response.successCount,
      failure: response.failureCount,
    });
  }
);
