import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/journal_entry.dart';

class EditEntryScreen extends StatefulWidget {
  final JournalEntry entry; // The existing entry to edit

  const EditEntryScreen({super.key, required this.entry});

  @override
  State<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends State<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  // Removed: final TextEditingController _imageUrlController = TextEditingController();

  String? _selectedCategory;

  bool _isSaving = false; // Renamed from _isSaving to _isUpdating for clarity

  final List<String> _categories = [
    'Technology', 'Travel', 'Food', 'Personal', 'Lifestyle',
    'Science', 'Art', 'Health', 'Finance', 'Other',
  ];

  final CollectionReference _journalEntriesCollection =
      FirebaseFirestore.instance.collection('journal_entries');

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing entry data
    _titleController.text = widget.entry.title;
    _contentController.text = widget.entry.content;
    _authorController.text = widget.entry.author;
    _tagsController.text = widget.entry.tags.join(', '); // Convert list to comma-separated string
    _selectedCategory = widget.entry.category;
    // Removed: _imageUrlController.text = widget.entry.imageUrl ?? '';
  }


  Future<void> _updateEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true; // Use _isSaving state, but implies updating now
      });

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.uid != widget.entry.authorId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You are not authorized to edit this entry.')),
          );
          Navigator.of(context).pop();
        }
        setState(() { _isSaving = false; });
        return;
      }

      try {
        List<String> tagsList = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

        // Create a map of data to update
        Map<String, dynamic> updatedData = {
          'title': _titleController.text,
          'content': _contentController.text,
          'author': _authorController.text.isNotEmpty
              ? _authorController.text
              : currentUser.displayName ?? currentUser.email ?? 'Anonymous',
          'category': _selectedCategory ?? 'General',
          'tags': tagsList,
          'timestamp': Timestamp.now(), // Update timestamp on modification
          // Removed: 'imageUrl': _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
        };

        // Update the existing document in Firestore
        await _journalEntriesCollection.doc(widget.entry.id).update(updatedData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Journal entry updated successfully!')),
          );
          Navigator.of(context).pop(); // Go back to MyBlogsScreen
        }
      } catch (e, stackTrace) {
        print('--- Error Updating Journal Entry ---');
        print('Error: $e');
        print('Stack Trace: $stackTrace');
        print('------------------------------------');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update entry: ${e.toString()}')),
          );
        }
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _tagsController.dispose();
    // Removed: _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Journal Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Blog Title',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: 'Author Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _contentController,
                        maxLines: 15,
                        minLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Blog Content',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.article),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Content cannot be empty';
                          }
                          return null;
                        },
                      ),
                      // Removed image URL field from here
                    ],
                  ),
                ),
              ),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 30),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma-separated)',
                      hintText: 'e.g., flutter, firebase, mobile development',
                      prefixIcon: Icon(Icons.tag),
                    ),
                  ),
                ),
              ),

              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _updateEntry, // Call update function
                      icon: const Icon(Icons.save),
                      label: const Text('Update Entry'), // Changed button text
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
