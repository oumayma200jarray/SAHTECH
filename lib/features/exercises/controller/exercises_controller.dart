import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/config/app_config.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/models/exercise_model.dart';

class ExercisesController extends ChangeNotifier {
  // ─── My exercises ────────────────────────────────────────────────────────
  List<ExerciseModel> myExercises = [];
  bool isLoadingMy = false;
  String? myError;

  // ─── Public exercises ────────────────────────────────────────────────────
  List<ExerciseModel> publicExercises = [];
  bool isLoadingPublic = false;
  String? publicError;
  bool publicFetched = false;

  // ─── Patients (for assign modal) ─────────────────────────────────────────
  List<Map<String, dynamic>> patients = [];
  bool isLoadingPatients = false;
  String? patientsError;

  // ─── Operation flags ─────────────────────────────────────────────────────
  bool isSaving = false;
  bool isDeleting = false;
  bool isAssigning = false;

  // ─── Load my exercises ───────────────────────────────────────────────────
  Future<void> loadMyExercises() async {
    isLoadingMy = true;
    myError = null;
    notifyListeners();
    try {
      final data = await EndPoint.client.get(EndPoint.doctorExercises);
      myExercises = (data as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ExerciseModel.fromJson)
          .toList();
    } catch (e) {
      myError = e.toString();
    } finally {
      isLoadingMy = false;
      notifyListeners();
    }
  }

  // ─── Load public exercises (lazy) ────────────────────────────────────────
  Future<void> loadPublicExercises() async {
    if (publicFetched) return;
    isLoadingPublic = true;
    publicError = null;
    notifyListeners();
    try {
      final data = await EndPoint.client.get(EndPoint.publicExercises);
      publicExercises = (data as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ExerciseModel.fromJson)
          .toList();
      publicFetched = true;
    } catch (e) {
      publicError = e.toString();
    } finally {
      isLoadingPublic = false;
      notifyListeners();
    }
  }

  // ─── Load patients for assign modal ─────────────────────────────────────
  Future<void> loadPatients() async {
    isLoadingPatients = true;
    patientsError = null;
    patients = [];
    notifyListeners();
    try {
      final data = await EndPoint.client.get(EndPoint.doctorGetPatients);
      final list = (data is Map ? data['patients'] : data) as List? ?? [];
      patients = list.whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      patientsError = e.toString();
    } finally {
      isLoadingPatients = false;
      notifyListeners();
    }
  }

  // ─── Create or update exercise ───────────────────────────────────────────
  Future<bool> saveExercise({
    ExerciseModel? existing,
    required String name,
    required String description,
    required List<String> categories,
    required List<String> sides,
    required String videoUrl,
    required bool isPublic,
    File? videoFile,
  }) async {
    isSaving = true;
    notifyListeners();
    try {
      final payload = <String, dynamic>{
        'name': name,
        'description': description,
        'isPublic': isPublic,
        'category': categories,
        'side': sides,
        if (videoUrl.isNotEmpty) 'videoUrl': videoUrl,
      };

      ExerciseModel exercise;
      if (videoFile != null) {
        exercise = existing != null
            ? await _multipartRequest(
                'PATCH',
                EndPoint.doctorExerciseById(existing.exerciseId),
                payload,
                videoFile,
              )
            : await _multipartRequest(
                'POST',
                EndPoint.doctorExercises,
                payload,
                videoFile,
              );
      } else {
        if (existing != null) {
          final data = await EndPoint.client.patch(
            EndPoint.doctorExerciseById(existing.exerciseId),
            body: payload,
          );
          exercise = ExerciseModel.fromJson(data as Map<String, dynamic>);
        } else {
          final data = await EndPoint.client.post(
            EndPoint.doctorExercises,
            body: payload,
          );
          exercise = ExerciseModel.fromJson(data as Map<String, dynamic>);
        }
      }

      if (existing != null) {
        final idx = myExercises.indexWhere(
          (e) => e.exerciseId == existing.exerciseId,
        );
        if (idx != -1) myExercises[idx] = exercise;
      } else {
        myExercises.insert(0, exercise);
      }
      return true;
    } catch (e) {
      debugPrint('saveExercise error: $e');
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // ─── Delete exercise ─────────────────────────────────────────────────────
  Future<bool> deleteExercise(String id) async {
    isDeleting = true;
    notifyListeners();
    try {
      await EndPoint.client.delete(EndPoint.doctorExerciseById(id));
      myExercises.removeWhere((e) => e.exerciseId == id);
      return true;
    } catch (e) {
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  // ─── Assign exercise to patient ──────────────────────────────────────────
  Future<bool> assignExercise({
    required String exerciseId,
    required String patientId,
  }) async {
    isAssigning = true;
    notifyListeners();
    try {
      await EndPoint.client.patch(
        EndPoint.doctorAssignExercise,
        body: {'patientId': patientId, 'exerciceId': exerciseId},
      );
      await loadMyExercises();
      return true;
    } catch (e) {
      return false;
    } finally {
      isAssigning = false;
      notifyListeners();
    }
  }

  // ─── Multipart helper (POST or PATCH) ────────────────────────────────────
  Future<ExerciseModel> _multipartRequest(
    String method,
    String endpoint,
    Map<String, dynamic> data,
    File file,
  ) async {
    final token = await StorageService.getAccessToken();
    final url = Uri.parse('${AppConfig.apiBaseUrl}/$endpoint');
    final request = http.MultipartRequest(method, url);
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    request.fields['name'] = data['name']?.toString() ?? '';
    request.fields['description'] = data['description']?.toString() ?? '';
    request.fields['isPublic'] = (data['isPublic'] == true).toString();

    // Send arrays as repeated multipart bytes (no filename = form field)
    for (final cat in (data['category'] as List<String>? ?? [])) {
      request.files.add(
        http.MultipartFile.fromBytes('category', utf8.encode(cat)),
      );
    }
    for (final side in (data['side'] as List<String>? ?? [])) {
      request.files.add(
        http.MultipartFile.fromBytes('side', utf8.encode(side)),
      );
    }

    request.files.add(await http.MultipartFile.fromPath('video', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ExerciseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Upload failed: ${response.statusCode}');
  }
}
