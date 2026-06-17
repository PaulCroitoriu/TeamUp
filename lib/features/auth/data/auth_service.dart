import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teamup/core/enums/gender.dart';
import 'package:teamup/core/enums/skill_level.dart';
import 'package:teamup/core/enums/sport.dart';
import 'package:teamup/core/firebase/firestore.dart';
import 'package:teamup/features/auth/models/business_model.dart';
import 'package:teamup/features/auth/models/user_model.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore}) : _auth = auth ?? FirebaseAuth.instance, _firestore = firestore ?? db;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersRef => _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _businessesRef => _firestore.collection('businesses');

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Register a player account.
  Future<UserModel> signUpPlayer({required String email, required String password, required String firstName, required String lastName}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName('$firstName $lastName');

    final user = UserModel(
      uid: cred.user!.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: UserRole.player,
      createdAt: DateTime.now(),
    );

    await _usersRef.doc(user.uid).set(user.toJson());
    return user;
  }

  /// Register a business account — creates both user + business docs
  /// atomically in a batch write.
  Future<UserModel> signUpBusiness({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String businessName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName('$firstName $lastName');

    final businessDoc = _businessesRef.doc();
    final business = BusinessModel(id: businessDoc.id, name: businessName, ownerUid: cred.user!.uid, createdAt: DateTime.now());

    final user = UserModel(
      uid: cred.user!.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: UserRole.business,
      businessId: businessDoc.id,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(_usersRef.doc(user.uid), user.toJson());
    batch.set(businessDoc, business.toJson());
    await batch.commit();

    return user;
  }

  Future<UserModel> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return getUserProfile(cred.user!.uid);
  }

  Future<UserModel> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found for uid: $uid');
    }
    return UserModel.fromFirestore(doc);
  }

  /// Update the editable fields of a player profile and return the fresh model.
  /// Writes only the profile fields (never role/email/createdAt/fcmTokens) so a
  /// profile edit can't clobber device push tokens registered elsewhere. Pass
  /// the new [photoUrl] after uploading to Storage; null clears it.
  Future<UserModel> updateProfile({
    required String uid,
    required String firstName,
    required String lastName,
    String? phone,
    String? photoUrl,
    Gender? gender,
    DateTime? birthDate,
    String? bio,
    required Map<Sport, SkillLevel> levels,
  }) async {
    await _usersRef.doc(uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'photoUrl': photoUrl,
      'gender': gender?.name,
      'birthDate': birthDate == null ? null : Timestamp.fromDate(birthDate),
      'bio': bio,
      'levels': {for (final e in levels.entries) e.key.name: e.value.name},
    });
    return getUserProfile(uid);
  }

  /// Toggle whether player bookings auto-confirm for this business.
  Future<void> setAutoConfirmBookings(String businessId, bool value) {
    return _businessesRef.doc(businessId).update({'autoConfirmBookings': value});
  }

  /// Set the minimum notice (in hours) a player must give to cancel.
  Future<void> setCancellationNoticeHours(String businessId, int hours) {
    return _businessesRef.doc(businessId).update({'cancellationNoticeHours': hours});
  }

  /// Update the editable details of a business profile and return the fresh
  /// model. Never touches ownerUid/createdAt or the booking-policy flags
  /// (those have their own setters).
  Future<BusinessModel> updateBusiness({
    required String id,
    required String name,
    String? phone,
    String? email,
    String? address,
    String? website,
    String? vatNumber,
    String? registrationNumber,
  }) async {
    await _businessesRef.doc(id).update({
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'vatNumber': vatNumber,
      'registrationNumber': registrationNumber,
    });
    return getBusiness(id);
  }

  Future<BusinessModel> getBusiness(String id) async {
    final doc = await _businessesRef.doc(id).get();
    if (!doc.exists) {
      throw Exception('Business not found: $id');
    }
    return BusinessModel.fromFirestore(doc);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Fetch a set of user profiles by id (e.g. the players in a game's roster
  /// or pending join requests). `whereIn` supports up to 30 ids per query, so
  /// the ids are chunked; missing ids are simply absent from the result.
  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    final unique = ids.toSet().toList();
    if (unique.isEmpty) return const [];
    final users = <UserModel>[];
    for (var i = 0; i < unique.length; i += 30) {
      final chunk = unique.sublist(i, (i + 30).clamp(0, unique.length));
      final snap = await _usersRef.where(FieldPath.documentId, whereIn: chunk).get();
      users.addAll(snap.docs.map(UserModel.fromFirestore));
    }
    return users;
  }

  /// Look up a user by phone number for the owner-side "ad-hoc booking"
  /// flow. Returns null if no match. The query is exact-match on the
  /// stored `phone` field; normalise on the caller side if needed.
  Future<UserModel?> findUserByPhone(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return null;
    final snap = await _usersRef.where('phone', isEqualTo: trimmed).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return UserModel.fromFirestore(snap.docs.first);
  }
}
