import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sahtek/features/dashboard/services/dashboard_services.dart';

class NouvellePublicationPage extends StatefulWidget {
  const NouvellePublicationPage({Key? key}) : super(key: key);

  @override
  State<NouvellePublicationPage> createState() => _NouvellePublicationPageState();
}

class _NouvellePublicationPageState extends State<NouvellePublicationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  String _publicationType = 'Video'; // 'Article' or 'Video'
  File? _selectedFile;
  String? _selectedFileName;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _publicationType == 'Video' ? ['mp4', 'mov'] : ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeInMB = file.lengthSync() / (1024 * 1024);

      if (sizeInMB > 50) {
        _showSnackBar('file_too_large'.tr(), isError: true);
        return;
      }

      setState(() {
        _selectedFile = file;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0D54F2),
      ),
    );
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showSnackBar('please_enter_title'.tr(), isError: true);
      return;
    }
    
    if (_selectedFile == null) {
       _showSnackBar('please_select_file'.tr(), isError: true);
       return;
    }

    setState(() => _isLoading = true);

    // Call service to publish
    final success = await SpecialistDashboardService.publishDocument(
      title: title,
      description: _descController.text,
      type: _publicationType,
      file: _selectedFile!,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSnackBar('document_published_success'.tr());
        Navigator.pop(context, true);
      } else {
        _showSnackBar('error_publishing'.tr(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.08),
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D54F2), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'new_publication'.tr(),
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Publication Type Selector
            Text('content_type'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTypeOption('Video', Icons.video_library),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeOption('Article', Icons.article),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title
            Text('title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'ex: Exercice de Flexion',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text('description'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tapez votre description...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // File Picker
            Text('document'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile == null ? Icons.upload_file : Icons.check_circle,
                      color: _selectedFile == null ? Colors.grey[400] : Colors.green,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFile == null
                          ? 'tap_to_select_file'.tr()
                          : _selectedFileName ?? 'Fichier sélectionné',
                      style: TextStyle(
                        color: _selectedFile == null ? Colors.grey[600] : Colors.black87,
                        fontWeight: _selectedFile == null ? FontWeight.normal : FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _publish,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send, size: 20),
                label: Text(
                  _isLoading ? 'publishing'.tr() : 'publish_button'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D54F2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: const Color(0xFF0D54F2).withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String type, IconData icon) {
    final isSelected = _publicationType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _publicationType = type;
          _selectedFile = null;
          _selectedFileName = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D54F2).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D54F2) : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF0D54F2) : Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0D54F2) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
