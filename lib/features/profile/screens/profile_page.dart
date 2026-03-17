import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<GlobalDataProvider>().profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Text(
                          profile.fullName.isNotEmpty
                              ? profile.fullName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.fullName.isNotEmpty
                        ? profile.fullName
                        : 'doctor_placeholder'.tr(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'patient'.tr(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Compte & Santé
            _buildSectionTitle('account_health'.tr()),
            _buildMenuItem(
              icon: Icons.person_outline,
              title: 'personal_information'.tr(),
              onTap: () => Navigator.pushNamed(context, '/personal_info'),
            ),
            _buildMenuItem(
              icon: Icons.folder_open_outlined,
              title: 'medical_folder'.tr(),
              onTap: () => Navigator.pushNamed(context, '/medical_folder'),
            ),
            _buildMenuItem(
              icon: Icons.favorite_border,
              title: 'my_favorites'.tr(),
              onTap: () => Navigator.pushNamed(context, '/favorites'),
            ),
            const SizedBox(height: 24),

            // Préférences
            _buildSectionTitle('preferences'.tr()),
            _buildMenuItem(
              icon: Icons.security_outlined,
              title: 'security_privacy'.tr(),
              onTap: () => Navigator.pushNamed(context, '/security_privacy'),
            ),
            _buildMenuItem(
              icon: Icons.notifications_none_outlined,
              title: 'notifications'.tr(),
              onTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
            const SizedBox(height: 40),

            // Déconnexion
            TextButton.icon(
              onPressed: () {
                // Logique de déconnexion
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: Text(
                'logout'.tr(),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'version'.tr(),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, bottom: 12),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[700]),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1C1E),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        onTap: onTap,
      ),
    );
  }
}
