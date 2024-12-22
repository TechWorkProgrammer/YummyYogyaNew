// To parse this JSON data, do
//
//     final makanan = makananFromJson(jsonString);

import 'dart:convert';

List<Makanan> makananFromJson(String str) =>
    List<Makanan>.from(json.decode(str).map((x) => Makanan.fromJson(x)));

String makananToJson(List<Makanan> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Makanan {
  Model model;
  int pk;
  Fields fields;

  Makanan({
    required this.model,
    required this.pk,
    required this.fields,
  });

  factory Makanan.fromJson(Map<String, dynamic> json) => Makanan(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
      );

  Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
      };
}

class Fields {
  String nama;
  String deskripsi;
  String kategori;
  String restoran;
  int harga;
  String rating;
  String gambar;

  Fields({
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.restoran,
    required this.harga,
    required this.rating,
    required this.gambar,
  });

  factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        nama: json["nama"],
        deskripsi: json["deskripsi"],
        kategori: json["kategori"],
        restoran: json["restoran"],
        harga: json["harga"],
        rating: json["rating"],
        gambar: json["gambar"],
      );

  get id => null;

  Map<String, dynamic> toJson() => {
        "nama": nama,
        "deskripsi": deskripsi,
        "kategori": kategori,
        "restoran": restoran,
        "harga": harga,
        "rating": rating,
        "gambar": gambar,
      };
}

enum Model { MAIN_MAKANAN }

final modelValues = EnumValues({"main.makanan": Model.MAIN_MAKANAN});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
