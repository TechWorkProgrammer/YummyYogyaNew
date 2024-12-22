import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:yummyogya_mobile/models/article_entry.dart';
import 'package:yummyogya_mobile/screens/article_detail.dart';
import 'package:yummyogya_mobile/screens/article_form.dart';
import 'package:yummyogya_mobile/widgets/left_drawer.dart';

class ArticleEntryPage extends StatefulWidget {
  const ArticleEntryPage({super.key});

  @override
  State<ArticleEntryPage> createState() => _ArticleEntryPageState();
}

class _ArticleEntryPageState extends State<ArticleEntryPage> {
  Future<List<ArticleEntry>> fetchArticle(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/article/json/');
    List<ArticleEntry> articles = [];

    for (var article in response) {
      if (article != null) {
        articles.add(ArticleEntry.fromJson(article));
      }
    }
    return articles;
  }

  @override
  Widget build(BuildContext context) {
    final request = Provider.of<CookieRequest>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artikel'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: const LeftDrawer(
          username: 'username'), // Sesuaikan dengan username Anda
      body: FutureBuilder<List<ArticleEntry>>(
        future: fetchArticle(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada artikel'));
          } else {
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                const maxWords = 30;
                final words = article.fields.content.split(' ');
                final truncatedContent = words.length > maxWords
                    ? '${words.sublist(0, maxWords).join(' ')}...'
                    : article.fields.content;
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ArticleDetailPage(article: article)),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            article.fields.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                width: 80,
                                height: 80,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Theme.of(context).primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.fields.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(truncatedContent,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ArticleForm()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
