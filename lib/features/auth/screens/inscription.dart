// Redesigned following SAHTECH brand guidelines
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/features/appointments/services/doctor_api_service.dart';
import 'package:sahtek/features/auth/controllers/signup_controller.dart';
import 'package:sahtek/features/auth/screens/map_location_picker.dart';
import 'package:sahtek/models/clinic_model.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _formKey = GlobalKey<FormState>();

  static const blue = Color(0xFF0052FF);
  static const skyBlue = Color(0xFF00A3FF);
  static const pageBackground = Color(0xFFF8FAFF);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0A0F1E);
  static const textSecondary = Color(0xFF64748B);

  final Map<String, String> langageImages = {
    'fr': 'lib/assets/images/fr.png',
    'en': 'lib/assets/images/en.png',
  };

  final TextEditingController nomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final TextEditingController ageController = TextEditingController();
  final TextEditingController poidsController = TextEditingController(
    text: '70',
  );
  final TextEditingController tailleController = TextEditingController(
    text: '175',
  );

  final TextEditingController specialityController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // Clinic picker state (doctor only)
  List<ClinicModel> _availableClinics = [];
  final Set<String> _selectedClinicIds = {};
  String? _primaryClinicId;
  bool _loadingClinics = false;

  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  Future<void> _loadClinics() async {
    setState(() => _loadingClinics = true);
    try {
      final clinics = await DoctorApiService.getClinics();
      if (mounted) setState(() => _availableClinics = clinics);
    } finally {
      if (mounted) setState(() => _loadingClinics = false);
    }
  }

  Future<void> _openMapPicker() async {
    final lat = double.tryParse(latitudeController.text);
    final lng = double.tryParse(longitudeController.text);
    final initial = (lat != null && lng != null) ? LatLng(lat, lng) : null;

    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => MapLocationPicker(initialLocation: initial),
      ),
    );

    if (result != null) {
      latitudeController.text = result.latitude.toStringAsFixed(6);
      longitudeController.text = result.longitude.toStringAsFixed(6);
    }
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    confirmEmailController.dispose();
    telephoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    ageController.dispose();
    poidsController.dispose();
    tailleController.dispose();
    specialityController.dispose();
    bioController.dispose();
    licenseController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupController = Provider.of<SignupController>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = (screenWidth - 40).clamp(280.0, 520.0);
    final localeCode = context.locale.languageCode;

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -70,
              right: -40,
              child: _GlowBlob(
                size: 220,
                colors: [blue.withOpacity(0.22), skyBlue.withOpacity(0.12)],
              ),
            ),
            Positioned(
              bottom: -80,
              left: -50,
              child: _GlowBlob(
                size: 260,
                colors: [skyBlue.withOpacity(0.12), blue.withOpacity(0.1)],
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircleActionButton(
                          icon: Iconsax.arrow_left,
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/'),
                        ),
                        _LanguageSwitcher(
                          imagePath:
                              langageImages[localeCode] ??
                              'lib/assets/images/fr.png',
                          onPressed: () {
                            if (localeCode == 'fr') {
                              context.setLocale(const Locale('en'));
                            } else {
                              context.setLocale(const Locale('fr'));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [blue, skyBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: blue.withOpacity(0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'lib/assets/images/sah.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'SAHTECH',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'create_account'.tr(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: contentWidth,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: blue.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _FieldLabel(label: 'role_label'),
                          const SizedBox(height: 12),
                          Row(
                            children: ['PATIENT', 'DOCTOR'].map((role) {
                              final isSelected =
                                  signupController.selectedRole == role;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    signupController.setRole(role);
                                    if (role == 'DOCTOR' &&
                                        _availableClinics.isEmpty) {
                                      _loadClinics();
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(
                                      right: role == 'PATIENT' ? 12 : 0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? blue : surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: blue.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: blue.withOpacity(0.15),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Text(
                                      role,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          _FieldLabel(label: 'gender_label'),
                          const SizedBox(height: 12),
                          Row(
                            children: ['MALE', 'FEMALE', 'OTHER'].map((gender) {
                              final isSelected =
                                  signupController.selectedGender == gender;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      signupController.setGender(gender),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: EdgeInsets.only(
                                      right: gender != 'OTHER' ? 8 : 0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? blue : surface,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: blue.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      gender.tr(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          _FieldLabel(label: 'full_name_label'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: nomController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'fullname_required'.tr()
                                : null,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                            ),
                            decoration: _brandFieldDecoration(
                              hintText: 'fullname_hint'.tr(),
                              prefixIcon: Iconsax.user,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel(label: 'email_label'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'email_required'.tr();
                              if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              ).hasMatch(v)) {
                                return 'email_invalid'.tr();
                              }
                              return null;
                            },
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                            ),
                            decoration: _brandFieldDecoration(
                              hintText: 'email_hint'.tr(),
                              prefixIcon: Iconsax.sms,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel(label: 'phone_label'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: telephoneController,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'phone_required'.tr();
                              if (!RegExp(r'^[0-9]{8}$').hasMatch(v)) {
                                return 'phone_invalid'.tr();
                              }
                              return null;
                            },
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                            ),
                            decoration: _brandFieldDecoration(
                              hintText: 'phone_hint'.tr(),
                              prefixIcon: Iconsax.call,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel(label: 'address_label'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: addressController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'address_required'.tr()
                                : null,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                            ),
                            decoration: _brandFieldDecoration(
                              hintText: 'address_hint'.tr(),
                              prefixIcon: Iconsax.location,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FieldLabel(label: 'password_label'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'password_required'.tr();
                              if (v.length < 6) return 'password_length'.tr();
                              return null;
                            },
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                            ),
                            decoration: _brandFieldDecoration(
                              hintText: 'password_hint'.tr(),
                              prefixIcon: Iconsax.lock,
                              suffixIcon: IconButton(
                                splashRadius: 20,
                                icon: Icon(
                                  isPasswordVisible
                                      ? Iconsax.eye
                                      : Iconsax.eye_slash,
                                  color: blue,
                                  size: 20,
                                ),
                                onPressed: togglePasswordVisibility,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (signupController.selectedRole == 'PATIENT') ...[
                            _FieldLabel(label: 'age_label'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: ageController,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'age_required'.tr()
                                  : null,
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                              ),
                              decoration: _brandFieldDecoration(
                                hintText: '25',
                                prefixIcon: Iconsax.calendar,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _FieldLabel(label: 'weight_label'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: poidsController,
                                        keyboardType: TextInputType.number,
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'weight_required'.tr();
                                          if (double.tryParse(v) == null)
                                            return 'weight_invalid'.tr();
                                          return null;
                                        },
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontSize: 14,
                                        ),
                                        decoration: _brandFieldDecoration(
                                          hintText: '70',
                                          prefixIcon: Iconsax.activity,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _FieldLabel(label: 'height_label'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: tailleController,
                                        keyboardType: TextInputType.number,
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return 'height_required'.tr();
                                          if (double.tryParse(v) == null)
                                            return 'height_invalid'.tr();
                                          return null;
                                        },
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontSize: 14,
                                        ),
                                        decoration: _brandFieldDecoration(
                                          hintText: '175',
                                          prefixIcon: Iconsax.ruler,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (signupController.selectedRole == 'DOCTOR') ...[
                            _FieldLabel(label: 'speciality_label'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: specialityController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'speciality_required'.tr()
                                  : null,
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                              ),
                              decoration: _brandFieldDecoration(
                                hintText: 'Cardiology',
                                prefixIcon: Iconsax.health,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FieldLabel(label: 'bio_label'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: bioController,
                              maxLines: 3,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'bio_required'.tr()
                                  : null,
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                              ),
                              decoration: _brandFieldDecoration(
                                hintText: 'bio_hint'.tr(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FieldLabel(label: 'license_label'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: licenseController,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'license_required'.tr();
                                if (!RegExp(r'^\d{4,5}\/\d{2}$').hasMatch(v))
                                  return 'license_invalid'.tr();
                                return null;
                              },
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                              ),
                              decoration: _brandFieldDecoration(
                                hintText: '1234/95',
                                prefixIcon: Iconsax.award,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FieldLabel(label: 'link_clinics_label'),
                            const SizedBox(height: 8),
                            _ClinicMultiPicker(
                              clinics: _availableClinics,
                              selectedIds: _selectedClinicIds,
                              loading: _loadingClinics,
                              onRefresh: _loadClinics,
                              onChanged: (ids) => setState(() {
                                _selectedClinicIds
                                  ..clear()
                                  ..addAll(ids);
                                // deselect primary if it was removed
                                if (!_selectedClinicIds
                                    .contains(_primaryClinicId)) {
                                  _primaryClinicId = null;
                                }
                              }),
                            ),
                            if (_selectedClinicIds.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _FieldLabel(label: 'primary_clinic_label'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String?>(
                                value: _primaryClinicId,
                                decoration: _brandFieldDecoration(
                                  hintText: 'primary_clinic_hint'.tr(),
                                  prefixIcon: Iconsax.hospital,
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'no_primary_clinic'.tr(),
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  ..._availableClinics
                                      .where((c) =>
                                          _selectedClinicIds.contains(c.clinicId))
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c.clinicId,
                                          child: Text(
                                            c.name,
                                            style:
                                                const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _primaryClinicId = v),
                              ),
                            ],
                            const SizedBox(height: 16),
                            const SizedBox(height: 0),
                            _FieldLabel(label: 'coordinates_label'),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _openMapPicker,
                              icon: const Icon(
                                Iconsax.map_1,
                                size: 18,
                                color: blue,
                              ),
                              label: Text(
                                'pick_on_map'.tr(),
                                style: const TextStyle(
                                  color: blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: blue.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _FieldLabel(label: 'latitude_label'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: latitudeController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                              signed: true,
                                            ),
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontSize: 14,
                                        ),
                                        decoration: _brandFieldDecoration(
                                          hintText: '36.8065',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _FieldLabel(label: 'longitude_label'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: longitudeController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                              signed: true,
                                            ),
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontSize: 14,
                                        ),
                                        decoration: _brandFieldDecoration(
                                          hintText: '10.1815',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                          if (signupController.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Iconsax.warning_2,
                                    color: Color(0xFFEF4444),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      signupController.errorMessage!,
                                      style: const TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          SizedBox(
                            height: 56,
                            child: signupController.isLoading
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.6,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(blue),
                                      ),
                                    ),
                                  )
                                : DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [blue, skyBlue],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: blue.withOpacity(0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            signupController.signup(
                                              fullName: nomController.text
                                                  .trim(),
                                              email: emailController.text
                                                  .trim(),
                                              password: passwordController.text
                                                  .trim(),
                                              phone: telephoneController.text
                                                  .trim(),
                                              address: addressController.text
                                                  .trim(),
                                              context: context,
                                              age:
                                                  signupController
                                                          .selectedRole ==
                                                      'PATIENT'
                                                  ? ageController.text.trim()
                                                  : null,
                                              weight:
                                                  signupController
                                                          .selectedRole ==
                                                      'PATIENT'
                                                  ? double.tryParse(
                                                      poidsController.text,
                                                    )
                                                  : null,
                                              height:
                                                  signupController
                                                          .selectedRole ==
                                                      'PATIENT'
                                                  ? double.tryParse(
                                                      tailleController.text,
                                                    )
                                                  : null,
                                              speciality:
                                                  signupController
                                                          .selectedRole ==
                                                      'DOCTOR'
                                                  ? specialityController.text
                                                        .trim()
                                                  : null,
                                              bio:
                                                  signupController
                                                          .selectedRole ==
                                                      'DOCTOR'
                                                  ? bioController.text.trim()
                                                  : null,
                                              licenseNumber:
                                                  signupController
                                                          .selectedRole ==
                                                      'DOCTOR'
                                                  ? licenseController.text
                                                        .trim()
                                                  : null,
                                              clinicIds:
                                                  signupController
                                                          .selectedRole ==
                                                      'DOCTOR'
                                                  ? _selectedClinicIds.toList()
                                                  : null,
                                              primaryClinicId:
                                                  signupController
                                                          .selectedRole ==
                                                      'DOCTOR'
                                                  ? _primaryClinicId
                                                  : null,
                                              latitude:
                                                  signupController
                                                          .selectedRole ==
                                                      'DOCTOR'
                                                  ? double.tryParse(
                                                      latitudeController.text,
                                                    )
                                                  : null,
                                              longitude:
                                                  signupController
                                                          .selectedRole ==
                                                      'DOCTOR'
                                                  ? double.tryParse(
                                                      longitudeController.text,
                                                    )
                                                  : null,
                                            );
                                          }
                                        },
                                        child: const Center(
                                          child: Text(
                                            'Signup',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'already_account'.tr(),
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/connexion'),
                        child: Text(
                          ' ${"signin_link".tr()}',
                          style: const TextStyle(
                            color: blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.tr(),
      style: const TextStyle(
        color: Color(0xFF0A0F1E),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0052FF).withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF0A0F1E), size: 20),
        ),
      ),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher({required this.imagePath, required this.onPressed});

  final String imagePath;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, width: 28, height: 18, fit: BoxFit.cover),
              const SizedBox(width: 8),
              const Icon(Iconsax.global, color: Color(0xFF0052FF), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

// ─── Clinic Multi-Picker ─────────────────────────────────────────────────────

class _ClinicMultiPicker extends StatelessWidget {
  final List<ClinicModel> clinics;
  final Set<String> selectedIds;
  final bool loading;
  final VoidCallback onRefresh;
  final ValueChanged<Set<String>> onChanged;

  static const blue = Color(0xFF0052FF);

  const _ClinicMultiPicker({
    required this.clinics,
    required this.selectedIds,
    required this.loading,
    required this.onRefresh,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: blue),
          ),
        ),
      );
    }

    if (clinics.isEmpty) {
      return OutlinedButton.icon(
        onPressed: onRefresh,
        icon: const Icon(Icons.refresh, size: 16, color: blue),
        label: Text(
          'load_clinics'.tr(),
          style: const TextStyle(color: blue, fontSize: 13),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: blue, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    }

    return Column(
      children: clinics.map((clinic) {
        final selected = selectedIds.contains(clinic.clinicId);
        return CheckboxListTile(
          value: selected,
          activeColor: blue,
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(
            clinic.name,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            clinic.address,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          onChanged: (_) {
            final next = Set<String>.from(selectedIds);
            if (selected) {
              next.remove(clinic.clinicId);
            } else {
              next.add(clinic.clinicId);
            }
            onChanged(next);
          },
        );
      }).toList(),
    );
  }
}

// ─── Field decoration ─────────────────────────────────────────────────────────

InputDecoration _brandFieldDecoration({
  required String hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF94A3B8),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: const Color(0xFF0052FF), size: 20)
        : null,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0052FF), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
    ),
  );
}
