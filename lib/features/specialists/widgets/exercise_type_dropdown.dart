import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ExerciseTypeDropdown extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

  const ExerciseTypeDropdown({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'choose_exercise_label'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedItem,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF0D54F2),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1C1E),
                    ),
                    items: items.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
        ),
      ],
    );
  }
}
