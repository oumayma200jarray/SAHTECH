import 'package:flutter/material.dart';

class NumericInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;

  const NumericInputField({
    Key? key,
    required this.label,
    required this.controller,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.15)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1C1E),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF0D54F2), size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}
