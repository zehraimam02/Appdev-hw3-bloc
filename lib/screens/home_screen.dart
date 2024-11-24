import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hw3/bloc/news_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar section
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2EFF6),
        elevation: 0, 
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main headline
            const Text(
              'Headline News',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Subtitle
            const Text(
              'Read Top News Today',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ],
        ),
        // AppBar logo in the top-right corner
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/appBarLogo.png',
              height: 50,
            ),
          ),
        ],
        centerTitle: false,
      ),

      // Body section
      body: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {
          // Show shimmer effect while data is loading
          if (state.status == NewsStatus.loading) {
            return _buildShimmerEffect();
          }
          
          // Show error message in case of failure
          if (state.status == NewsStatus.failure) {
            return Center(child: Text(state.error ?? 'Something went wrong'));
          }

          // Show news articles as a list
          return ListView.builder(
            itemCount: state.articles.length,
            itemBuilder: (context, index) {
              final article = state.articles[index];
              return InkWell(
                onTap: () => _showArticleDetails(context, article), // Show article details on tap
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  elevation: 5,
                  shadowColor: const Color.fromARGB(255, 236, 148, 33).withOpacity(0.5),
                  child: SizedBox(
                    height: 120, // Adjusted height for the article card
                    child: Row(
                      children: [
                        // Article image
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: article.urlToImage != null
                                ? Stack(
                                    children: [
                                      // Placeholder shimmer while the image is loading
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.white,
                                        ),
                                      ),
                                      // Network image
                                      Image.network(
                                        article.urlToImage!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                : const Icon(Icons.image_not_supported, size: 90, color: Colors.grey),
                          ),
                        ),
                        // Article title and metadata
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Article title
                                Text(
                                  article.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Article author
                                Text(
                                  article.author ?? 'Unknown',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                // Publication date
                                Text(
                                  _formatDate(article.publishedAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 120, 119, 119)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Shimmer effect for loading state
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 120,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                // Placeholder for article image
                leading: Container(
                  width: 80,
                  height: 80,
                  color: Colors.white,
                ),
                // Placeholder for title and metadata
                title: Container(
                  height: 16,
                  color: Colors.white,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 100,
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                    Container(
                      height: 12,
                      width: 150,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Show article details in a modal bottom sheet
  void _showArticleDetails(BuildContext context, Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article title
              Text(
                article.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Author and publication date
              Text(
                'By ${article.author ?? "Unknown"}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Published on ${_formatDate(article.publishedAt)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              // Article image
              if (article.urlToImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.urlToImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 200),
                  ),
                ),
              const SizedBox(height: 16),
              // Article description and content
              Text(
                article.description ?? 'No description available',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                article.content ?? 'No content available',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              // Button to view full article
              TextButton(
                onPressed: () => _launchUrl(article.url, context),
                child: const Text('View Full Article'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Format date to a readable format
  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.year}-${date.month}-${date.day}';
  }

  // Launch URL to view full article
  Future<void> _launchUrl(String url, BuildContext context) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView, // Opens in in-app WebView
        );
      } else {
        // Show error message using ScaffoldMessenger
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open the article'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message for any other errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the article'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
