import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid; // Firebase User ID (matching FirebaseAuth.currentUser.uid)
  final String email;
  final String fullName;
  final Timestamp createdAt; // When the user account was created

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.createdAt,
  });

  // Factory constructor to create AppUser from a Firestore DocumentSnapshot
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id, // The document ID is the user's UID
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Method to convert AppUser to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'createdAt': createdAt,
    };
  }
}
