import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/features/profile/controller/profile_controller.dart';
import 'package:easy_localization/easy_localization.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blue,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'personal_information'.tr(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Avatar
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue.withOpacity(0.1),
                              backgroundImage: controller.imageUrl.isNotEmpty
                                  ? NetworkImage(
                                      UrlHelper.fixImageUrl(
                                        controller.imageUrl,
                                      ),
                                    )
                                  : null,
                              child: controller.imageUrl.isEmpty
                                  ? Text(
                                      controller.displayName.isNotEmpty
                                          ? controller.displayName[0]
                                                .toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Common fields
                        _buildField(
                          'full_name_label'.tr(),
                          controller.fullNameController,
                        ),
                        _buildField(
                          'email_label'.tr(),
                          controller.emailController,
                        ),
                        _buildField(
                          'phone_label'.tr(),
                          controller.phoneController,
                        ),
                        _buildField(
                          'address_label'.tr(),
                          controller.addressController,
                        ),

                        // Patient-only fields
                        if (controller.role == 'PATIENT') ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  'age'.tr(),
                                  controller.ageController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildField(
                                  'weight_kg'.tr(),
                                  controller.weightController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildField(
                                  'height_cm'.tr(),
                                  controller.heightController,
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Specialist-only fields
                        if (controller.role != 'PATIENT') ...[
                          _buildField(
                            'specialty'.tr(),
                            controller.specialtyController,
                          ),
                          _buildField('bio'.tr(), controller.bioController),
                          _buildField(
                            'license_number'.tr(),
                            controller.licenseNumberController,
                            readOnly: true,
                          ),
                          _buildField(
                            'clinic'.tr(),
                            controller.clinicController,
                          ),
                          _buildField(
                            'location'.tr(),
                            controller.locationController,
                          ),
                        ],

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: controller.isSaving
                                ? null
                                : () => controller.saveProfile(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
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
                        const SizedBox(height: 40),
                        _buildAccountManagement(),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'account_management'.tr(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _buildAccountButton(
          'deactivate_account'.tr(),
          Icons.block_outlined,
          Colors.grey[700]!,
          const Color(0xFFF5F5F5),
        ),
        const SizedBox(height: 12),
        _buildAccountButton(
          'delete_account'.tr(),
          Icons.delete_outline,
          Colors.redAccent,
          const Color(0xFFFFEBEE),
        ),
      ],
    );
  }

  Widget _buildAccountButton(
    String title,
    IconData icon,
    Color textColor,
    Color bgColor,
  ) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
