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

  /// Stream messages oldest → newest for chronological rendering.
  Stream<List<MessageModel>> streamMessages(String conversationId) {
    return _msgRef(conversationId).orderBy('sentAt').snapshots().map((snap) => snap.docs.map(MessageModel.fromFirestore).toList());
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

    final message = MessageModel(id: msgRef.id, senderId: senderId, text: text, sentAt: now);

    await _firestore.runTransaction((txn) async {
      final convSnap = await txn.get(convRef);
      if (!convSnap.exists) {
        final conversation = ConversationModel(
          id: convId,
          kind: ConversationKind.booking,
          bookingId: bookingId,
          participantIds: participantIds,
          lastMessageText: text,
          lastMessageSenderId: senderId,
          lastMessageAt: now,
          createdAt: now,
        );
        txn.set(convRef, conversation.toJson());
      } else {
        txn.update(convRef, {
          'lastMessageText': text,
          'lastMessageSenderId': senderId,
          'lastMessageAt': Timestamp.fromDate(now),
          // Keep participants in sync if they expand later (e.g. game joins).
          'participantIds': participantIds,
        });
      }
      txn.set(msgRef, message.toJson());
    });

    return (conversationId: convId, message: message);
  }
}
