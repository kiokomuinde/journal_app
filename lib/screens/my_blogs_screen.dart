import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry.dart';
import 'add_entry_screen.dart';
import 'edit_entry_screen.dart';
import 'blog_detail_screen.dart';

class MyBlogsScreen extends StatelessWidget {
  const MyBlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // Handle case where user is not logged in or currentUser is null
    // This is a safety check, as main.dart should redirect them away
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Journal Entries'),
          actions: [
            // Logout Button (still provided even if not logged in, for consistency)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'Please sign in to view and manage your journal entries.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal Entries'),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Signs out the user
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journal_entries')
            .where('authorId', isEqualTo: currentUser.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error fetching my blogs: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'You haven\'t published any entries yet.\nTap the "+" button to create one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final List<JournalEntry> entries = snapshot.data!.docs.map((doc) {
            return JournalEntry.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlogDetailScreen(entry: entry),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'In ${entry.category}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Published: ${entry.timestamp.toDate().toLocal().toString().split(' ')[0]}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          entry.content.length > 150
                              ? '${entry.content.substring(0, 150)}...'
                              : entry.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (entry.tags.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: entry.tags.map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor: Colors.blue.shade50,
                                labelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              )).toList(),
                            ),
                          ),
                        const Divider(height: 25, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text('Edit'),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditEntryScreen(entry: entry),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton.icon(
                              icon: const Icon(Icons.delete, size: 20),
                              label: const Text('Delete'),
                              onPressed: () {
                                _confirmDelete(context, entry.id);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEntryScreen(),
            ),
          );
        },
        tooltip: 'Add New Journal Entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String entryId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('journal_entries').doc(entryId).delete();
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Entry deleted successfully!')),
                  );
                  Navigator.of(ctx).pop();
                }
              } catch (e) {
                print('Error deleting entry: $e');
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Failed to delete entry: $e')),
                  );
                  Navigator.of(ctx).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
