import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

FirebaseFirestore get db =>
    FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'teamup-db');
