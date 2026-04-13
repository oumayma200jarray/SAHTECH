import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sahtek/features/specialists/screens/ListPatients.dart';
import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/models/exercise_assignment_model.dart';
import 'package:sahtek/features/specialists/services/specialist_service.dart';
import 'package:sahtek/features/specialists/widgets/patient_info_header.dart';
import 'package:sahtek/features/specialists/widgets/exercise_type_dropdown.dart';
import 'package:sahtek/features/specialists/widgets/video_picker_field.dart';
import 'package:sahtek/features/specialists/widgets/numeric_input_field.dart';

class PublierExercicePage extends StatefulWidget {
  const PublierExercicePage({Key? key}) : super(key: key);

  @override
  State<PublierExercicePage> createState() => _PublierExercicePageState();
}

class _PublierExercicePageState extends State<PublierExercicePage> {
  // ─── Controllers ─────────────────────────────────────────────────────────
  final TextEditingController _durationController = TextEditingController(
    text: '30',
  );
  final TextEditingController _repetitionsController = TextEditingController(
    text: '10',
  );

  // ─── State ───────────────────────────────────────────────────────────────
  List<String> _exerciseTypes = [];
  String? _selectedExerciseType;
  File? _selectedFile;
  String? _selectedFileName;
  bool _isLoading = false;
  bool _isLoadingTypes = true;

  @override
  void initState() {
    super.initState();
    _loadExerciseTypes();
  }

  Future<void> _loadExerciseTypes() async {
    final types = await SpecialistService.fetchExerciseTypes();
    if (mounted) {
      setState(() {
        _exerciseTypes = types;
        _selectedExerciseType = types.isNotEmpty ? types.first : null;
        _isLoadingTypes = false;
      });
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _repetitionsController.dispose();
    super.dispose();
  }

  // ─── Handlers ────────────────────────────────────────────────────────────

  Future<void> _pickVideoFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeInMB = file.lengthSync() / (1024 * 1024);

      if (sizeInMB > 50) {
        _showSnackBar('file_too_large'.tr(), isError: true);
        return;
      }

      setState(() {
        _selectedFile = file;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0D54F2),
      ),
    );
  }

  Future<void> _publish(PatientModel patient) async {
    if (_selectedExerciseType == null) return;

    final duration = int.tryParse(_durationController.text) ?? 0;
    final repetitions = int.tryParse(_repetitionsController.text) ?? 0;

    if (duration <= 0 || repetitions <= 0) {
      _showSnackBar('invalid_exercise_fields'.tr(), isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final assignment = ExerciseAssignment(
      patientId: patient.userId,
      exerciseType: _selectedExerciseType!,
      duration: duration,
      repetitions: repetitions,
      videoFile: _selectedFile,
    );

    final success = await SpecialistService.publishExercise(assignment);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSnackBar('exercise_published_success'.tr());
        Navigator.pop(context, true);
      } else {
        _showSnackBar('exercise_published_error'.tr(), isError: true);
      }
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final patient = ModalRoute.of(context)!.settings.arguments as PatientModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PatientInfoHeader(patient: patient),
            const SizedBox(height: 28),
            ExerciseTypeDropdown(
              items: _exerciseTypes,
              selectedItem: _selectedExerciseType,
              isLoading: _isLoadingTypes,
              onChanged: (val) => setState(() => _selectedExerciseType = val),
            ),
            const SizedBox(height: 24),
            VideoPickerField(
              selectedFile: _selectedFile,
              fileName: _selectedFileName,
              onTap: _pickVideoFile,
            ),
            const SizedBox(height: 24),
            NumericInputField(
              label: 'duration_label'.tr(),
              controller: _durationController,
              icon: Icons.timer_outlined,
            ),
            const SizedBox(height: 24),
            NumericInputField(
              label: 'repetitions_label'.tr(),
              controller: _repetitionsController,
              icon: Icons.repeat,
            ),
            const SizedBox(height: 40),
            _buildSubmitButton(patient),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: _buildAppBarLeading(),
      title: Text(
        'assign_exercise_title'.tr(),
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildAppBarLeading() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.08),
        radius: 20,
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0D54F2),
            size: 20,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListePatientsPage()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSubmitButton(PatientModel patient) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : () => _publish(patient),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send, size: 20),
        label: Text(
          _isLoading ? 'publishing'.tr() : 'publish_button'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D54F2),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: const Color(0xFF0D54F2).withOpacity(0.6),
        ),
      ),
    );
  }
}
