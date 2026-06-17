import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/core/firebase/firestore.dart';
import 'package:teamup/features/messaging/models/conversation_model.dart';
import 'package:teamup/features/messaging/models/message_model.dart';

class MessagingService {
  MessagingService({FirebaseFirestore? firestore}) : _firestore = firestore ?? db;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _convRef => _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> _msgRef(String conversationId) => _convRef.doc(conversationId).collection('messages');

  /// Deterministic ID so both parties read/write to the same conversation.
  String bookingConversationId(String bookingId) => 'booking_$bookingId';

  Stream<ConversationModel?> streamConversation(String conversationId) {
    return _convRef.doc(conversationId).snapshots().map((doc) => doc.exists ? ConversationModel.fromFirestore(doc) : null);
  }

  /// Stream messages oldest → newest for chronological rendering. The
  /// `arrayContains` filter is required so Firestore security rules can
  /// statically prove the query stays within docs the user is allowed to
  /// read (we mirror `participantIds` onto each message).
  Stream<List<MessageModel>> streamMessages({required String conversationId, required String userId}) {
    return _msgRef(
      conversationId,
    ).where('participantIds', arrayContains: userId).orderBy('sentAt').snapshots().map((snap) => snap.docs.map(MessageModel.fromFirestore).toList());
  }

  /// Send a message in a booking conversation. Creates the conversation
  /// document on first send so we don't write empty conversations on screen
  /// open. Returns the conversation id and the persisted message.
  Future<({String conversationId, MessageModel message})> sendBookingMessage({
    required String bookingId,
    required String senderId,
    required List<String> participantIds,
    required String text,
  }) async {
    final convId = bookingConversationId(bookingId);
    final convRef = _convRef.doc(convId);
    final msgRef = _msgRef(convId).doc();
    final now = DateTime.now();

    final message = MessageModel(id: msgRef.id, senderId: senderId, text: text, participantIds: participantIds, sentAt: now);

    // Write the message first — this is what the chat actually reads, and the
    // rules allow it as long as the sender lists themselves in participantIds.
    // We deliberately do NOT read the conversation: a freshly-joined player
    // isn't in the stored participantIds yet, so a transactional get() would be
    // permission-denied even though they're a legitimate member.
    await msgRef.set(message.toJson());

    // The conversation doc is just inbox metadata (last-message preview). Upsert
    // it best-effort with arrayUnion so new members are added without clobbering
    // others; never block the send if this write is rejected.
    try {
      await convRef.set({
        'kind': ConversationKind.booking.name,
        'bookingId': bookingId,
        'participantIds': FieldValue.arrayUnion(participantIds),
        'lastMessageText': text,
        'lastMessageSenderId': senderId,
        'lastMessageAt': Timestamp.fromDate(now),
        'createdAt': Timestamp.fromDate(now),
      }, SetOptions(merge: true));
    } catch (_) {
      // Metadata only — the message is already delivered.
    }

    return (conversationId: convId, message: message);
  }
}
