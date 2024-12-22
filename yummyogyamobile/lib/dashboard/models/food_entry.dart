// To parse this JSON data, do
//
//     final foodEntry = foodEntryFromJson(jsonString);

import 'dart:convert';

List<FoodEntry> foodEntryFromJson(String str) =>
    List<FoodEntry>.from(json.decode(str).map((x) => FoodEntry.fromJson(x)));

String foodEntryToJson(List<FoodEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FoodEntry {
  final int id;
  final String name;
  final String description;
  final int price;
  final String image_url;
  final String restaurant;
  final String category;
  final String rating;

  FoodEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image_url,
    required this.restaurant,
    required this.category,
    required this.rating,
  });

  factory FoodEntry.fromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      image_url: json['image_url'] ?? '',
      restaurant: json['restaurant'] ?? '',
      category: json['category'] ?? '',
      rating: json['rating'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': image_url,
      'restaurant': restaurant,
      'category': category,
      'rating': rating,
    };
  }
}
