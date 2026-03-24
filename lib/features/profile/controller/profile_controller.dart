import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/features/auth/services/auth_service.dart';
import 'package:sahtek/features/profile/services/profile_service.dart';
import 'package:sahtek/features/profile/services/upload_image_service.dart';
import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/models/specialist_model.dart';

class ProfileController extends ChangeNotifier {
  bool isLoading = false;
  bool isSaving = false;
  String? errorMessage;
  String? role;
  bool isUploadingImage = false;
  String? imageUrl;

  final ImagePicker _picker = ImagePicker();

  PatientModel? patient;
  SpecialistModel? specialist;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController =
      TextEditingController(); // 👈 add address controller

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

  Future<void> pickAndUploadImage({required BuildContext context}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    isUploadingImage = true;
    imageUrl = null; // 👈 clear old image first to force reload
    notifyListeners();

    try {
      final newImageUrl = await UploadImageService.uploadProfileImage(
        file: File(pickedFile.path),
      );

      // save to storage
      await StorageService.saveSession(
        accessToken: (await StorageService.getAccessToken()) ?? '',
        refreshToken: (await StorageService.getRefreshToken()) ?? '',
        userId: (await StorageService.getUserId()) ?? '',
        role: (await StorageService.getRole()) ?? '',
        imageUrl: newImageUrl,
      );

      // update controller with fixed URL
      imageUrl = UrlHelper.fixImageUrl(newImageUrl); // 👈 update in memory
      notifyListeners();

      // clear Flutter's image cache so NetworkImage reloads 👈
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    } finally {
      isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    final storedImageUrl = await StorageService.getImageUrl();
    imageUrl = UrlHelper.fixImageUrl(storedImageUrl);
    notifyListeners();
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
        imageUrl = UrlHelper.fixImageUrl(patient!.imageUrl);
        ageController.text = patient!.age.toString();
        weightController.text = patient!.weight.toString();
        heightController.text = patient!.height.toString();
      } else {
        specialist = await ProfileService.getSpecialistProfile();
        fullNameController.text = specialist!.fullName;
        emailController.text = specialist!.email;
        phoneController.text = specialist!.phone;
        imageUrl = UrlHelper.fixImageUrl(specialist!.imageUrl);
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

  Future<void> deleteAccount({required BuildContext context}) async {
    // show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_account'.tr()),
        content: Text('delete_account_confirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading = true;
    notifyListeners();

    try {
      await AuthService.deleteAccount();

      // clear all local storage
      await StorageService.clearSession();
      EndPoint.client.clearAuthToken();

      if (!context.mounted) return;

      // navigate to connexion and clear all routes
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('delete_account_error'.tr())));
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
