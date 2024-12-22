import 'package:flutter/material.dart';
import 'package:yummyogya_mobile/dashboard/models/food_entry.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditFoodScreen extends StatefulWidget {
  final dynamic food;
  EditFoodScreen({required this.food});

  @override
  _EditFoodScreenState createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _restaurantController;
  late TextEditingController _ratingController;
  late TextEditingController _imageUrlController;

  late FocusNode _nameFocusNode;
  late FocusNode _priceFocusNode;
  late FocusNode _descriptionFocusNode;
  late FocusNode _categoryFocusNode;
  late FocusNode _restaurantFocusNode;
  late FocusNode _ratingFocusNode;
  late FocusNode _imageUrlFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
        text: widget.food.name); // Ubah menjadi widget.food.name
    _priceController =
        TextEditingController(text: widget.food.price.toString());
    _descriptionController =
        TextEditingController(text: widget.food.description);
    _categoryController = TextEditingController(text: widget.food.category);
    _restaurantController = TextEditingController(text: widget.food.restaurant);
    _ratingController =
        TextEditingController(text: widget.food.rating.toString());
    _imageUrlController = TextEditingController(text: widget.food.image_url);

    _nameFocusNode = FocusNode();
    _priceFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _categoryFocusNode = FocusNode();
    _restaurantFocusNode = FocusNode();
    _ratingFocusNode = FocusNode();
    _imageUrlFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _categoryFocusNode.dispose();
    _restaurantFocusNode.dispose();
    _ratingFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

// Fungsi untuk memperbarui makanan di server Django
  Future<bool> _updateFoodToDjango(FoodEntry updatedFood) async {
    final String url =
        'http://127.0.0.1:8000/dashboard/update_food_flutter/${updatedFood.id}/';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': updatedFood.name,
          'price': updatedFood.price,
          'description': updatedFood.description,
          'category': updatedFood.category,
          'restaurant': updatedFood.restaurant,
          'rating': updatedFood.rating,
          'image_url': updatedFood.image_url,
        }),
      );

      if (response.statusCode == 200) {
        // Jika pembaruan berhasil
        print("Makanan berhasil diperbarui di Django.");
        return true;
      } else {
        // Jika terjadi kesalahan
        print("Gagal memperbarui makanan: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error saat memperbarui makanan: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Makanan'),
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
                focusNode: _nameFocusNode, // Menambahkan FocusNode
                decoration: const InputDecoration(labelText: 'Nama Makanan'),
                style: TextStyle(
                  color: _nameFocusNode.hasFocus ? Colors.orange : Colors.black,
                ),
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
                focusNode: _priceFocusNode, // Menambahkan FocusNode
                decoration: const InputDecoration(labelText: 'Harga'),
                style: TextStyle(
                  color:
                      _priceFocusNode.hasFocus ? Colors.orange : Colors.black,
                ),
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
                focusNode: _descriptionFocusNode, // Menambahkan FocusNode
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                style: TextStyle(
                  color: _descriptionFocusNode.hasFocus
                      ? Colors.orange
                      : Colors.black,
                ),
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
                focusNode: _categoryFocusNode, // Menambahkan FocusNode
                decoration: const InputDecoration(labelText: 'Kategori'),
                style: TextStyle(
                  color: _categoryFocusNode.hasFocus
                      ? Colors.orange
                      : Colors.black,
                ),
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
                focusNode: _restaurantFocusNode, // Menambahkan FocusNode
                decoration: const InputDecoration(labelText: 'Nama Restoran'),
                style: TextStyle(
                  color: _restaurantFocusNode.hasFocus
                      ? Colors.orange
                      : Colors.black,
                ),
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
                focusNode: _ratingFocusNode, // Menambahkan FocusNode
                decoration: const InputDecoration(labelText: 'Rating'),
                style: TextStyle(
                  color:
                      _ratingFocusNode.hasFocus ? Colors.orange : Colors.black,
                ),
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
                focusNode: _imageUrlFocusNode, // Menambahkan FocusNode
                decoration: const InputDecoration(labelText: 'URL Gambar'),
                style: TextStyle(
                  color: _imageUrlFocusNode.hasFocus
                      ? Colors.orange
                      : Colors.black,
                ),
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
              // Tombol Perbarui
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Membuat objek FoodEntry yang telah diperbarui
                    final updatedFood = FoodEntry(
                      id: widget.food.id, // ID tetap sama
                      name: _nameController.text,
                      description: _descriptionController.text,
                      price: int.parse(_priceController.text),
                      image_url: _imageUrlController.text,
                      restaurant: _restaurantController.text,
                      category: _categoryController.text,
                      rating:
                          _ratingController.text, // Pastikan ini tipe double
                    );

                    // Mengirim data yang diperbarui ke Django
                    bool success = await _updateFoodToDjango(updatedFood);

                    if (success) {
                      // Mengirim kembali objek yang sudah diperbarui ke halaman sebelumnya
                      Navigator.pop(context, updatedFood);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Data Makanan Diperbarui')),
                      );
                    } else {
                      // Tampilkan pesan kesalahan jika pembaruan gagal
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gagal memperbarui makanan')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Perbarui Makanan',
                  style: TextStyle(
                    color: Colors.orange, // Menentukan warna teks
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
