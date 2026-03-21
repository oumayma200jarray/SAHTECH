import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class PersonalInfoPage extends StatefulWidget {
  const PersonalInfoPage({super.key});

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late TextEditingController nomController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController poidsController;
  late TextEditingController tailleController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<GlobalDataProvider>().profile;
    nomController = TextEditingController(text: profile.fullName);
    emailController = TextEditingController(text: profile.email);
    phoneController = TextEditingController(text: profile.phone);
    poidsController = TextEditingController(text: profile.weight.toString());
    tailleController = TextEditingController(text: profile.height.toString());
  }

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    phoneController.dispose();
    poidsController.dispose();
    tailleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    context.watch<GlobalDataProvider>().profile.imageUrl,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('photo_selector_simulation'.tr()),
                        ),
                      );
                    },
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
            _buildField('full_name_label'.tr(), nomController),
            _buildField('email_label'.tr(), emailController),
            _buildField('phone_label'.tr(), phoneController),
            Row(
              children: [
                Expanded(child: _buildField('weight_kg'.tr(), poidsController)),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField('height_cm'.tr(), tailleController),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final newProfile = context
                      .read<GlobalDataProvider>()
                      .profile
                      .copyWith(
                        fullName: nomController.text,
                        email: emailController.text,
                        phone: phoneController.text,
                        weight: double.tryParse(poidsController.text) ?? 0.0,
                        height: double.tryParse(tailleController.text) ?? 0.0,
                      );
                  // context.read<GlobalDataProvider>().updateProfile(newProfile);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('changes_saved'.tr())));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
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
  }

  Widget _buildField(String label, TextEditingController controller) {
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
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${"action".tr()} $title')));
        },
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
