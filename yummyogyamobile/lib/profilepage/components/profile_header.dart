import 'package:flutter/material.dart';
import 'package:yummyogya_mobile/profilepage/components/change_password_modal.dart';
import 'package:yummyogya_mobile/profilepage/components/profile_edit_modal.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final String baseUrl;
  final Function onProfileUpdated;

  const ProfileHeader({
    super.key,
    required this.profileData,
    required this.baseUrl,
    required this.onProfileUpdated,
  });

  void _openEditProfileModal(BuildContext currentContext) async {
    final result = await showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      builder: (modalContext) => ProfileEditModal(
        baseUrl: baseUrl,
        username: profileData['username'],
        currentBio: profileData['bio'] ?? '',
        currentProfilePhoto: profileData['profile_photo'] ?? '',
      ),
    );

    if (result == true) {
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        onProfileUpdated();
      }
    }
  }

  void _openChangePasswordModal(BuildContext currentContext) async {
    final result = await showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      builder: (modalContext) => ChangePasswordModal(
        baseUrl: baseUrl,
        username: profileData['username'],
      ),
    );

    if (result == true) {
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(content: Text('Password berhasil diubah!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: profileData['profile_photo'] != null
              ? NetworkImage('$baseUrl${profileData['profile_photo']}')
              : null,
          backgroundColor: Colors.grey[300],
          child: profileData['profile_photo'] == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Text(
              'Bergabung Sejak: ${profileData['date_joined'] ?? 'Tidak diketahui'}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.access_time, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Text(
              'Terakhir Login: ${profileData['last_login'] ?? 'Tidak diketahui'}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openEditProfileModal(context),
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
              onPressed: () => _openChangePasswordModal(context),
              icon: const Icon(Icons.lock, color: Colors.white),
              label: const Text(
                'Change Password',
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
