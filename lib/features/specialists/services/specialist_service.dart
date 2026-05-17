import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/models/specialist_model.dart';
import 'package:sahtek/models/exercise_assignment_model.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/models/medical_document_model.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'dart:io';

class SpecialistService {
  static Future<List<SpecialistModel>> fetchSpecialists({
    String query = '',
  }) async {
    try {
      final normalizedQuery = query.trim().isEmpty ? ' ' : query.trim();
      final List<dynamic> data = await EndPoint.client.get(
        EndPoint.specialists(normalizedQuery),
      );
      return data.map((json) => SpecialistModel.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ fetchSpecialists error: $e');
      return [];
    }
  }

  static Future<SpecialistModel?> fetchSpecialistById(String userId) async {
    try {
      final dynamic data = await EndPoint.client.get(
        EndPoint.specialistById(userId),
      );

      if (data is Map<String, dynamic>) {
        return SpecialistModel.fromJson(data);
      }

      return null;
    } catch (e) {
      print('⚠️ fetchSpecialistById error: $e');
      return null;
    }
  }

  /// Récupère la liste des patients assignés au spécialiste connecté
  static Future<List<PatientModel>> fetchMyPatients() async {
    try {
      final List<dynamic> data = await EndPoint.client.get(EndPoint.myPatients);
      return data.map((json) => PatientModel.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ fetchMyPatients error: $e');
      return [];
    }
  }

  /// Récupère les exercices assignés au patient actuel
  static Future<List<ContentModel>> fetchMyExercises() async {
    try {
      final List<dynamic> data = await EndPoint.client.get(
        EndPoint.myExercises,
      );
      // On convertit les ExerciseAssignment du backend en ContentModel pour l'UI
      return data.map((json) {
        final assignment = ExerciseAssignment.fromJson(json);
        return ContentModel.fromJson(assignment.toContentJson());
      }).toList();
    } catch (e) {
      print('⚠️ fetchMyExercises error: $e');
      return [];
    }
  }

  /// Récupère le dossier médical complet d'un patient
  static Future<List<MedicalDocument>> fetchMedicalRecords(
    String patientId,
  ) async {
    try {
      final List<dynamic> data = await EndPoint.client.get(
        EndPoint.medicalRecords(patientId),
      );
      return data.map((json) => MedicalDocument.fromJson(json)).toList();
    } catch (e) {
      print('⚠️ fetchMedicalRecords error: $e');
      return [];
    }
  }

  /// Upload un nouveau document médical pour un patient
  static Future<bool> uploadMedicalRecord(
    String patientId,
    MedicalDocument doc,
    File file,
  ) async {
    try {
      // 1. Envoyer les métadonnées
      await EndPoint.client.post(
        EndPoint.medicalRecords(patientId),
        body: doc.toJson(),
      );

      // 2. Upload effectif du fichier
      await EndPoint.client.uploadFile(
        EndPoint.uploadMedicalRecord(patientId),
        file: file,
        fieldName: 'file',
      );

      return true;
    } catch (e) {
      print('⚠️ uploadMedicalRecord error: $e');
      return false;
    }
  }

  /// Publie un exercice assigné à un patient
  /// Envoie les données + vidéo au backend
  static Future<bool> publishExercise(ExerciseAssignment assignment) async {
    try {
      // Étape 1 : Envoyer les métadonnées de l'exercice
      final response = await EndPoint.client.post(
        EndPoint.publishExercise,
        body: assignment.toJson(),
      );

      // Étape 2 : Upload de la vidéo si présente
      if (assignment.videoFile != null && response != null) {
        final exerciseId = response['id']?.toString() ?? '';
        if (exerciseId.isNotEmpty) {
          await EndPoint.client.uploadFile(
            '${EndPoint.uploadExerciseVideo}/$exerciseId',
            file: assignment.videoFile!,
            fieldName: 'video',
          );
        }
      }

      return true;
    } catch (e) {
      print('⚠️ publishExercise error: $e');
      return false;
    }
  }

  /// Récupère la liste des types d'exercices disponibles depuis le backend
  static Future<List<String>> fetchExerciseTypes() async {
    try {
      final List<dynamic> data = await EndPoint.client.get(
        '${EndPoint.publishExercise}/types',
      );
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      print('⚠️ fetchExerciseTypes error: $e');
      // Fallback : types par défaut si le backend ne répond pas
      return [
        'Squat',
        'Flexion de l\'épaule',
        'Abduction de l\'épaule',
        'Rotation externe',
        'Extension du genou',
        'Flexion du coude',
      ];
    }
  }

  /// Filtre local des patients par nom, email ou téléphone
  static List<PatientModel> searchPatients(
    List<PatientModel> allPatients,
    String text,
  ) {
    if (text.isEmpty) return allPatients;

    final query = text.toLowerCase().trim();

    return allPatients.where((patient) {
      final nameMatch = patient.fullName.toLowerCase().contains(query);
      final emailMatch = patient.email.toLowerCase().contains(query);
      final phoneMatch = patient.phone.toLowerCase().contains(query);
      return nameMatch || emailMatch || phoneMatch;
    }).toList();
  }
}
