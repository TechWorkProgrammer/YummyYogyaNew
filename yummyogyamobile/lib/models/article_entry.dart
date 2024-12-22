// To parse this JSON data, do
//
//     final articleEntry = articleEntryFromJson(jsonString);

import 'dart:convert';

List<ArticleEntry> articleEntryFromJson(String str) => List<ArticleEntry>.from(json.decode(str).map((x) => ArticleEntry.fromJson(x)));

String articleEntryToJson(List<ArticleEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ArticleEntry {
    String model;
    String pk;
    Fields fields;

    ArticleEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory ArticleEntry.fromJson(Map<String, dynamic> json) => ArticleEntry(
        model: json["model"],
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    int user;
    String title;
    String content;
    DateTime publishedDate;
    String imageUrl;

    Fields({
        required this.user,
        required this.title,
        required this.content,
        required this.publishedDate,
        required this.imageUrl,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        user: json["user"],
        title: json["title"],
        content: json["content"],
        publishedDate: DateTime.parse(json["published_date"]),
        imageUrl: json["image_url"],
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "title": title,
        "content": content,
        "published_date": publishedDate.toIso8601String(),
        "image_url": imageUrl,
    };
}
