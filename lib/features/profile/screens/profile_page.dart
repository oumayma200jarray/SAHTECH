import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:iconsax/iconsax.dart';

const Color _primaryBlue = Color(0xFF0052FF);
const Color _gradientEnd = Color(0xFF00A3FF);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _role;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final role = await StorageService.getRole();
    final imageUrl = await StorageService.getImageUrl();
    setState(() {
      _role = role;
      _imageUrl = imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<GlobalDataProvider>().profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Iconsax.arrow_left_2,
            color: Color(0xFF0052FF),
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Si on ne peut pas pop (ex: remplacement de route), on retourne à l'accueil selon le rôle
              final isSpecialist =
                  _role?.toUpperCase() == 'SPECIALIST' ||
                  _role?.toUpperCase() == 'SPECIALISTE' ||
                  _role?.toUpperCase() == 'DOCTOR';
              Navigator.pushReplacementNamed(
                context,
                isSpecialist ? '/dashboard_specialiste' : '/accueil',
              );
            }
          },
        ),
        title: Text(
          'profile'.tr(),
          style: const TextStyle(
            color: Color(0xFF0A0F1E),
            fontSize: 24,
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
                  // Avatar with gradient background when no image
                  Stack(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _imageUrl == null || _imageUrl!.isEmpty
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF0052FF),
                                    Color(0xFF00A3FF),
                                  ],
                                )
                              : null,
                        ),
                        child: ClipOval(
                          child: _imageUrl != null && _imageUrl!.isNotEmpty
                              ? Image.network(
                                  UrlHelper.fixImageUrl(_imageUrl!),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                              : Center(
                                  child: Text(
                                    profile.fullName.isNotEmpty
                                        ? profile.fullName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _primaryBlue,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _primaryBlue.withOpacity(0.24),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.camera,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _role != null && _role!.isNotEmpty
                          ? _role!.toLowerCase().tr()
                          : 'patient'.tr(),
                      style: const TextStyle(
                        color: Color(0xFF0052FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
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
            const SizedBox(height: 24),

            // Avis & Langue
            _buildSectionTitle('Votre avis'),
            _buildMenuItem(
              icon: Icons.rate_review_outlined,
              title: 'Mes avis',
              onTap: () => Navigator.pushNamed(context, '/my_reviews'),
            ),
            _buildLanguageItem(context),
            const SizedBox(height: 40),

            // Déconnexion
            TextButton.icon(
              onPressed: () async {
                await StorageService.clearSession();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
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
            const Text(
              '1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 10),
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
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context) {
    final current = context.locale.languageCode == 'fr' ? 'Français' : 'English';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Icon(Icons.language_rounded, color: _primaryBlue, size: 20),
        title: const Text(
          'Langue',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0A0F1E)),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(current, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(width: 6),
            const Icon(Iconsax.arrow_right, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
        onTap: () => _showLanguagePicker(context),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final locales = [
      {'code': 'fr', 'label': 'Français', 'flag': '🇫🇷'},
      {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choisir la langue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0F1E),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...locales.map((l) {
              final isSelected = context.locale.languageCode == l['code'];
              return GestureDetector(
                onTap: () {
                  context.setLocale(Locale(l['code']!));
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _primaryBlue.withValues(alpha: 0.07)
                        : const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? _primaryBlue : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(l['flag']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Text(
                        l['label']!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? _primaryBlue : const Color(0xFF0A0F1E),
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: _primaryBlue, size: 20),
                    ],
                  ),
                ),
              );
            }),
          ],
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052FF).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(icon, color: _primaryBlue, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A0F1E),
          ),
        ),
        trailing: const Icon(
          Iconsax.arrow_right,
          color: Color(0xFF94A3B8),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
