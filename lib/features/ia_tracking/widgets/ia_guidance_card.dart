import 'package:flutter/material.dart';

class IAGuidanceCard extends StatelessWidget {
  final String message;
  final bool isError;
  final bool isLoading;

  const IAGuidanceCard({
    Key? key,
    required this.message,
    this.isError = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError ? Colors.red[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isError ? Colors.red : Colors.blue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              isError ? Icons.warning_amber_rounded : Icons.info_outline,
              color: isError ? Colors.red : Colors.blue,
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isError ? Colors.red[900] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
