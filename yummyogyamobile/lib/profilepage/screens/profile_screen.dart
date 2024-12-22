import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> profileData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'http://127.0.0.1:8000/profile/api/?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
        print('Failed to load profile data');
      });
      // Handle error (e.g., show a message)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile photo and username
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileData['profile_photo'] != null
                          ? NetworkImage(profileData['profile_photo'])
                          : const NetworkImage(
                              'https://via.placeholder.com/150'),
                    ),
                    const SizedBox(height: 16),
                    Text('Username: ${profileData['username']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Email: ${profileData['email']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Joined: ${profileData['date_joined']}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),

                    // Bio
                    Text('Bio: ${profileData['bio'] ?? 'No bio available'}',
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),

                    // Wishlist Section
                    const Text('Wishlist',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: profileData['wishlist']?.length ?? 0,
                      itemBuilder: (context, index) {
                        var item = profileData['wishlist'][index];
                        return ListTile(
                          leading: Image.network(item['image'],
                              width: 50, height: 50),
                          title: Text(item['name']),
                          subtitle: Text('Price: ${item['price']}'),
                        );
                      },
                    ),

                    // Reviews Section
                    const SizedBox(height: 16),
                    const Text('Reviews',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: profileData['reviews']?.length ?? 0,
                      itemBuilder: (context, index) {
                        var review = profileData['reviews'][index];
                        return ListTile(
                          title: Text(review['food_name']),
                          subtitle: Text(
                              '${review['rating']} Stars\n${review['review']}'),
                        );
                      },
                    ),

                    // Edit Profile Button - Opens Bottom Sheet
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _showEditProfileBottomSheet(context);
                      },
                      child: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        // Corrected the parameter to 'backgroundColor'
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Function to show the profile editing form in a BottomSheet
  void _showEditProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ProfileEditForm(
          bio: profileData['bio'] ?? '',
          username: widget.username,
          onProfileUpdated: (updatedBio) {
            setState(() {
              profileData['bio'] = updatedBio;
            });
            Navigator.pop(context); // Close the bottom sheet
          },
        );
      },
    );
  }
}

class ProfileEditForm extends StatefulWidget {
  final String bio;
  final String username;
  final Function(String) onProfileUpdated;

  const ProfileEditForm({
    Key? key,
    required this.bio,
    required this.username,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _ProfileEditFormState createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.bio;
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/profile/update/api/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'bio': _bioController.text}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          widget.onProfileUpdated(_bioController.text);
        } else {
          // Handle failure
          print('Error updating profile');
        }
      } else {
        // Handle server error
        print('Failed to update profile');
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bio input field
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Update your bio',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your bio';
                }
                return null;
              },
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Save button
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Save Changes'),
                  ),
          ],
        ),
      ),
    );
  }
}
