import 'package:flutter/material.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:sahtek/core/theme/InputDecoration.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/features/auth/controllers/signup_controller.dart';

class Inscription extends StatefulWidget {
  const Inscription({super.key});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  final _formKey = GlobalKey<FormState>();
  static const blue = Color.fromARGB(255, 13, 84, 242);

  final Map<String, String> langageImages = {
    'fr': 'lib/assets/images/fr.png',
    'en': 'lib/assets/images/en.png',
  };

  // shared fields
  final TextEditingController nomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController confirmEmailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // patient fields
  final TextEditingController ageController = TextEditingController();
  final TextEditingController poidsController = TextEditingController(text: '70');
  final TextEditingController tailleController = TextEditingController(text: '175');

  // doctor fields
  final TextEditingController specialityController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController clinicController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  bool isPasswordVisible = false;

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
    clinicController.dispose();
    locationController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  @override
  Widget build(BuildContext context) {
    final signupController = Provider.of<SignupController>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = (screenWidth - 24).clamp(280.0, 360.0);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  visualDensity: VisualDensity.compact,
                ),
                trailing: GestureDetector(
                  onTap: () {
                    if (context.locale.languageCode == 'fr') {
                      context.setLocale(const Locale('en'));
                    } else {
                      context.setLocale(const Locale('fr'));
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        langageImages[context.locale.languageCode] ??
                            'lib/assets/images/fr.png',
                        width: 26,
                        height: 18,
                        fit: BoxFit.cover,
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: contentWidth,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'lib/assets/images/sah.png',
                        width: 96,
                        height: 96,
                      ),
                      Text(
                        'SAHTECH',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: blue,
                        ),
                      ),
                      Text(
                        'create_account'.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [

                            // ─── Role selector ──────────────────────────
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'role_label'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: ['PATIENT', 'DOCTOR'].map((role) {
                                final isSelected =
                                    signupController.selectedRole == role;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        signupController.setRole(role),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? blue
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(color: blue),
                                      ),
                                      child: Text(
                                        role,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),

                            // ─── Gender selector ────────────────────────
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'gender_label'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: ['MALE', 'FEMALE', 'OTHER']
                                  .map((gender) {
                                final isSelected =
                                    signupController.selectedGender == gender;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        signupController.setGender(gender),
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 4),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? blue
                                            : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(color: blue),
                                      ),
                                      child: Text(
                                        gender.tr(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),

                            // ─── Full name ──────────────────────────────
                            _buildLabel('full_name_label'.tr()),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: nomController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'fullname_required'.tr()
                                  : null,
                              decoration: Deco(null, null,
                                  const Icon(Icons.person_outline, color: blue),
                                  hintText: 'fullname_hint'.tr()),
                            ),
                            const SizedBox(height: 10),

                            // ─── Email ──────────────────────────────────
                            _buildLabel('email_label'.tr()),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'email_required'.tr();
                                if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                ).hasMatch(v))
                                  return 'email_invalid'.tr();
                                return null;
                              },
                              decoration: Deco(null, null,
                                  const Icon(Icons.email_outlined, color: blue),
                                  hintText: 'exemple@mail.com'),
                            ),
                            const SizedBox(height: 10),

                            // ─── Phone ──────────────────────────────────
                            _buildLabel('phone_label'.tr()),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: telephoneController,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'phone_required'.tr();
                                if (!RegExp(r'^[0-9]{8}$').hasMatch(v))
                                  return 'phone_invalid'.tr();
                                return null;
                              },
                              decoration: Deco(null, null,
                                  const Icon(Icons.phone_outlined, color: blue),
                                  hintText: 'phone_hint'.tr()),
                            ),
                            const SizedBox(height: 10),

                            // ─── Address ─────────────────────────────────
                            _buildLabel('address_label'.tr()),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: addressController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'address_required'.tr()
                                  : null,
                              decoration: Deco(null, null,
                                  const Icon(Icons.location_on_outlined,
                                      color: blue),
                                  hintText: 'address_hint'.tr()),
                            ),
                            const SizedBox(height: 10),

                            // ─── Password ────────────────────────────────
                            _buildLabel('password_label'.tr()),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'password_required'.tr();
                                if (v.length < 6)
                                  return 'password_length'.tr();
                                return null;
                              },
                              decoration: Deco(
                                null,
                                null,
                                IconButton(
                                  onPressed: togglePasswordVisibility,
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: blue,
                                  ),
                                ),
                                hintText: '********',
                              ),
                            ),
                            const SizedBox(height: 10),

                            // ─── PATIENT fields ──────────────────────────
                            if (signupController.selectedRole == 'PATIENT') ...[
                              _buildLabel('age_label'.tr()),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: ageController,
                                keyboardType: TextInputType.number,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'age_required'.tr()
                                    : null,
                                decoration: Deco(null, null,
                                    const Icon(Icons.cake_outlined, color: blue),
                                    hintText: '25'),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('weight_label'.tr()),
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
                                          decoration: Deco(null, null,
                                              const Icon(
                                                  Icons.fitness_center_outlined,
                                                  color: blue),
                                              hintText: '70'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('height_label'.tr()),
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
                                          decoration: Deco(null, null,
                                              const Icon(Icons.height,
                                                  color: blue),
                                              hintText: '175'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            // ─── DOCTOR fields ───────────────────────────
                            if (signupController.selectedRole == 'DOCTOR') ...[
                              _buildLabel('speciality_label'.tr()),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: specialityController,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'speciality_required'.tr()
                                    : null,
                                decoration: Deco(null, null,
                                    const Icon(Icons.medical_services_outlined,
                                        color: blue),
                                    hintText: 'Cardiology'),
                              ),
                              const SizedBox(height: 10),
                              _buildLabel('bio_label'.tr()),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: bioController,
                                maxLines: 3,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'bio_required'.tr()
                                    : null,
                                decoration: Deco(null, null, null,
                                    hintText: 'bio_hint'.tr()),
                              ),
                              const SizedBox(height: 10),
                              _buildLabel('license_label'.tr()),
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
                                decoration: Deco(null, null,
                                    const Icon(Icons.badge_outlined, color: blue),
                                    hintText: '1234/95'),
                              ),
                              const SizedBox(height: 10),
                              _buildLabel('clinic_label'.tr()),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: clinicController,
                                decoration: Deco(null, null,
                                    const Icon(Icons.local_hospital_outlined,
                                        color: blue),
                                    hintText: 'clinic_hint'.tr()),
                              ),
                              const SizedBox(height: 10),
                              _buildLabel('location_label'.tr()),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: locationController,
                                decoration: Deco(null, null,
                                    const Icon(Icons.location_on_outlined,
                                        color: blue),
                                    hintText: 'location_hint'.tr()),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('latitude_label'.tr()),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: latitudeController,
                                          keyboardType: TextInputType.number,
                                          decoration: Deco(null, null, null,
                                              hintText: '36.8065'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('longitude_label'.tr()),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: longitudeController,
                                          keyboardType: TextInputType.number,
                                          decoration: Deco(null, null, null,
                                              hintText: '10.1815'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // show error
                      if (signupController.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            signupController.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // signup button
                      signupController.isLoading
                          ? const CircularProgressIndicator()
                          : buttonIn('Signup'.tr(), () {
                              if (_formKey.currentState!.validate()) {
                                signupController.signup(
                                  fullName: nomController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  phone: telephoneController.text.trim(),
                                  address: addressController.text.trim(),
                                  context: context,
                                  // patient
                                  age: signupController.selectedRole == 'PATIENT'
                                      ? ageController.text.trim()
                                      : null,
                                  weight: signupController.selectedRole ==
                                          'PATIENT'
                                      ? double.tryParse(poidsController.text)
                                      : null,
                                  height: signupController.selectedRole ==
                                          'PATIENT'
                                      ? double.tryParse(tailleController.text)
                                      : null,
                                  // doctor
                                  speciality: signupController.selectedRole ==
                                          'DOCTOR'
                                      ? specialityController.text.trim()
                                      : null,
                                  bio: signupController.selectedRole == 'DOCTOR'
                                      ? bioController.text.trim()
                                      : null,
                                  licenseNumber:
                                      signupController.selectedRole == 'DOCTOR'
                                          ? licenseController.text.trim()
                                          : null,
                                  clinic:
                                      signupController.selectedRole == 'DOCTOR'
                                          ? clinicController.text.trim()
                                          : null,
                                  location:
                                      signupController.selectedRole == 'DOCTOR'
                                          ? locationController.text.trim()
                                          : null,
                                  latitude:
                                      signupController.selectedRole == 'DOCTOR'
                                          ? double.tryParse(
                                              latitudeController.text)
                                          : null,
                                  longitude:
                                      signupController.selectedRole == 'DOCTOR'
                                          ? double.tryParse(
                                              longitudeController.text)
                                          : null,
                                );
                              }
                            }),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'already_account'.tr(),
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/connexion'),
                            child: const Text(
                              ' Login',
                              style: TextStyle(
                                color: blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
          fontSize: 12,
        ),
      ),
    );
  }
}