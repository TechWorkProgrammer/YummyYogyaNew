import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

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
  Uint8List? _webSelectedPhoto;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.currentBio;
  }

  Future<void> _pickPhoto() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.bytes != null) {
        setState(() {
          _webSelectedPhoto = result.files.single.bytes!;
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() {
          _selectedPhoto = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri =
          Uri.parse('${widget.baseUrl}/profilepage/profile/update/api/');
      final request = http.MultipartRequest('POST', uri);

      request.fields['username'] = widget.username;
      request.fields['bio'] = _bioController.text;

      if (kIsWeb && _webSelectedPhoto != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'profile_photo',
          _webSelectedPhoto!,
          filename: 'uploaded_image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      } else if (_selectedPhoto != null) {
        final mimeType = lookupMimeType(_selectedPhoto!.path) ?? 'image/jpeg';
        final fileName = path.basename(_selectedPhoto!.path);
        request.files.add(await http.MultipartFile.fromPath(
          'profile_photo',
          _selectedPhoto!.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ));
      }

      request.headers.addAll({'Accept': 'application/json'});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        _showSnackbar('Failed to update profile', Colors.red);
        return;
      }

      final responseData = jsonDecode(response.body);
      final success = responseData['success'] ?? false;
      final message = responseData['message'] ?? 'Unknown error occurred';

      if (success) {
        _showSnackbar(message, Colors.green);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        if (responseData.containsKey('errors')) {
          String errorMessages = responseData['errors']
              .values
              .map((errorList) => errorList.join(', '))
              .join('\n');
          _showSnackbar(errorMessages, Colors.red);
        } else {
          _showSnackbar(message, Colors.red);
        }
      }
    } catch (_) {
      _showSnackbar('An error occurred. Please try again.', Colors.red);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _removePhoto() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri =
          Uri.parse('${widget.baseUrl}/profilepage/profile/update/api/');
      final request = http.MultipartRequest('POST', uri);

      request.fields['username'] = widget.username;
      request.fields['delete_photo'] = 'true';

      request.headers.addAll({'Accept': 'application/json'});

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        _showSnackbar('Failed to remove photo', Colors.red);
        return;
      }

      final responseData = jsonDecode(response.body);
      final success = responseData['success'] ?? false;
      final message = responseData['message'] ?? 'Unknown error occurred';

      if (success) {
        _showSnackbar(message, Colors.green);
        setState(() {
          _selectedPhoto = null;
          _webSelectedPhoto = null;
        });
      } else {
        if (responseData.containsKey('errors')) {
          String errorMessages = responseData['errors']
              .values
              .map((errorList) => errorList.join(', '))
              .join('\n');
          _showSnackbar(errorMessages, Colors.red);
        } else {
          _showSnackbar(message, Colors.red);
        }
      }
    } catch (_) {
      _showSnackbar('An error occurred. Please try again.', Colors.red);
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
          content: Text(message, style: const TextStyle(color: Colors.white)),
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
                backgroundImage: kIsWeb && _webSelectedPhoto != null
                    ? MemoryImage(_webSelectedPhoto!)
                    : (_selectedPhoto != null
                        ? FileImage(_selectedPhoto!) as ImageProvider
                        : (widget.currentProfilePhoto.isNotEmpty
                            ? NetworkImage(
                                '${widget.baseUrl}${widget.currentProfilePhoto}')
                            : null)),
                backgroundColor: Colors.grey[300],
                child: ((_selectedPhoto == null && _webSelectedPhoto == null) &&
                        widget.currentProfilePhoto.isEmpty)
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
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
                label: const Text('Pilih Foto',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _removePhoto,
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text('Hapus Foto',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                  ),
                  child: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
