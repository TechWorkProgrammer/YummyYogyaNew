import 'package:flutter/material.dart';

class DetailCard extends StatelessWidget {
  final Map<String, dynamic> foodData;

  const DetailCard({required this.foodData, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            foodData['image_url'] ?? '',
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.fastfood,
              size: 100,
              color: Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          foodData['name'] ?? '',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Harga: Rp ${foodData['price'] ?? 0}',
          style: const TextStyle(fontSize: 20, color: Colors.green),
        ),
        const SizedBox(height: 8),
        Text(
          'Rating: ${foodData['rating']}',
          style: const TextStyle(fontSize: 18, color: Colors.orange),
        ),
        const SizedBox(height: 16),
        Text(
          foodData['description'] ?? 'Deskripsi tidak tersedia',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }
}
