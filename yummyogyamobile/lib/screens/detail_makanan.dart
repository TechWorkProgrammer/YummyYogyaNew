import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:yummyogya_mobile/models/makanan_entry.dart';

class DetailPage extends StatefulWidget {
  final Makanan makanan;

  DetailPage({required this.makanan});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isWishlisted = false; // Status untuk wishlist
  int selectedRating = 0; // Rating yang dipilih
  TextEditingController reviewController = TextEditingController();
  List<dynamic> reviews = []; // Daftar ulasan

  @override
  void initState() {
    super.initState();
    fetchReviews(); // Ambil ulasan saat halaman dibuka
  }

  Future<void> fetchReviews() async {
    final url = Uri.parse(
        'http://192.168.1.10:8000/details/${widget.makanan.pk}/'); // Ganti dengan endpoint backend
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          reviews = data['reviews'];
        });
      } else {
        throw Exception('Gagal memuat ulasan');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  Future<void> addToWishlist(int foodId) async {
    final url = Uri.parse(
        'http://192.168.1.10:8000/wishlist/add/$foodId/'); // Ganti dengan URL backend
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': getCsrfToken(), // Dummy CSRF token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            isWishlisted = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Berhasil ditambahkan ke wishlist!')),
          );
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke wishlist: $error')),
      );
    }
  }

  Future<void> submitReview(int foodId) async {
    final url = Uri.parse('http://192.168.1.10:8000/details/add_review/');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': getCsrfToken(), // Dummy CSRF token
        },
        body: json.encode({
          'food_id': foodId,
          'rating': selectedRating,
          'review': reviewController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ulasan berhasil ditambahkan!')),
          );
          fetchReviews(); // Perbarui daftar ulasan
          reviewController.clear();
          setState(() {
            selectedRating = 0;
          });
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim ulasan: $error')),
      );
    }
  }

  String getCsrfToken() {
    // Dummy token; ini perlu diganti dengan token asli
    return 'your_csrf_token_here';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.makanan.fields.nama),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : Colors.white,
            ),
            onPressed: () {
              addToWishlist(widget.makanan.pk); // Panggil fungsi wishlist
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.makanan.fields.gambar.startsWith('http')
                    ? widget.makanan.fields.gambar
                    : 'http://192.168.1.10:8000/${widget.makanan.fields.gambar}',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.fastfood,
                    size: 100,
                    color: Colors.orange,
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                widget.makanan.fields.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Rp ${widget.makanan.fields.harga}'),
              const SizedBox(height: 16),
              Text(widget.makanan.fields.deskripsi ?? 'Tidak ada deskripsi'),
              const SizedBox(height: 24),

              // Form Review
              Text(
                'Tambah Ulasan:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    icon: Icon(
                      Icons.star,
                      color:
                          index < selectedRating ? Colors.orange : Colors.grey,
                    ),
                  );
                }),
              ),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  hintText: 'Tulis ulasan di sini...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  submitReview(widget.makanan.pk);
                },
                child: Text('Kirim Ulasan'),
              ),
              const SizedBox(height: 24),

              // Daftar Ulasan
              Text(
                'Ulasan Pengguna:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              reviews.isNotEmpty
                  ? Column(
                      children: reviews.map((review) {
                        return Card(
                          child: ListTile(
                            title: Text('${review['user']}'),
                            subtitle: Text('${review['review']}'),
                            trailing: Text('${review['rating']} ★'),
                          ),
                        );
                      }).toList(),
                    )
                  : Text('Belum ada ulasan.'),
            ],
          ),
        ),
      ),
    );
  }
}
