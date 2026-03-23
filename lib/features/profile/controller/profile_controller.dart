import 'package:flutter/material.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/features/profile/services/profile_service.dart';
import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/models/specialist_model.dart';

class ProfileController extends ChangeNotifier {
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? role;

  PatientModel? patient;
  SpecialistModel? specialist;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController(); // 👈 add address controller

  // Patient controllers
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final ageController = TextEditingController();

  // Specialist controllers
  final specialtyController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final bioController = TextEditingController();
  final clinicController = TextEditingController();
  final locationController = TextEditingController();

  Future<void> loadProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      role = await StorageService.getRole();

      if (role == 'PATIENT') {
        patient = await ProfileService.getPatientProfile();
        debugPrint('Patient profile loaded: $patient');
        fullNameController.text = patient!.fullName;
        emailController.text = patient!.email;
        phoneController.text = patient!.phone;
        addressController.text = patient!.address;
        ageController.text = patient!.age.toString();
        weightController.text = patient!.weight.toString();
        heightController.text = patient!.height.toString();
      } else {
        specialist = await ProfileService.getSpecialistProfile();
        fullNameController.text = specialist!.fullName;
        emailController.text = specialist!.email;
        phoneController.text = specialist!.phone;
        addressController.text = specialist!.location;
        specialtyController.text = specialist!.specialty;
        licenseNumberController.text = specialist!.licenseNumber;
        bioController.text = specialist!.bio;
        clinicController.text = specialist!.clinic;
        locationController.text = specialist!.location;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(BuildContext context) async {
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (role == 'PATIENT' && patient != null) {
        final updated = patient!.copyWith(
          fullName: fullNameController.text,
          email: emailController.text,
          phone: phoneController.text,
          address: addressController.text,
          age: int.tryParse(ageController.text) ?? patient!.age,
          weight: double.tryParse(weightController.text) ?? patient!.weight,
          height: double.tryParse(heightController.text) ?? patient!.height,
        );
        await ProfileService.updatePatientProfile(updated);
        patient = updated;
      } else if (specialist != null) {
        // update specialist if needed
        await ProfileService.updateSpecialistProfile(specialist!);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
      }
    } catch (e) {
      errorMessage = e.toString();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  String get imageUrl {
    if (role == 'PATIENT') return patient?.imageUrl ?? '';
    return specialist?.imageUrl ?? '';
  }

  String get displayName {
    if (role == 'PATIENT') return patient?.fullName ?? '';
    return specialist?.fullName ?? '';
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    weightController.dispose();
    heightController.dispose();
    specialtyController.dispose();
    clinicController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
