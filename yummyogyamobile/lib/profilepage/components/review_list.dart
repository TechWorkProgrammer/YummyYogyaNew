import 'package:flutter/material.dart';

class ReviewList extends StatelessWidget {
  final List<dynamic> reviews;
  final String searchQuery;
  final String filter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onFilterChanged;

  const ReviewList({
    super.key,
    required this.reviews,
    required this.searchQuery,
    required this.filter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  List<dynamic> filterAndSearch(
      List<dynamic> list, String query, String filter) {
    List<dynamic> filteredList = list.where((item) {
      if (filter == 'all') return true;
      if (filter == 'high_rating' && item['rating'] >= 4) return true;
      if (filter == 'low_rating' && item['rating'] < 4) return true;
      return false;
    }).toList();

    filteredList.sort((a, b) {
      if (filter == 'highest') return b['rating'].compareTo(a['rating']);
      if (filter == 'lowest') return a['rating'].compareTo(b['rating']);
      return 0;
    });

    return filteredList
        .where((item) =>
            query.isEmpty ||
            item['food_name'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReviews = filterAndSearch(reviews, searchQuery, filter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: onSearchChanged,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.orange),
                    hintText: 'Cari review...',
                    hintStyle: TextStyle(color: Colors.black54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _showFilterDialog(context),
              icon: const Icon(Icons.filter_list, color: Colors.white),
              label:
                  const Text('Filter', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        filteredReviews.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredReviews.length,
                itemBuilder: (context, index) {
                  final review = filteredReviews[index];
                  return Card(
                    color: Colors.orange[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: ListTile(
                      title: Text(
                        review['food_name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      subtitle: Text(
                        '${review['rating']} Stars\n${review['review']}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: const Icon(Icons.star, color: Colors.orange),
                    ),
                  );
                },
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    searchQuery.isEmpty
                        ? 'Belum ada review.'
                        : 'Tidak ada review yang cocok dengan pencarian.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Semua'),
                value: 'all',
                groupValue: filter,
                onChanged: (value) {
                  onFilterChanged(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Rating Tinggi'),
                value: 'high_rating',
                groupValue: filter,
                onChanged: (value) {
                  onFilterChanged(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Rating Rendah'),
                value: 'low_rating',
                groupValue: filter,
                onChanged: (value) {
                  onFilterChanged(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Tertinggi'),
                value: 'highest',
                groupValue: filter,
                onChanged: (value) {
                  onFilterChanged(value);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Terendah'),
                value: 'lowest',
                groupValue: filter,
                onChanged: (value) {
                  onFilterChanged(value);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
