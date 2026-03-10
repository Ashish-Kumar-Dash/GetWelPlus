import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

// article model - represents a news article from the api
class Article {
  final String title;
  final String description;
  final String content;
  final String? imageUrl;
  final String source;
  final String? author;
  final DateTime publishedAt;
  final String url; // original url, kept for reference

  Article({
    required this.title,
    required this.description,
    required this.content,
    this.imageUrl,
    required this.source,
    this.author,
    required this.publishedAt,
    required this.url,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: _stripHtml(json['title'] ?? 'Untitled'),
      description: _stripHtml(json['description'] ?? ''),
      // news api truncates content with "[+123 chars]" - we clean that up
      content: _cleanContent(json['content'] ?? json['description'] ?? ''),
      imageUrl: json['urlToImage'],
      source: json['source']?['name'] ?? 'Unknown',
      author: json['author'],
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      url: json['url'] ?? '',
    );
  }

  // strip html tags and decode common entities
  static String _stripHtml(String text) {
    // remove html tags
    var cleaned = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // decode common html entities
    cleaned = cleaned
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&#x27;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&hellip;', '…')
        .replaceAll(RegExp(r'&#\d+;'), ''); // remove remaining numeric entities
    return cleaned.trim();
  }

  // remove the "[+123 chars]" suffix that news api adds
  static String _cleanContent(String content) {
    final regex = RegExp(r'\[\+\d+ chars\]$');
    return _stripHtml(content.replaceAll(regex, ''));
  }

  // format date nicely
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(publishedAt);
    
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${publishedAt.day}/${publishedAt.month}/${publishedAt.year}';
    }
  }
}

// service to fetch wellness/mental health articles
class ArticleService {
  static const _baseUrl = 'https://newsapi.org/v2/everything';
  
  String get _apiKey => dotenv.env['NEWS_API_KEY'] ?? '';

  // wellness-focused keywords for each category
  static const Map<String, String> categoryKeywords = {
    'Meditation': 'meditation mindfulness calm relaxation',
    'Anxiety': 'anxiety management coping mental health',
    'Stress': 'stress relief management wellness',
    'Sleep': 'sleep health insomnia rest wellness',
    'Self Growth': 'self improvement personal growth motivation mindset',
  };

  // fetch articles for a specific category
  Future<List<Article>> fetchArticles({
    required String category,
    int pageSize = 20,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'your_news_api_key_here') {
      throw Exception('Please add your NEWS_API_KEY to the .env file');
    }

    final keywords = categoryKeywords[category] ?? category;
    
    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': keywords,
        'language': 'en',
        'sortBy': 'relevancy',
        'pageSize': pageSize.toString(),
        'apiKey': _apiKey,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] != 'ok') {
          throw Exception(data['message'] ?? 'Failed to fetch articles');
        }

        final articles = (data['articles'] as List)
            .map((json) => Article.fromJson(json))
            // filter out articles with missing essential data
            .where((a) => a.title.isNotEmpty && a.title != '[Removed]')
            .where((a) => a.description.isNotEmpty)
            .toList();

        return articles;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Check your NEWS_API_KEY in .env');
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Try again later.');
      } else {
        throw Exception('Failed to load articles (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('Error fetching articles: $e');
      rethrow;
    }
  }

  // fetch popular/trending wellness articles (for the Popular section)
  Future<List<Article>> fetchPopularArticles({int pageSize = 10}) async {
    if (_apiKey.isEmpty || _apiKey == 'your_news_api_key_here') {
      throw Exception('Please add your NEWS_API_KEY to the .env file');
    }

    try {
      final uri = Uri.parse(_baseUrl).replace(queryParameters: {
        'q': 'mental health wellness mindfulness self-care',
        'language': 'en',
        'sortBy': 'popularity',
        'pageSize': pageSize.toString(),
        'apiKey': _apiKey,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] != 'ok') {
          throw Exception(data['message'] ?? 'Failed to fetch articles');
        }

        final articles = (data['articles'] as List)
            .map((json) => Article.fromJson(json))
            .where((a) => a.title.isNotEmpty && a.title != '[Removed]')
            .where((a) => a.description.isNotEmpty)
            .toList();

        return articles;
      } else {
        throw Exception('Failed to load popular articles');
      }
    } catch (e) {
      debugPrint('Error fetching popular articles: $e');
      rethrow;
    }
  }
}
