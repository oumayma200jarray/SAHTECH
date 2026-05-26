import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/services/local_notification_service.dart';
import 'package:sahtek/models/patient_assignment_model.dart';
import 'package:sahtek/services/exercise_socket_service.dart';

enum ExerciseFilter { all, todo, done }

class PatientExercisesController extends ChangeNotifier {
  List<PatientAssignment> _assignments = [];
  bool isLoading = false;
  String? error;
  bool isFetched = false;
  ExerciseFilter activeFilter = ExerciseFilter.all;

  StreamSubscription<Map<String, dynamic>>? _socketSub;

  List<PatientAssignment> get assignments => _assignments;

  List<PatientAssignment> get filteredAssignments {
    switch (activeFilter) {
      case ExerciseFilter.all:
        return _assignments;
      case ExerciseFilter.todo:
        return _assignments.where((a) => !a.isCompleted).toList();
      case ExerciseFilter.done:
        return _assignments.where((a) => a.isCompleted).toList();
    }
  }

  int get completedCount => _assignments.where((a) => a.isCompleted).length;
  int get totalCount => _assignments.length;

  PatientExercisesController() {
    _subscribeToSocket();
  }

  Future<void> loadAssignments({bool force = false}) async {
    if (isFetched && !force) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final data = await EndPoint.client.get(EndPoint.assignedExercises);
      _assignments = (data as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(PatientAssignment.fromJson)
          .toList();
      isFetched = true;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markCompleted(String assignmentId) async {
    try {
      final data = await EndPoint.client.patch(
        EndPoint.markAssignmentComplete(assignmentId),
      );
      final raw = data is Map<String, dynamic>
          ? ((data['data'] ?? data) as Map<String, dynamic>)
          : <String, dynamic>{};
      final updated = PatientAssignment.fromJson(raw);
      final idx =
          _assignments.indexWhere((a) => a.assignmentId == assignmentId);
      if (idx != -1) {
        _assignments[idx] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      debugPrint('markCompleted error: $e');
      return false;
    }
  }

  void setFilter(ExerciseFilter filter) {
    activeFilter = filter;
    notifyListeners();
  }

  void _addFromSocket(Map<String, dynamic> payload) {
    final exerciseData = <String, dynamic>{
      'exerciseId': payload['assignmentId'] ?? '',
      'name': payload['exerciseName'] ?? '',
      'description': payload['description'],
      'videoUrl': payload['videoUrl'],
      'category': payload['category'],
      'side': payload['side'],
    };
    final assignment = PatientAssignment.fromJson({
      'assignmentId': payload['assignmentId'] ?? '',
      'repetitions': 0,
      'series': 0,
      'seancesParJour': 1,
      'isCompleted': false,
      'createdAt': DateTime.now().toIso8601String(),
      'exercise': exerciseData,
    });
    _assignments.insert(0, assignment);
    notifyListeners();
  }

  void _subscribeToSocket() {
    _socketSub = ExerciseSocketService.instance.exerciseAssignedStream.listen(
      (payload) async {
        _addFromSocket(payload);
        final doctorName =
            payload['doctorName']?.toString() ?? 'Votre médecin';
        final exerciseName =
            payload['exerciseName']?.toString() ?? 'un exercice';
        await LocalNotificationService.showChatNotification(
          title: 'Nouvel exercice assigné',
          body: '$doctorName vous a assigné : $exerciseName',
        );
      },
    );
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }
}
