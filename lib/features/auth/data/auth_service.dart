import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
}
