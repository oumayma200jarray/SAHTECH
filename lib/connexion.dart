import 'package:flutter/material.dart';
import 'package:sahtek/widgets/buttons.dart';
import 'package:sahtek/InputDecoration.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

//import 'package:pin_code_fields/pin_code_fields.dart';
//import 'package:sahtech/GlobalController.dart';
class Connexion extends StatefulWidget {
  Connexion({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final _formKey = GlobalKey<FormState>(); // ✅ Déclaration correcte
  static const blue = Color.fromARGB(255, 13, 84, 242);

  Map<String, String> langageImages = {
    'fr': 'lib/assets/images/fr.png',
    'en': 'lib/assets/images/en.png',
  };
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false; //controler mot de passe
  bool isConfirmPasswordVisible = false;

  bool isEmailError = false;
  bool isPasswordError = false;
  bool isConfirmPasswordError = false;

  // methode pour la visibilité de mot de passe
  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/inscription');
                  },
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                ),
                trailing: IconButton(
                  onPressed: () {
                    if (context.locale.languageCode == 'fr') {
                      context.setLocale(const Locale('en'));
                    } else {
                      context.setLocale(const Locale('fr'));
                    }
                  },
                  icon: Image.asset(
                    langageImages[context.locale.languageCode] ??
                        'lib/assets/images/fr.png',
                    width: 30,
                    height: 20,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/sah.png',
                        width: 250,
                        height: 250,
                      ),
                      Text(
                        'Login'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('login_subtitle'.tr()),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/inscription'),
                            child: Text(
                              'signup'.tr(),
                              style: const TextStyle(
                                color: blue,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'email_label'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              validator: (email) {
                                final v = email?.trim() ?? '';
                                if (v.isEmpty) return 'email_required'.tr();
                                if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                ).hasMatch(v))
                                  return 'email_invalid'.tr();
                                return null;
                              },
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: Deco(
                                null,
                                null,
                                const Icon(Icons.mail_outline, color: blue),
                                hintText: 'email_hint'.tr(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'password_label'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              validator: (password) {
                                final v = password?.trim() ?? '';
                                if (v.isEmpty) return 'password_required'.tr();
                                if (v.length < 6) return 'password_length'.tr();
                                if (!RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                                ).hasMatch(v)) {
                                  return 'password_complex'.tr();
                                }
                                return null;
                              },
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !isPasswordVisible,
                              decoration: Deco(
                                null,
                                null,
                                IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: blue,
                                  ),
                                  onPressed: togglePasswordVisibility,
                                ),
                                hintText: 'password_hint'.tr(),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/OtpVerificationPage',
                            );
                          },
                          child: Text(
                            'forgot_password'.tr(),
                            style: const TextStyle(
                              color: Color.fromARGB(255, 31, 84, 242),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      buttonC('login'.tr(), () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pushNamed(context, '/accueil');
                        }
                      }),
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
}
