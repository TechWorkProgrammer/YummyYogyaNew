import 'package:flutter/material.dart';
import 'package:yummyogya_mobile/detail/screens/detail_makanan.dart';
import 'package:yummyogya_mobile/wishlist/screens/wishlist_screens.dart';

class WishlistList extends StatelessWidget {
  final List<dynamic> wishlist;
  final String username;

  const WishlistList({
    super.key,
    required this.wishlist,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wishlist',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        wishlist.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: wishlist.length,
                itemBuilder: (context, index) {
                  final item = wishlist[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            foodId: item['id'].toString(),
                            username: username,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.orange[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          'Price: Rp ${item['price']}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(
                          Icons.favorite,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Wishlist masih kosong.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WishlistScreen(username: username),
              ),
            );
          },
          child: Center(
            child: Text(
              'Buka Semua Wishlist',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
