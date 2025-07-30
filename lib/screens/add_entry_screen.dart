import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Still needed for authorId

import '../models/journal_entry.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  // Removed: final TextEditingController _imageUrlController = TextEditingController();

  String? _selectedCategory;
  // Removed: File? _pickedImageFile;
  // Removed: bool _isUploadingImage = false;
  // Removed: String? _uploadedImageUrl;

  bool _isSaving = false;

  final List<String> _categories = [
    'Technology', 'Travel', 'Food', 'Personal', 'Lifestyle',
    'Science', 'Art', 'Health', 'Finance', 'Other',
  ];

  final CollectionReference _journalEntriesCollection =
      FirebaseFirestore.instance.collection('journal_entries');
  // Removed: final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.displayName != null && currentUser.displayName!.isNotEmpty) {
      _authorController.text = currentUser.displayName!;
    }
  }

  // Removed: _pickImage() function
  // Removed: _uploadImage() function

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to publish an entry.')),
          );
          Navigator.of(context).pop();
        }
        setState(() { _isSaving = false; });
        return;
      }
      final String currentUserId = currentUser.uid;

      try {
        List<String> tagsList = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();

        // Removed: String? finalImageUrl;
        // Removed: if (_uploadedImageUrl != null) { finalImageUrl = _uploadedImageUrl; }
        // Removed: else if (_imageUrlController.text.isNotEmpty) { finalImageUrl = _imageUrlController.text; }

        final newEntry = JournalEntry(
          id: '',
          title: _titleController.text,
          content: _contentController.text,
          timestamp: Timestamp.now(),
          author: _authorController.text.isNotEmpty
              ? _authorController.text
              : currentUser.displayName ?? currentUser.email ?? 'Anonymous',
          authorId: currentUserId,
          category: _selectedCategory ?? 'General',
          tags: tagsList,
          // Removed: imageUrl: finalImageUrl,
        );

        await _journalEntriesCollection.add(newEntry.toFirestore());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Journal entry published successfully!')),
          );
          Navigator.of(context).pop();
        }
      } catch (e, stackTrace) {
        print('--- Error Saving Journal Entry ---');
        print('Error: $e');
        print('Stack Trace: $stackTrace');
        print('----------------------------------');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to publish entry: ${e.toString()}')),
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
        title: const Text('Publish New Journal Entry'),
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
                          hintText: 'A catchy title for your post',
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
                          hintText: 'Your name or pseudonym',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          hintText: 'Select a category',
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
                          hintText: 'Write your insightful blog post here...',
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
                      // Removed image selection/preview section
                      // Removed ElevatedButton for picking image
                      // Removed TextFormField for Direct Image URL
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
                      onPressed: _saveEntry,
                      icon: const Icon(Icons.send),
                      label: const Text('Publish Entry'),
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
