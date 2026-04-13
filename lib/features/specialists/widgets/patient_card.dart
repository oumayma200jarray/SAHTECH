import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/patient_model.dart';

/// Reusable card widget displaying a patient's name
/// with action buttons for medical folder and exercise.
class PatientCard extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onAddMedicalFolder;
  final VoidCallback onAddExercise;

  const PatientCard({
    Key? key,
    required this.patient,
    required this.onAddMedicalFolder,
    required this.onAddExercise,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient name
          Text(
            patient.fullName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // "Ajouter dossier médical" button
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onAddMedicalFolder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8ECF0),
                      foregroundColor: const Color(0xFF3A3F47),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'add_medical_folder'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // "Ajouter exercice" button
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onAddExercise,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D54F2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'add_exercise'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
