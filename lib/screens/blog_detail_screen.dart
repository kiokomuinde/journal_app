import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
// import 'package:cached_network_image/cached_network_image.dart'; // Optional: for better image loading

class BlogDetailScreen extends StatelessWidget {
  final JournalEntry entry;

  const BlogDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'By ${entry.author} in ${entry.category}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Published: ${entry.timestamp.toDate().toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // // Optional: Display image if available (and if you re-add image functionality later)
            // if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty)
            //   Column(
            //     children: [
            //       ClipRRect(
            //         borderRadius: BorderRadius.circular(10.0),
            //         child: CachedNetworkImage( // Requires cached_network_image package
            //           imageUrl: entry.imageUrl!,
            //           placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            //           errorWidget: (context, url, error) => const Icon(Icons.error),
            //           fit: BoxFit.cover,
            //           width: double.infinity,
            //           height: 250,
            //         ),
            //       ),
            //       const SizedBox(height: 20),
            //     ],
            //   ),

            Text(
              entry.content,
              style: const TextStyle(fontSize: 18, height: 1.5),
            ),
            const SizedBox(height: 20),
            if (entry.tags.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tags:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: entry.tags.map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    )).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
