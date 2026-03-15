import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/models/medical_document_model.dart';
import 'package:easy_localization/easy_localization.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.blue,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'my_favorites'.tr(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            tabs: [
              Tab(text: 'videos'.tr()),
              Tab(text: 'articles'.tr()),
              Tab(text: 'documents'.tr()),
            ],
          ),
        ),
        body: Consumer<GlobalDataProvider>(
          builder: (context, provider, child) {
            return TabBarView(
              children: [
                _buildContentList(
                  context,
                  provider.viewedVideos,
                  'videos'.tr().toLowerCase(),
                ),
                _buildContentList(
                  context,
                  provider.viewedArticles,
                  'articles'.tr().toLowerCase(),
                ),
                _buildDocumentList(context, provider.viewedDocuments),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentList(
    BuildContext context,
    List<ContentModel> items,
    String type,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(
        'no_viewed_content'.tr(namedArgs: {'type': type}),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildListItem(
          title: item.title,
          subtitle:
              item.subtitle ??
              item.author ??
              '${item.duration ?? ""} • ${"viewed".tr()}',
          imageUrl: item.imageUrl ?? '',
          isDocument: false,
        );
      },
    );
  }

  Widget _buildDocumentList(BuildContext context, List<MedicalDocument> items) {
    if (items.isEmpty) {
      return _buildEmptyState('no_viewed_documents'.tr());
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final doc = items[index];
        return _buildListItem(
          title: doc.title,
          subtitle:
              '${doc.category} • ${DateFormat('dd MMM yyyy', context.locale.toString()).format(doc.date)}',
          imageUrl: '', // On utilisera une icône par défaut
          isDocument: true,
          type: doc.type,
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: Colors.grey[300], size: 60),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required String subtitle,
    required String imageUrl,
    required bool isDocument,
    String? type,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: isDocument
                ? Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[50],
                    child: Icon(
                      type?.toUpperCase() == 'PDF'
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      color: Colors.blue.withAlpha(100),
                      size: 40,
                    ),
                  )
                : imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.blue,
                      ),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[100],
                    child: const Icon(
                      Icons.article_outlined,
                      color: Colors.blue,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.favorite, color: Colors.blue, size: 18),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
