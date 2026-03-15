import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SecurityPrivacyPage extends StatefulWidget {
  const SecurityPrivacyPage({super.key});

  @override
  State<SecurityPrivacyPage> createState() => _SecurityPrivacyPageState();
}

class _SecurityPrivacyPageState extends State<SecurityPrivacyPage> {
  bool biometricAuth = true;
  bool doubleAuth = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'security_privacy'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('login_and_access'.tr()),
            _buildSwitchTile(
              Icons.fingerprint,
              'biometric_auth'.tr(),
              biometricAuth,
              (val) => setState(() => biometricAuth = val),
            ),
            _buildSwitchTile(
              Icons.security,
              'two_factor_auth'.tr(),
              doubleAuth,
              (val) => setState(() => doubleAuth = val),
            ),
            _buildActionTile(Icons.key_outlined, 'change_password_action'.tr()),
            const SizedBox(height: 32),
            _buildSectionTitle('data_management'.tr()),
            _buildActionTile(Icons.storage_outlined, 'manage_data_access'.tr()),
            _buildActionTile(Icons.download_outlined, 'download_my_data'.tr()),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Colors.blue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'account_protected'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'last_security_check'.tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'version_security'.tr().toUpperCase(),
                style: TextStyle(color: Colors.grey[400], fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        onTap: () {},
      ),
    );
  }
}
