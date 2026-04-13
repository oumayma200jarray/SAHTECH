import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/features/specialists/services/specialist_service.dart';
import 'package:sahtek/models/medical_document_model.dart';

class SpecialistMedicalFolderPage extends StatefulWidget {
  const SpecialistMedicalFolderPage({super.key});

  @override
  State<SpecialistMedicalFolderPage> createState() => _SpecialistMedicalFolderPageState();
}

class _SpecialistMedicalFolderPageState extends State<SpecialistMedicalFolderPage> {
  List<MedicalDocument> _allDocuments = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDossier();
  }

  Future<void> _loadDossier() async {
    final patient = ModalRoute.of(context)!.settings.arguments as PatientModel;
    final docs = await SpecialistService.fetchMedicalRecords(patient.userId);
    if (mounted) {
      setState(() {
        _allDocuments = docs;
        _isLoading = false;
      });
    }
  }

  int _getCountByCategory(String category) {
    return _allDocuments.where((doc) => doc.category == category).length;
  }

  @override
  Widget build(BuildContext context) {
    final patient = ModalRoute.of(context)!.settings.arguments as PatientModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(patient),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(patient),
                  const SizedBox(height: 32),
                  Text(
                    'categories'.tr().toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildCategoriesGrid(patient),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(PatientModel patient) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.08),
          radius: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0D54F2), size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text(
        'medical_folder'.tr(),
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(PatientModel patient) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color(0xFFE3EAFF),
          backgroundImage: patient.imageUrl.isNotEmpty ? NetworkImage(patient.imageUrl) : null,
          child: patient.imageUrl.isEmpty
              ? Text(
                  patient.fullName[0].toUpperCase(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D54F2)),
                )
              : null,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 4),
            Text(
              'patient_medical_record_desc'.tr(),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoriesGrid(PatientModel patient) {
    final categories = [
      {'title': 'Radiographies', 'icon': Icons.grid_view, 'color': Colors.blue},
      {'title': 'Prescriptions', 'icon': Icons.description_outlined, 'color': Colors.purple},
      {'title': 'Bilans cliniques', 'icon': Icons.person_outline, 'color': Colors.orange},
      {'title': 'Analyses de sang', 'icon': Icons.opacity, 'color': Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final count = _getCountByCategory(cat['title'] as String);
        return _buildCategoryCard(cat, count, patient);
      },
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat, int count, PatientModel patient) {
    final color = cat['color'] as Color;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/medical_category_detail',
          arguments: {
            'patient': patient,
            'category': cat['title'],
            'color': color,
          },
        ).then((_) => _loadDossier()); // Refresh on return
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat['icon'] as IconData, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (cat['title'] as String).tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1C1E)),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${'files_count'.tr()}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
