import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/article.dart';

enum NewsStatus {initial, loading, success, failure}

class NewsState {
  final List<Article> articles;
  final NewsStatus status;
  final String? error;

  NewsState ({
    this.articles = const [],
    this.status = NewsStatus.initial,
    this.error,
  });
}

class NewsCubit extends Cubit<NewsState> {
  NewsCubit(): super(NewsState());

  Future<void> fetchNews() async {
    emit(NewsState(status: NewsStatus.loading));

    try {
      final response = await http.get(
        Uri.parse('https://newsapi.org/v2/top-headlines?country=us&apiKey=abb021fcd9124fe4a756d19365dc0136')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = (data['articles'] as List)
            .map((article) => Article.fromJson(article))
            .toList();

        emit(NewsState(
          articles: articles,
          status: NewsStatus.success,
        ));
      } else {
        emit(NewsState(
          status: NewsStatus.failure,
          error: 'Failed to fetch news',
        ));
      }
    } catch (e) {
      emit(NewsState(
        status: NewsStatus.failure,
        error: e.toString(),
      ));
    }
  }
}