import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id; // Document ID from Firestore
  final String title;
  final String content;
  final Timestamp timestamp; // Use Firestore's Timestamp for dates
  final String author; // Display Name (will be set from user's full name)
  final String authorId; // User ID from Firebase Auth
  final String category;
  final List<String> tags;
  // Removed: final String? imageUrl;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    required this.author,
    required this.authorId,
    required this.category,
    this.tags = const [],
    // Removed: this.imageUrl,
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      author: data['author'] ?? 'Anonymous',
      authorId: data['authorId'] ?? '',
      category: data['category'] ?? 'General',
      tags: List<String>.from(data['tags'] ?? []),
      // Removed: imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp,
      'author': author,
      'authorId': authorId,
      'category': category,
      'tags': tags,
      // Removed: 'imageUrl': imageUrl,
    };
  }
}
