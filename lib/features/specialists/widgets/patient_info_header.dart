import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/patient_model.dart';

class PatientInfoHeader extends StatelessWidget {
  final PatientModel patient;

  const PatientInfoHeader({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          _buildPatientDetails(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFE3EAFF),
      backgroundImage: patient.imageUrl.isNotEmpty ? NetworkImage(patient.imageUrl) : null,
      child: patient.imageUrl.isEmpty
          ? Text(
              patient.fullName.isNotEmpty ? patient.fullName[0].toUpperCase() : 'P',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D54F2),
              ),
            )
          : null,
    );
  }

  Widget _buildPatientDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'patient_context'.tr(),
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          patient.fullName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A1C1E),
          ),
        ),
      ],
    );
  }
}
