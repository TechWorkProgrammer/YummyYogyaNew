import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:yummyogya_mobile/dashboard/screens/dashboard_screen.dart';
import 'package:yummyogya_mobile/screens/article.dart';
import 'package:yummyogya_mobile/screens/login.dart';
import 'package:yummyogya_mobile/screens/menu.dart';
import 'package:yummyogya_mobile/screens/search.dart';
import 'package:yummyogya_mobile/wishlist/screens/wishlist_screens.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:yummyogya_mobile/profilepage/screens/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => CookieRequest(),
      child: MaterialApp(
        title: 'Yummyogya',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
          ).copyWith(secondary: Colors.deepPurple[400]),
        ),
        home: FutureBuilder<bool>(
          future: _checkLoginStatus(), // Memeriksa status login
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Tampilkan loading sementara
            } else if (snapshot.hasData && snapshot.data == true) {
              return const MyHomePage(username: 'User'); // Jika sudah login
            } else {
              return const LoginPage(); // Jika belum login
            }
          },
        ),
        routes: {
          '/menu': (context) => const MyHomePage(username: 'User'),
          '/search': (context) => const SearchPage(username: 'User'),
          '/wishlist': (context) => const WishlistScreen(username: 'User'),
          '/article': (context) => const ArticleEntryPage(),
          '/dashboard': (context) => DashboardScreen(username: 'User'),
          '/profile': (context) => ProfileScreen(username: 'User'),
        },
      ),
    );
  }

  // Fungsi untuk memeriksa status login
  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // Ambil status login
    return isLoggedIn;
  }

  // Fungsi untuk menyimpan status login saat berhasil login
  static Future<void> saveLoginStatus(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn); // Simpan status login
  }

  // Fungsi untuk logout dan menghapus status login
  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn'); // Hapus status login saat logout
  }
}
