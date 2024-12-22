import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddFoodScreen extends StatefulWidget {
  @override
  _AddFoodScreenState createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _restaurantController = TextEditingController();
  final _ratingController = TextEditingController();
  final _imageUrlController = TextEditingController();

  Future<void> _addFoodToDjango(Map<String, dynamic> foodData) async {
    final url = Uri.parse('http://127.0.0.1:8000/dashboard/add_food_flutter/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(foodData),
      );

      if (response.statusCode == 201) {
        print("Makanan berhasil ditambahkan ke Django");
      } else {
        print("Gagal menambahkan makanan: ${response.body}");
      }
    } catch (e) {
      print("Error saat menambahkan makanan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Makanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input untuk Nama Makanan
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Makanan'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama makanan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // Input untuk Harga
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final price = int.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Harga harus lebih besar dari 0';
                  }
                  return null;
                },
              ),
              // Input untuk Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // Input untuk Kategori
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Kategori'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // Input untuk Nama Restoran
              TextFormField(
                controller: _restaurantController,
                decoration: const InputDecoration(labelText: 'Nama Restoran'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama restoran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              // Input untuk Rating
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Rating (0 - 5)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Rating tidak boleh kosong';
                  }
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Rating harus antara 0 dan 5';
                  }
                  return null;
                },
              ),
              // Input untuk URL Gambar
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Gambar'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'URL Gambar tidak boleh kosong';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'URL tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Tombol Simpan
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Menyusun data makanan yang akan dikirim
                    final newFood = {
                      'name': _nameController.text,
                      'price': int.parse(_priceController.text),
                      'description': _descriptionController.text,
                      'category': _categoryController.text,
                      'restaurant': _restaurantController.text,
                      'rating': _ratingController.text,
                      'image_url': _imageUrlController.text,
                    };

                    // Menyimpan data dan kembali ke halaman sebelumnya
                    Navigator.pop(context, newFood);
                  }
                },
                child: const Text('Simpan Makanan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
