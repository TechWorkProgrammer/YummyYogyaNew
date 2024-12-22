import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileEditModal extends StatefulWidget {
  final String baseUrl;
  final String username;
  final String currentBio;
  final String currentProfilePhoto;

  const ProfileEditModal({
    super.key,
    required this.baseUrl,
    required this.username,
    required this.currentBio,
    required this.currentProfilePhoto,
  });

  @override
  ProfileEditModalState createState() => ProfileEditModalState();
}

class ProfileEditModalState extends State<ProfileEditModal> {
  final TextEditingController _bioController = TextEditingController();
  bool _isSubmitting = false;
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.currentBio;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleResponse(http.Response response) async {
    final responseData = jsonDecode(response.body);
    final success = responseData['success'] ?? false;
    final message = responseData['message'] ?? 'Unknown error occurred';

    if (mounted) {
      if (success) {
        _showSnackbar(message, Colors.green);
        Navigator.pop(context, true);
      } else {
        _showSnackbar(message, Colors.red);
      }
    }
  }

  Future<void> _removePhoto() async {
    try {
      setState(() {
        _isSubmitting = true;
      });

      final response = await http.post(
        Uri.parse('${widget.baseUrl}/profilepage/profile/update/api'),
        body: jsonEncode({
          'username': widget.username,
          'delete_photo': true,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      await _handleResponse(response);
    } catch (e) {
      _showSnackbar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    try {
      setState(() {
        _isSubmitting = true;
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${widget.baseUrl}/profilepage/profile/update/api'),
      );

      request.fields['username'] = widget.username;
      request.fields['bio'] = _bioController.text;

      if (_selectedPhoto != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_photo',
          _selectedPhoto!.path,
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      await _handleResponse(response);
    } catch (e) {
      _showSnackbar('Terjadi kesalahan: $e', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackbar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedPhoto != null
                    ? FileImage(_selectedPhoto!) as ImageProvider
                    : (widget.currentProfilePhoto.isNotEmpty
                        ? NetworkImage(
                            '${widget.baseUrl}${widget.currentProfilePhoto}')
                        : const AssetImage(
                            'assets/placeholder.png')) as ImageProvider,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: const Text(
                  'Pilih Foto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _removePhoto,
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  'Hapus Foto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Edit Bio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tulis bio Anda...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.deepOrange),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
