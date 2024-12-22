import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yummyogya_mobile/profilepage/screens/profile_screen.dart';
import 'package:yummyogya_mobile/screens/login.dart';

class LeftDrawer extends StatefulWidget {
  final String username;

  const LeftDrawer({super.key, required this.username});

  @override
  LeftDrawerState createState() => LeftDrawerState();
}

class LeftDrawerState extends State<LeftDrawer> {
  final String baseUrl = 'http://192.168.1.10:8000';
  String? profilePhoto;
  bool isLoadingProfilePhoto = true;

  @override
  void initState() {
    super.initState();
    fetchProfilePhoto();
  }

  Future<void> fetchProfilePhoto() async {
    final url = '$baseUrl/profilepage/profile/api/?username=${widget.username}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          profilePhoto = data['data']['profile_photo'];
          isLoadingProfilePhoto = false;
        });
      } else {
        setState(() {
          isLoadingProfilePhoto = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingProfilePhoto = false;
      });
    }
  }

  Future<void> logout(BuildContext context) async {
    final String logoutUrl = '$baseUrl/authentication/logout_flutter/';

    try {
      final response = await http.post(Uri.parse(logoutUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Logout gagal: ${data['message']}")),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.orange,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: isLoadingProfilePhoto
                      ? null
                      : (profilePhoto != null && profilePhoto!.isNotEmpty
                          ? NetworkImage('$baseUrl$profilePhoto')
                          : null),
                  backgroundColor: Colors.grey[300],
                  child: isLoadingProfilePhoto
                      ? const CircularProgressIndicator(color: Colors.white)
                      : (profilePhoto == null || profilePhoto!.isEmpty
                          ? const Icon(Icons.person,
                              size: 30, color: Colors.white)
                          : null),
                ),
                const SizedBox(height: 10),
                Text(
                  'Selamat Datang, ${widget.username}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profil'),
            onTap: () {
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(username: widget.username),
                  ),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Kembali ke Homepage'),
            onTap: () {
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/menu',
                  (route) => false,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await logout(context);
            },
          ),
        ],
      ),
    );
  }
}
