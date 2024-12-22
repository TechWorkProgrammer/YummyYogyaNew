import 'package:flutter/material.dart';

class ReviewList extends StatelessWidget {
  final List<dynamic> reviews;

  const ReviewList({required this.reviews, super.key});

  @override
  Widget build(BuildContext context) {
    return reviews.isNotEmpty
        ? Column(
            children: reviews.map((review) {
              return Card(
                color: Colors.grey[100],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: Text(
                      review['user']?.substring(0, 1)?.toUpperCase() ?? 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '${review['user']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${review['review']}'),
                  trailing: Text(
                    '${review['rating']} ★',
                    style: const TextStyle(fontSize: 18, color: Colors.orange),
                  ),
                ),
              );
            }).toList(),
          )
        : const Text(
            'Belum ada ulasan.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          );
  }
}
