import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final String baseUrl;

  const ProfileHeader({
    super.key,
    required this.profileData,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: profileData['profile_photo'] != null
              ? NetworkImage('$baseUrl${profileData['profile_photo']}')
              : const AssetImage('assets/placeholder.png') as ImageProvider,
        ),
        const SizedBox(height: 16),
        Text(
          profileData['username'] ?? 'Unknown User',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profileData['bio'] ?? 'Tidak ada bio',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.lock, color: Colors.white),
              label: const Text(
                'Edit Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
