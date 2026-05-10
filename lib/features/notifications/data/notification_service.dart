import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/core/firebase/firestore.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore}) : _firestore = firestore ?? db;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref => _firestore.collection('notifications');

  /// Stream a user's notifications, newest first.
  Stream<List<NotificationModel>> streamForUser(String userId) {
    return _ref
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromFirestore).toList());
  }

  /// Stream the unread count for the bell badge.
  Stream<int> streamUnreadCount(String userId) {
    return _ref.where('recipientId', isEqualTo: userId).where('read', isEqualTo: false).snapshots().map((snap) => snap.size);
  }

  Future<NotificationModel> create(NotificationModel notification) async {
    final doc = _ref.doc();
    final created = notification.copyWith(id: doc.id);
    await doc.set(created.toJson());
    return created;
  }

  Future<void> markRead(String id) {
    return _ref.doc(id).update({'read': true});
  }

  Future<void> markAllRead(String userId) async {
    final unread = await _ref.where('recipientId', isEqualTo: userId).where('read', isEqualTo: false).get();
    if (unread.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
