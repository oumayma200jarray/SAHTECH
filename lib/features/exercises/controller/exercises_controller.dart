import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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
      ExerciseModel exercise;

      if (videoFile != null) {
        // File path: raw multipart (mirrors React FormData)
        exercise = await _streamMultipart(
          method: existing != null ? 'PATCH' : 'POST',
          endpoint: existing != null
              ? EndPoint.doctorExerciseById(existing.exerciseId)
              : EndPoint.doctorExercises,
          name: name,
          description: description,
          categories: categories,
          sides: sides,
          isPublic: isPublic,
          videoUrl: videoUrl.isNotEmpty ? videoUrl : null,
          videoFile: videoFile,
        );
      } else {
        // JSON path (mirrors React: api.post(url, payload) with plain object)
        debugPrint('📤 POST JSON → ${EndPoint.doctorExercises}');
        final payload = <String, dynamic>{
          'name': name,
          'description': description,
          'isPublic': isPublic,
          'category': categories,
          'side': sides,
          if (videoUrl.isNotEmpty) 'videoUrl': videoUrl,
        };

        final dynamic data;
        if (existing != null) {
          data = await EndPoint.client.patch(
            EndPoint.doctorExerciseById(existing.exerciseId),
            body: payload,
          );
        } else {
          data = await EndPoint.client.post(
            EndPoint.doctorExercises,
            body: payload,
          );
        }
        debugPrint('📥 response: $data');
        exercise = ExerciseModel.fromJson(data as Map<String, dynamic>);
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

  // ─── Raw multipart using dart:io HttpClient ─────────────────────────────
  // Uses HttpClientRequest.addStream() which pauses the file reader whenever
  // the socket buffer is full (backpressure). This means only one 64 KB chunk
  // lives in RAM at a time — the entire file is never buffered in memory.
  //
  // Text fields have NO Content-Type header → busboy emits 'field' events →
  // multer's fileFilter is never invoked for them.
  // Repeated keys (category × N, side × N) → req.body arrays in multer.
  Future<ExerciseModel> _streamMultipart({
    required String method,
    required String endpoint,
    required String name,
    required String description,
    required List<String> categories,
    required List<String> sides,
    required bool isPublic,
    String? videoUrl,
    required File videoFile,
  }) async {
    final token = await StorageService.getAccessToken();
    final boundary = 'sahtech${DateTime.now().millisecondsSinceEpoch}';
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/$endpoint');
    debugPrint('📤 _streamMultipart $method $uri');

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);

    try {
      final req = await client.openUrl(method, uri);

      req.headers
        ..set(
          HttpHeaders.contentTypeHeader,
          'multipart/form-data; boundary=$boundary',
        )
        ..set(HttpHeaders.acceptHeader, 'application/json');
      if (token != null) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      // Build all text fields into one UTF-8 buffer (single write call)
      final textParts = BytesBuilder();
      void addField(String key, String value) {
        textParts.add(utf8.encode('--$boundary\r\n'));
        textParts.add(
          utf8.encode('Content-Disposition: form-data; name="$key"\r\n'),
        );
        textParts.add(utf8.encode('\r\n'));
        textParts.add(utf8.encode('$value\r\n'));
      }

      addField('name', name);
      addField('description', description);
      addField('isPublic', isPublic.toString());
      if (videoUrl != null) {
        addField('videoUrl', videoUrl);
      }
      for (final cat in categories) {
        addField('category', cat);
      }
      for (final side in sides) {
        addField('side', side);
      }

      final fileName = videoFile.path.split('/').last;
      final mimeType = _videoMimeType(videoFile.path);
      textParts.add(utf8.encode('--$boundary\r\n'));
      textParts.add(
        utf8.encode(
          'Content-Disposition: form-data; name="video"; filename="$fileName"\r\n',
        ),
      );
      textParts.add(utf8.encode('Content-Type: $mimeType\r\n'));
      textParts.add(utf8.encode('\r\n'));

      // Send all text headers in one chunk
      req.add(textParts.takeBytes());

      // Stream the video with backpressure: addStream() pauses the file reader
      // when the socket buffer is full so the entire file is never in RAM.
      await req
          .addStream(videoFile.openRead())
          .timeout(
            const Duration(minutes: 5),
            onTimeout: () => throw Exception('Video upload timed out'),
          );

      req.add(utf8.encode('\r\n--$boundary--\r\n'));
      debugPrint('📤 body sent, awaiting server response…');

      final res = await req.close().timeout(
        const Duration(minutes: 1),
        onTimeout: () => throw Exception('Server response timed out'),
      );
      final body = await utf8.decodeStream(res);
      debugPrint('📥 ${res.statusCode}: $body');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return ExerciseModel.fromJson(jsonDecode(body) as Map<String, dynamic>);
      }
      throw Exception('Multipart failed: ${res.statusCode} — $body');
    } finally {
      client.close();
    }
  }

  String _videoMimeType(String path) {
    final ext = path.toLowerCase().split('.').last;
    return const {
          'mp4': 'video/mp4',
          'mov': 'video/quicktime',
          'avi': 'video/x-msvideo',
          'mkv': 'video/x-matroska',
          'webm': 'video/webm',
          '3gp': 'video/3gpp',
        }[ext] ??
        'video/mp4';
  }
}
