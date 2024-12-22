import 'dart:convert';

List<WishlistProduct> wishlistProductFromJson(String str) => 
    List<WishlistProduct>.from(json.decode(str).map((x) => WishlistProduct.fromJson(x)));

String wishlistProductToJson(List<WishlistProduct> data) => 
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WishlistProduct {
  int id;
  String nama;
  int harga;
  String deskripsi;
  String rating;
  String gambar;
  String notes;

  WishlistProduct({
    required this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.rating,
    required this.gambar,
    required this.notes,
  });

  factory WishlistProduct.fromJson(Map<String, dynamic> json) => WishlistProduct(
        id: json["id"],
        nama: json["nama"],
        harga: json["harga"],
        deskripsi: json["deskripsi"],
        rating: json["rating"].toString(),
        gambar: json["gambar"],
        notes: json["notes"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nama": nama,
        "harga": harga,
        "deskripsi": deskripsi,
        "rating": rating,
        "gambar": gambar,
        "notes": notes,
      };
}