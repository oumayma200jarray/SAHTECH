// Redesigned following SAHTECH brand guidelines
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/features/auth/controllers/auth_controller.dart';

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final _formKey = GlobalKey<FormState>();

  static const blue = Color(0xFF0052FF);
  static const skyBlue = Color(0xFF00A3FF);
  static const pageBackground = Color(0xFFF8FAFF);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF0A0F1E);
  static const textSecondary = Color(0xFF64748B);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  final Map<String, String> langageImages = {
    'fr': 'lib/assets/images/fr.png',
    'en': 'lib/assets/images/en.png',
  };

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final localeCode = context.locale.languageCode;
    final currentLanguageImage =
        langageImages[localeCode] ?? 'lib/assets/images/fr.png';
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Stack(
                  children: [
                    Positioned(
                      top: -70,
                      right: -40,
                      child: _GlowBlob(
                        size: 220,
                        colors: [
                          blue.withOpacity(0.22),
                          skyBlue.withOpacity(0.12),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -80,
                      left: -50,
                      child: _GlowBlob(
                        size: 260,
                        colors: [
                          skyBlue.withOpacity(0.12),
                          blue.withOpacity(0.1),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _CircleActionButton(
                                icon: CupertinoIcons.chevron_left,
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  '/',
                                ),
                              ),
                              _LanguageSwitcher(
                                imagePath: currentLanguageImage,
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
                          const SizedBox(height: 24),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [blue, skyBlue],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: blue.withOpacity(0.18),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Image.asset(
                                        'lib/assets/images/sah.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'SAHTECK',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'no_account'.tr(),
                                      style: const TextStyle(
                                        color: textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        '/inscription',
                                      ),
                                      child: Text(
                                        'signup'.tr(),
                                        style: const TextStyle(
                                          color: blue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const _FieldLabel(label: 'email_label'),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        validator: (email) {
                                          final v = email?.trim() ?? '';
                                          if (v.isEmpty) {
                                            return 'email_required'.tr();
                                          }
                                          if (!RegExp(
                                            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                          ).hasMatch(v)) {
                                            return 'email_invalid'.tr();
                                          }
                                          return null;
                                        },
                                        controller: emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontSize: 14,
                                        ),
                                        decoration: _fieldDecoration(
                                          hintText: 'email_hint'.tr(),
                                          prefixIcon: CupertinoIcons.mail,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const _FieldLabel(
                                        label: 'password_label',
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        validator: (password) {
                                          final v = password?.trim() ?? '';
                                          if (v.isEmpty) {
                                            return 'password_required'.tr();
                                          }
                                          if (v.length < 6) {
                                            return 'password_length'.tr();
                                          }
                                          return null;
                                        },
                                        controller: passwordController,
                                        obscureText: !isPasswordVisible,
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontSize: 14,
                                        ),
                                        decoration: _fieldDecoration(
                                          hintText: 'password_hint'.tr(),
                                          prefixIcon: CupertinoIcons.lock,
                                          suffixIcon: IconButton(
                                            splashRadius: 20,
                                            icon: Icon(
                                              isPasswordVisible
                                                  ? CupertinoIcons.eye
                                                  : CupertinoIcons.eye_slash,
                                              color: blue,
                                              size: 20,
                                            ),
                                            onPressed: togglePasswordVisibility,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => Navigator.pushNamed(
                                      context,
                                      '/forgot-password',
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: blue,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 10,
                                      ),
                                    ),
                                    child: Text(
                                      'forgot_password'.tr(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                if (authController.errorMessage != null) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          CupertinoIcons
                                              .exclamationmark_triangle_fill,
                                          color: Color(0xFFEF4444),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            authController.errorMessage!,
                                            style: const TextStyle(
                                              color: Color(0xFFEF4444),
                                              fontSize: 13,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ] else
                                  const SizedBox(height: 16),
                                SizedBox(
                                  height: 56,
                                  child: authController.isLoading
                                      ? const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.6,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    blue,
                                                  ),
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
                                            borderRadius: BorderRadius.circular(
                                              28,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: blue.withOpacity(0.25),
                                                blurRadius: 18,
                                                offset: const Offset(0, 10),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(28),
                                              onTap: () {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  authController.signIn(
                                                    email: emailController.text
                                                        .trim(),
                                                    password: passwordController
                                                        .text
                                                        .trim(),
                                                    context: context,
                                                  );
                                                }
                                              },
                                              child: const Center(
                                                child: Text(
                                                  'Login',
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
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
              const Icon(
                CupertinoIcons.globe,
                color: Color(0xFF0052FF),
                size: 18,
              ),
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

InputDecoration _fieldDecoration({
  required String hintText,
  required IconData prefixIcon,
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
    prefixIcon: Icon(prefixIcon, color: Color(0xFF0052FF), size: 20),
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
