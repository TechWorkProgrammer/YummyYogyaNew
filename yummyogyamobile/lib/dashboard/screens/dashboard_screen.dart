import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'edit_food_screen.dart';
import 'add_food_screen.dart';
import '../models/food_entry.dart'; // Impor model FoodEntry
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  final String username;

  DashboardScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? userId;
  List<FoodEntry> _foodEntries = [];
  String _sortBy = 'name'; // Default sorting by name
  bool _isAscending = true;

  void _sortFoodEntries(String sortBy) {
    setState(() {
      if (sortBy == 'name') {
        _foodEntries.sort((a, b) => _isAscending
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
      } else if (sortBy == 'price') {
        _foodEntries.sort((a, b) => _isAscending
            ? a.price.compareTo(b.price)
            : b.price.compareTo(a.price));
      }
      _sortBy = sortBy; // Update sorting state
    });
  }

  Future<bool> fetchDashboardData() async {
    final String url =
        'http://127.0.0.1:8000/dashboard/api/dashboard/?username=${widget.username}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<FoodEntry> data =
            foodEntryFromJson(response.body); // Gunakan foodEntryFromJson
        setState(() {
          _foodEntries = data;
          _sortFoodEntries(_sortBy);
        });
        return true;
      } else {
        print("Fetch API Failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error in fetchDashboardData: $e");
      return false;
    }
  }

  void _editFood(FoodEntry food) async {
    final updatedFood = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFoodScreen(food: food),
      ),
    );

    if (updatedFood != null && updatedFood is FoodEntry) {
      setState(() {
        int index = _foodEntries.indexWhere((item) => item.id == food.id);
        if (index != -1) {
          _foodEntries[index] = updatedFood;
        }
      });
    }
    await fetchDashboardData();
  }

  Future<void> _deleteFoodFromServer(int id) async {
    final String url =
        'http://127.0.0.1:8000/dashboard/delete_food_flutter/$id/';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Jika berhasil, hapus dari daftar makanan di Flutter
        await fetchDashboardData();
        setState(() {
          _foodEntries.removeWhere((food) => food.id == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Makanan berhasil dihapus')),
        );
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Makanan tidak ditemukan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus makanan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> fetchUserId() async {
    // Lakukan HTTP request untuk mendapatkan userId dari Django
    final response = await http.get(
      Uri.parse(
          'http://127.0.0.1:8000/dashboard/api/get_user_id?username=${widget.username}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        userId = data['user_id']; // Simpan userId ke state
      });
    } else {
      print('Error fetching userId: ${response.body}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    fetchUserId();
  }

  Future<void> _addFoodToDjango(Map<String, dynamic> foodData) async {
    final url = Uri.parse('http://127.0.0.1:8000/dashboard/add_food_flutter/');
    // Assuming you have the userId available in your Flutter app
    userId = userId; // Replace this with actual user ID

    // Add user_id to the food data
    final Map<String, dynamic> postData = {
      ...foodData,
      'user_id': userId, // Pass the user_id
    };
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(postData),
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

  Future<void> _updateFoodToDjango(FoodEntry food) async {
    final String url =
        'http://127.0.0.1:8000/dashboard/update_food_flutter/${food.id}/';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': food.name,
          'price': food.price,
          'description': food.description,
          'category': food.category,
          'restaurant': food.restaurant,
          'rating': food.rating,
          'image_url': food.image_url,
        }),
      );

      if (response.statusCode == 200) {
        print('Food updated successfully in Django');
      } else {
        print('Failed to update food: ${response.body}');
      }
    } catch (e) {
      print('Error updating food: $e');
    }
  }

  void _addNewFood() async {
    final newFood = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddFoodScreen()));

    if (newFood != null && newFood is Map<String, dynamic>) {
      setState(() {
        _foodEntries.add(
          FoodEntry(
            id: DateTime.now().millisecondsSinceEpoch,
            name: newFood['name'],
            price: newFood['price'],
            description: newFood['description'],
            category: newFood['category'],
            restaurant: newFood['restaurant'],
            rating: newFood['rating'],
            image_url: newFood['image_url'],
          ),
        );
      });

      // Kirim data ke Django
      await _addFoodToDjango(newFood);

      // Refresh data setelah berhasil menambah makanan
      await fetchDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Dashboard"),
        actions: [
          DropdownButton<String>(
            value: _sortBy,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _sortFoodEntries(newValue);
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'name',
                child: Text('Sort by Name'),
              ),
              DropdownMenuItem(
                value: 'price',
                child: Text('Sort by Price'),
              ),
            ],
            underline: SizedBox(), // Hilangkan garis bawah dropdown
            icon: Icon(Icons.sort, color: Colors.orange), // Ikon dropdown
          ),
          IconButton(
            icon: Icon(
              _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.orange,
            ),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending; // Toggle ascending/descending
                _sortFoodEntries(_sortBy); // Apply sorting ulang
              });
            },
            tooltip: _isAscending ? 'Sort Ascending' : 'Sort Descending',
          ),
        ],
      ),
      body: _foodEntries.isEmpty
          ? const Center(child: Text("Belum ada makanan yang ditambahkan"))
          : LayoutBuilder(
              builder: (context, constraints) {
                // Hitung jumlah kolom berdasarkan lebar layar
                final int crossAxisCount =
                    max(2, (constraints.maxWidth / 200).floor());
                final double childAspectRatio =
                    constraints.maxWidth / (crossAxisCount * 350);

                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Jumlah kolom dinamis
                    crossAxisSpacing: 8.0, // Spasi horizontal antar kolom
                    mainAxisSpacing: 8.0, // Spasi vertikal antar baris
                    childAspectRatio: childAspectRatio, // Rasio aspek dinamis
                  ),
                  itemCount: _foodEntries.length,
                  itemBuilder: (context, index) {
                    final food = _foodEntries[index];
                    return Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                              child: Image.network(
                                food.image_url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              (progress.expectedTotalBytes!)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(Icons.broken_image, size: 40),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              food.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14, // Ukuran font disesuaikan
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              food.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors
                                    .grey, // Warna abu-abu untuk teks yang lebih pudar
                              ),
                              softWrap: true, // Membungkus teks jika panjang
                              maxLines:
                                  3, // Maksimal 3 baris, tambahkan jika ingin membatasi
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.attach_money,
                                    size: 14,
                                    color: Colors.black), // Ikon Price
                                const SizedBox(
                                    width:
                                        4), // Spasi kecil antara ikon dan teks
                                Text(
                                  "${food.price}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 14,
                                    color: Colors.black), // Ikon Rating
                                const SizedBox(width: 4),
                                Text(
                                  "${food.rating}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.category,
                                    size: 14,
                                    color: Colors.black), // Ikon Category
                                const SizedBox(width: 4),
                                Text(
                                  food.category,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start, // Pastikan teks disejajarkan dengan baik
                              children: [
                                const Icon(
                                  Icons.restaurant,
                                  size: 14,
                                  color: Colors.black, // Ikon Restaurant
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  // Jika ruang terbatas, teks tetap bisa membungkus
                                  child: Text(
                                    food.restaurant,
                                    style: const TextStyle(fontSize: 12),
                                    softWrap:
                                        true, // Membungkus teks ke baris berikutnya
                                    maxLines:
                                        3, // Tidak ada batasan jumlah baris
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _editFood(food),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => _deleteFoodFromServer(food.id),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16.0), // Jarak dari bawah
        child: FloatingActionButton.extended(
          onPressed: _addNewFood,
          label: const Text(
            'Add Food',
            style: TextStyle(fontSize: 14.0), // Ukuran teks disesuaikan
          ),
          icon: const Icon(Icons.add, size: 20.0), // Ikon lebih kecil
          tooltip: 'Tambah Makanan',
          backgroundColor: Colors.orange, // Warna latar belakang tombol
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat, // Letakkan di tengah bawah
    );
  }
}
