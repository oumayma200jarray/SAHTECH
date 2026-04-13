import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/models/medical_document_model.dart';
import 'package:sahtek/features/specialists/services/specialist_service.dart';

class MedicalCategoryDetailPage extends StatefulWidget {
  const MedicalCategoryDetailPage({super.key});

  @override
  State<MedicalCategoryDetailPage> createState() =>
      _MedicalCategoryDetailPageState();
}

class _MedicalCategoryDetailPageState extends State<MedicalCategoryDetailPage> {
  List<MedicalDocument> _documents = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final patient = args['patient'] as PatientModel;
    final category = args['category'] as String;

    final allDocs = await SpecialistService.fetchMedicalRecords(patient.userId);
    if (mounted) {
      setState(() {
        _documents = allDocs.where((doc) => doc.category == category).toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadFile() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final patient = args['patient'] as PatientModel;
    final category = args['category'] as String;

    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'dcm', 'dicom'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      setState(() => _isUploading = true);

      // Création du modèle temporaire
      final doc = MedicalDocument(
        id: '', // Le backend générera l'ID
        title: fileName.split('.').first,
        date: DateTime.now(),
        type: fileName.toLowerCase().endsWith('.pdf')
            ? DocumentType.pdf
            : (fileName.toLowerCase().endsWith('.dcm') ||
                  fileName.toLowerCase().endsWith('.dicom'))
            ? DocumentType.dicom
            : DocumentType.image,
        category: category,
        fileUrl: '', // Sera rempli par l'upload
      );

      final success = await SpecialistService.uploadMedicalRecord(
        patient.userId,
        doc,
        file,
      );

      if (mounted) {
        setState(() => _isUploading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('document_uploaded_success'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          _loadDocuments();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('document_uploaded_error'.tr()),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final patient = args['patient'] as PatientModel;
    final category = args['category'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFD),
      appBar: _buildAppBar(category, patient),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUploadCard(),
                  const SizedBox(height: 40),
                  _buildRecentDocsHeader(),
                  const SizedBox(height: 20),
                  _buildDocumentsList(),
                ],
              ),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(String category, PatientModel patient) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0D54F2)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        category.tr(),
        style: const TextStyle(
          color: Color(0xFF1A1C1E),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: patient.imageUrl.isNotEmpty
                ? NetworkImage(patient.imageUrl)
                : null,
            child: patient.imageUrl.isEmpty
                ? Text(patient.fullName[0].toUpperCase())
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.unarchive_outlined,
              color: Color(0xFF0D54F2),
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'add_document'.tr(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'add_document_desc'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadFile,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.file_upload_outlined),
              label: Text(
                _isUploading ? 'uploading'.tr() : 'upload_file_button'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D54F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'recent_documents'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C1E),
          ),
        ),
        Text(
          '${_documents.length} ${'files_label'.tr().toUpperCase()}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsList() {
    if (_documents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'no_documents_found'.tr(),
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _documents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final doc = _documents[index];
        return _buildDocCard(doc);
      },
    );
  }

  Widget _buildDocCard(MedicalDocument doc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              doc.type == DocumentType.pdf
                  ? Icons.description_outlined
                  : Icons.image_outlined,
              color: Colors.grey[400],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildTypeTag(doc.type.name.toUpperCase()),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(doc.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Action pour visionner le document
            },
            icon: const Icon(
              Icons.visibility_outlined,
              color: Color(0xFF0D54F2),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFC),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0D54F2),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'added_today'.tr();
    if (diff.inDays == 1) return 'added_yesterday'.tr();
    return 'added_format'.tr(args: [DateFormat('dd MMM').format(date)]);
  }
}
