import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamup/core/firebase/firestore.dart';
import 'package:teamup/features/notifications/models/notification_model.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore}) : _firestore = firestore ?? db;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _ref => _firestore.collection('notifications');

  /// Stream a user's notifications, newest first. Sorted/limited client-side so
  /// a single-field query suffices (no composite index needed).
  Stream<List<NotificationModel>> streamForUser(String userId) {
    return _ref.where('recipientId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs.map(NotificationModel.fromFirestore).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list.take(50).toList();
    });
  }

  /// Stream the unread count for the bell badge. Filtered client-side to avoid a
  /// composite index.
  Stream<int> streamUnreadCount(String userId) {
    return _ref
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromFirestore).where((n) => !n.read).length);
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
    final snap = await _ref.where('recipientId', isEqualTo: userId).get();
    final unread = snap.docs.where((d) => d.data()['read'] != true).toList();
    if (unread.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in unread) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }
}
