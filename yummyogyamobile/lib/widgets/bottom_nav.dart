import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex; // Indeks halaman aktif
  final Function(int) onTap; // Callback untuk mengelola tap

  const BottomNav({Key? key, required this.currentIndex, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Untuk menampilkan semua item
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Wishlist',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: currentIndex, // Indeks halaman aktif
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: onTap, // Callback saat item ditekan
    );
  }
}
