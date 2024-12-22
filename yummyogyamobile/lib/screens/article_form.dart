import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:yummyogya_mobile/screens/article.dart';
import 'package:yummyogya_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ArticleForm extends StatefulWidget {
  const ArticleForm({super.key});

  @override
  State<ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends State<ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  Future<void> _addArticleToDjango(Map<String, dynamic> articleData) async {
    final url = Uri.parse('http://127.0.0.1:8000/article/create-flutter/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(articleData),
      );

      if (response.statusCode == 201) {
        print("Artikel berhasil ditambahkan ke Django");
      } else {
        print("Gagal menambahkan artikel: ${response.body}");
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Artikel'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: const LeftDrawer(
          username: 'username'), // Sesuaikan dengan username Anda
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input untuk Judul Artikel
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Artikel'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul artikel tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // Input untuk Isi Artikel
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Isi Artikel'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Isi artikel tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // Tombol Submit
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final response = await request.postJson(
                        'http://127.0.0.1:8000/article/create-flutter/', jsonEncode(<String, String>{
                          'title': _titleController.text,
                          'content': _contentController.text,
                        }),
                      );
                      if (context.mounted){
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Artikel berhasil ditambahkan'),
                            ),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const ArticleEntryPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gagal menambahkan artikel'),
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
