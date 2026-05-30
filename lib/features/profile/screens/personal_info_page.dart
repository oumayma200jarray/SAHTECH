// Redesigned following SAHTECK brand guidelines
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/features/profile/controller/profile_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';

const Color _primaryBlue = Color(0xFF0052FF);
const Color _gradientEnd = Color(0xFF00A3FF);
const Color _backgroundColor = Color(0xFFF8FAFF);
const Color _surfaceColor = Colors.white;
const Color _textPrimary = Color(0xFF0A0F1E);
const Color _textSecondary = Color(0xFF64748B);

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileController>(context, listen: false).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ProfileController>(context);
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: _primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'personal_information'.tr(),
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                children: [
                  _SectionCard(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              controller.pickAndUploadImage(context: context),
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 104,
                                height: 104,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [_primaryBlue, _gradientEnd],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: ClipOval(
                                    child:
                                        (controller.imageUrl != null &&
                                            controller.imageUrl!.isNotEmpty)
                                        ? Image.network(
                                            UrlHelper.fixImageUrl(
                                              controller.imageUrl,
                                            ),
                                            fit: BoxFit.cover,
                                            width: 98,
                                            height: 98,
                                          )
                                        : Container(
                                            color: _primaryBlue.withOpacity(
                                              0.12,
                                            ),
                                            child: Center(
                                              child: controller.isUploadingImage
                                                  ? const SizedBox(
                                                      width: 28,
                                                      height: 28,
                                                      child:
                                                          CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            color: Colors.white,
                                                          ),
                                                    )
                                                  : Text(
                                                      controller
                                                              .displayName
                                                              .isNotEmpty
                                                          ? controller
                                                                .displayName[0]
                                                                .toUpperCase()
                                                          : 'U',
                                                      style: const TextStyle(
                                                        fontSize: 40,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 2,
                                bottom: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _primaryBlue,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _primaryBlue.withOpacity(0.18),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Iconsax.camera,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'profile_photo'.tr(),
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'tap_to_change_photo'.tr(),
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _SectionCard(
                    child: Column(
                      children: [
                        _buildField(
                          'full_name_label'.tr(),
                          controller.fullNameController,
                          icon: Iconsax.user,
                        ),
                        _buildField(
                          'email_label'.tr(),
                          controller.emailController,
                          icon: Iconsax.sms,
                        ),
                        _buildField(
                          'phone_label'.tr(),
                          controller.phoneController,
                          icon: Iconsax.call,
                        ),
                        _buildField(
                          'address_label'.tr(),
                          controller.addressController,
                          icon: Iconsax.location,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  if (controller.role == 'PATIENT') ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildCompactField(
                              'age'.tr(),
                              controller.ageController,
                              icon: Iconsax.activity,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactField(
                              'weight_kg'.tr(),
                              controller.weightController,
                              icon: Iconsax.weight,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCompactField(
                              'height_cm'.tr(),
                              controller.heightController,
                              icon: Iconsax.ruler,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (controller.role == 'DOCTOR') ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      child: Column(
                        children: [
                          _buildField(
                            'specialty'.tr(),
                            controller.specialtyController,
                            icon: Iconsax.health,
                          ),
                          _buildField(
                            'bio'.tr(),
                            controller.bioController,
                            icon: Iconsax.note_1,
                          ),
                          _buildField(
                            'license_number'.tr(),
                            controller.licenseNumberController,
                            icon: Iconsax.shield_tick,
                            readOnly: true,
                          ),
                          _buildField(
                            'location'.tr(),
                            controller.locationController,
                            icon: Iconsax.location,
                            isLast: true,
                          ),
                          const SizedBox(height: 8),
                          _buildReadOnlyInfo(
                            label: 'primary_clinic_label'.tr(),
                            value:
                                controller.specialist?.primaryClinic?.name ??
                                'no_primary_clinic'.tr(),
                            icon: Iconsax.building,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_primaryBlue, _gradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryBlue.withOpacity(0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: controller.isSaving
                            ? null
                            : () => controller.saveProfile(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: controller.isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'save_changes'.tr(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildAccountManagement(),
                ],
              ),
            ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController fieldController, {
    bool readOnly = false,
    required IconData icon,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: fieldController,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 14, color: _textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
                borderSide: const BorderSide(color: _primaryBlue, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactField(
    String label,
    TextEditingController fieldController, {
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: fieldController,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
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
              borderSide: const BorderSide(color: _primaryBlue, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyInfo({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: _primaryBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: _textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagement() {
    final controller = Provider.of<ProfileController>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'account_management'.tr(),
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        _buildAccountButton(
          'deactivate_account'.tr(),
          Iconsax.pause_circle,
          _textSecondary,
          const Color(0xFFF1F5F9),
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildAccountButton(
          'delete_account'.tr(),
          Iconsax.trash,
          const Color(0xFFEF4444),
          const Color(0xFFFEF2F2),
          onTap: () => controller.deleteAccount(context: context),
        ),
      ],
    );
  }

  Widget _buildAccountButton(
    String title,
    IconData icon,
    Color textColor,
    Color bgColor, {
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Icon(
                Iconsax.arrow_right_3,
                color: textColor.withOpacity(0.35),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
