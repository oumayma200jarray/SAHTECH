import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/medical_document_model.dart';
import 'package:easy_localization/easy_localization.dart';

class MedicalFolderPage extends StatelessWidget {
  const MedicalFolderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'medical_folder'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'recent_documents'.tr(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'see_all_docs'.tr(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 170, // Ajusté pour le bouton
              child: Consumer<GlobalDataProvider>(
                builder: (context, provider, child) {
                  if (provider.medicalDocuments.isEmpty) {
                    return _buildEmptyRecentDocs();
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.medicalDocuments.length,
                    itemBuilder: (context, index) {
                      final doc = provider.medicalDocuments[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildRecentDocCard(context, doc),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'categories'.tr().toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Consumer<GlobalDataProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    _buildCategoryItem(
                      context,
                      Icons.grid_view,
                      'x_rays'.tr(),
                      provider.getCountByCategory('Radiographies').toString(),
                      Colors.blue,
                    ),
                    _buildCategoryItem(
                      context,
                      Icons.description_outlined,
                      'prescriptions'.tr(),
                      provider.getCountByCategory('Prescriptions').toString(),
                      Colors.purple,
                    ),
                    _buildCategoryItem(
                      context,
                      Icons.person_outline,
                      'physio_reports'.tr(),
                      provider.getCountByCategory('Bilans de Kiné').toString(),
                      Colors.orange,
                    ),
                    _buildCategoryItem(
                      context,
                      Icons.opacity,
                      'blood_tests'.tr(),
                      provider
                          .getCountByCategory('Analyses de sang')
                          .toString(),
                      Colors.red,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _simulateAddDocument(context),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyRecentDocs() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, color: Colors.grey[300], size: 40),
            const SizedBox(height: 8),
            Text(
              'no_recent_document'.tr(),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateAddDocument(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context, listen: false);

    final categories = [
      'Radiographies',
      'Prescriptions',
      'Bilans de Kiné',
      'Analyses de sang',
    ];
    final randomCategory =
        categories[provider.medicalDocuments.length % categories.length];

    final newDoc = MedicalDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Doc #${provider.medicalDocuments.length + 1}',
      date: DateTime.now(),
      type: provider.medicalDocuments.length % 2 == 0 ? DocumentType.pdf : DocumentType.image,
      category: randomCategory,
      fileUrl: '',
    );

    provider.addMedicalDocument(newDoc);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${"new_document_added".tr()} ${randomCategory.tr()}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildRecentDocCard(BuildContext context, MedicalDocument doc) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 90,
                  width: double.infinity,
                  color: Colors.grey[50],
                  child: Center(
                    child: Icon(
                      doc.type == DocumentType.pdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.image_outlined,
                      color: Colors.grey[300],
                      size: 32,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '.${doc.type}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat(
                    'dd MMM yyyy',
                    context.locale.languageCode,
                  ).format(doc.date),
                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 24,
                  child: TextButton(
                    onPressed: () {
                      Provider.of<GlobalDataProvider>(
                        context,
                        listen: false,
                      ).markDocumentAsViewed(doc.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('open_document'.tr())),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.blue.withAlpha(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'consult'.tr(),
                      style: const TextStyle(fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    IconData icon,
    String title,
    String count,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'category_info'.tr(namedArgs: {'title': title, 'count': count}),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      count == '0'
                          ? 'no_document'.tr()
                          : 'latest_recent_addition'.tr(),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
