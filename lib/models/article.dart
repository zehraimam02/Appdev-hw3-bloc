// lib/models/article.dart
class Article {
  final String? author;
  final String title;
  final String? description;
  final String? urlToImage;
  final String publishedAt;
  final String? content;
  final String url;

  Article({
    this.author,
    required this.title,
    this.description,
    this.urlToImage,
    required this.publishedAt,
    this.content,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      author: json['author'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'] ?? DateTime.now().toIso8601String(),
      content: json['content'],
      url: json['url'] ?? '',
    );
  }
}