import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class VideoPickerField extends StatelessWidget {
  final File? selectedFile;
  final String? fileName;
  final VoidCallback onTap;

  const VideoPickerField({
    Key? key,
    required this.selectedFile,
    required this.fileName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'upload_exercise_label'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selectedFile != null
                    ? const Color(0xFF0D54F2).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.15),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  selectedFile != null ? Icons.check_circle : Icons.add_to_photos_outlined,
                  color: selectedFile != null ? const Color(0xFF0D54F2) : Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  selectedFile != null ? fileName ?? 'file_selected'.tr() : 'click_to_choose_file'.tr(),
                  style: TextStyle(
                    color: selectedFile != null ? const Color(0xFF1A1C1E) : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (selectedFile == null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'file_format_hint'.tr(),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
