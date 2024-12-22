import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:yummyogya_mobile/models/makanan_entry.dart';
import 'package:yummyogya_mobile/detail/screens/detail_makanan.dart';
import 'package:yummyogya_mobile/screens/menu.dart';
import 'package:yummyogya_mobile/widgets/left_drawer.dart';
import 'package:yummyogya_mobile/widgets/bottom_nav.dart';
import 'package:yummyogya_mobile/wishlist/models/wishlist_product.dart';
import 'package:yummyogya_mobile/wishlist/screens/wishlist_screens.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  final String username;
  final Function(WishlistProduct)? addToWishlist; // Jadikan nullable

  const SearchPage({
    Key? key,
    required this.username,
    this.addToWishlist, // Tidak wajib diisi
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<List<Makanan>> fetchMakanan(CookieRequest request) async {
    const String url = 'http://192.168.1.10:8000/json/';
    final response = await request.get(url);

    var data = response;

    List<Makanan> listMakanan = [];
    for (var d in data) {
      if (d != null) {
        listMakanan.add(Makanan.fromJson(d));
      }
    }
    return listMakanan;
  }

  Future<void> _handleAddToWishlist(Makanan makanan) async {
    final request = context.read<CookieRequest>();

    try {
      // Menyiapkan data dalam format JSON
      final requestData = {
        'username': widget.username,
        'food_id': makanan.pk.toString(),
        'food_name': makanan.fields.nama,
        'food_price': makanan.fields.harga.toString(),
        'food_image': makanan.fields.gambar,
        'food_rating': makanan.fields.rating.toString(),
        'notes': '', // Default empty notes
      };

      // Melakukan POST request
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/wishlist/wishlist/add_wishlist_flutter/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      // Debugging: Print status code dan body respons
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Memastikan respons berbentuk JSON
      var responseBody = jsonDecode(response.body);
      print("Decoded Response Body: $responseBody");

      // Memeriksa apakah respons mengandung 'message'
      if (response.statusCode == 200 && responseBody.containsKey('message')) {
        // Membuat objek WishlistProduct
        final product = WishlistProduct(
          id: makanan.pk,
          nama: makanan.fields.nama,
          harga: makanan.fields.harga,
          deskripsi: makanan.fields.deskripsi,
          rating: makanan.fields.rating.toString(),
          gambar: makanan.fields.gambar,
          notes: '',
        );

        // Memanggil callback addToWishlist jika ada
        if (widget.addToWishlist != null) {
          widget.addToWishlist!(product);
        }

        // Menampilkan pesan sukses
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${makanan.fields.nama} berhasil ditambahkan ke Wishlist!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Menampilkan pesan error jika gagal
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menambahkan ${makanan.fields.nama} ke Wishlist'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Menangani error jika ada
      print("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat menambahkan ke wishlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Kode di dalam block finally ini akan dieksekusi setelah try selesai,
      // baik sukses atau gagal.
      print("Request to add to wishlist completed.");
    }
  }

  int _currentIndex = 1; // Indeks untuk Search
  String searchQuery = ""; // Query pencarian makanan
  late Future<List<Makanan>> makananFuture; // Data makanan dari server

  // Variabel untuk kategori dan rentang harga
  List<String> categories = [
    'All',
    'Makanan',
    'Minuman',
    'Jajanan',
    'Oleh-oleh',
  ];
  String selectedCategory = 'All';

  double minPrice = 0;
  double maxPrice = 100000; // Sesuaikan dengan data Anda
  RangeValues selectedPriceRange = const RangeValues(0, 100000);

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    makananFuture = fetchMakanan(request); // Ambil data makanan saat init
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyHomePage(username: widget.username),
          ),
        );
        break;
      case 1: // Search
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchPage(username: widget.username),
          ),
        );
        break;
      case 2: // Wishlist
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WishlistScreen(username: widget.username),
          ),
        );
        break;
      case 3: // Profile (Open Right Drawer)
        _scaffoldKey.currentState!.openEndDrawer(); // Membuka drawer kanan
        break;
    }
  }

  // GlobalKey untuk mengontrol Scaffold agar bisa membuka endDrawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final TextEditingController _searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Makanan'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Baris yang berisi Search Bar, Dropdown Kategori, dan Tombol Rentang Harga
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari makanan...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase().trim();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Dropdown Kategori
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange),
                      ),
                    ),
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Rentang Harga
                IconButton(
                  icon: const Icon(Icons.attach_money),
                  onPressed: () async {
                    RangeValues? result = await showDialog<RangeValues>(
                      context: context,
                      builder: (context) {
                        RangeValues tempRange = selectedPriceRange;
                        return AlertDialog(
                          title: const Text('Pilih Rentang Harga'),
                          content: StatefulBuilder(
                            builder: (context, setStateDialog) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RangeSlider(
                                    values: tempRange,
                                    min: minPrice,
                                    max: maxPrice,
                                    divisions: 100,
                                    labels: RangeLabels(
                                      'Rp ${tempRange.start.round()}',
                                      'Rp ${tempRange.end.round()}',
                                    ),
                                    onChanged: (RangeValues values) {
                                      setStateDialog(() {
                                        tempRange = values;
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(null);
                              },
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(tempRange);
                              },
                              child: const Text('Simpan'),
                            ),
                          ],
                        );
                      },
                    );
                    if (result != null) {
                      setState(() {
                        selectedPriceRange = result;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          // Sisanya tetap sama
          Expanded(
            child: FutureBuilder(
              future: makananFuture,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData || snapshot.data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data makanan.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                // Filter makanan berdasarkan query pencarian, kategori, dan harga
                final List<Makanan> allMakanan = snapshot.data as List<Makanan>;

                // Filter berdasarkan query pencarian
                List<Makanan> makananList = searchQuery.isEmpty
                    ? allMakanan
                    : allMakanan.where((makanan) {
                        final namaMakanan = makanan.fields.nama.toLowerCase();
                        return namaMakanan.contains(searchQuery);
                      }).toList();

                // Filter berdasarkan kategori (dengan substring)
                if (selectedCategory != 'All') {
                  makananList = makananList.where((makanan) {
                    return makanan.fields.kategori
                        .toLowerCase()
                        .contains(selectedCategory.toLowerCase());
                  }).toList();
                }

                // Filter berdasarkan rentang harga
                makananList = makananList.where((makanan) {
                  return makanan.fields.harga >= selectedPriceRange.start &&
                      makanan.fields.harga <= selectedPriceRange.end;
                }).toList();

                if (makananList.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada makanan yang cocok dengan pencarian.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Jumlah kolom dalam grid
                    crossAxisSpacing: 16, // Jarak horizontal antar kolom
                    mainAxisSpacing: 16, // Jarak vertikal antar baris
                    childAspectRatio:
                        0.75, // Rasio tinggi-lebar untuk setiap card
                  ),
                  itemCount: makananList.length,
                  itemBuilder: (_, index) {
                    final Makanan makanan = makananList[index];
                    return SizedBox(
                      height: 250, // Tinggi tetap untuk card
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Gambar makanan
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              child: Image.network(
                                makanan.fields.gambar.startsWith('http')
                                    ? makanan.fields.gambar
                                    : 'http://127.0.0.1:8000${makanan.fields.gambar}',
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    height: 120,
                                    width: double.infinity,
                                    child: const Icon(
                                      Icons.fastfood,
                                      size: 60,
                                      color: Colors.orange,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Nama makanan
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                makanan.fields.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Harga makanan
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Rp ${makanan.fields.harga}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Restoran makanan
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                'Restoran: ${makanan.fields.restoran}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Rating makanan
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Text(
                                    makanan.fields.rating.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),

                            // Tombol Add to Wishlist dan Detail
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _handleAddToWishlist(makanan),
                                    style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    minimumSize: const Size(50, 30),
                                    ),
                                    child: const Text(
                                    'Add to Wishlist',
                                    style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailPage(makanan: makanan, username: widget.username),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue, // Warna latar tombol
                                      foregroundColor: Colors
                                          .white, // Warna teks menjadi putih
                                      minimumSize: const Size(50, 30),
                                    ),
                                    child: const Text(
                                      'Detail',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
