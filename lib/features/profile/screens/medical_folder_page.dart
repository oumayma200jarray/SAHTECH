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
      type: provider.medicalDocuments.length % 2 == 0
          ? DocumentType.pdf
          : DocumentType.image,
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
