import 'package:flutter/material.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:sahtek/core/theme/InputDecoration.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';

class Inscription extends StatefulWidget {
  Inscription({super.key});

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

  final TextEditingController nomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();
  final TextEditingController poidsController = TextEditingController(
    text: '70',
  );
  final TextEditingController tailleController = TextEditingController(
    text: '175',
  );
  final TextEditingController antecedentsController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void dispose() {
    nomController.dispose();
    emailController.dispose();
    telephoneController.dispose();
    poidsController.dispose();
    tailleController.dispose();
    antecedentsController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = (screenWidth - 24).clamp(280.0, 320.0);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
                      const SizedBox(width: 2),
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
                        'SAHTECH'.tr(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: blue,
                        ),
                      ),
                      Text(
                        'health & Rehabilitation'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
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
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'full_name_label'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: nomController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'fullname_required'.tr()
                                  : null,
                              decoration: Deco(
                                null,
                                null,
                                const Icon(Icons.person_outline, color: blue),
                                hintText: 'fullname_hint'.tr(),
                              ),
                            ),
                            const SizedBox(height: 10),
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
                              decoration: Deco(
                                null,
                                null,
                                const Icon(Icons.email_outlined, color: blue),
                                hintText: 'exemple@mail.com',
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'phone_label'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: telephoneController,
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'phone_required'.tr()
                                  : null,
                              decoration: Deco(
                                null,
                                null,
                                const Icon(Icons.phone_outlined, color: blue),
                                hintText: 'phone_hint'.tr(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'weight_label'.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
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
                                        decoration: Deco(
                                          null,
                                          null,
                                          const Icon(
                                            Icons.fitness_center_outlined,
                                            color: blue,
                                          ),
                                          hintText: '70',
                                        ),
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
                                      Text(
                                        'height_label'.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade800,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
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
                                        decoration: Deco(
                                          null,
                                          null,
                                          const Icon(Icons.height, color: blue),
                                          hintText: '175',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'history_label'.tr(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: antecedentsController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'history_required'.tr()
                                  : null,
                              decoration: Deco(
                                null,
                                null,
                                const Icon(
                                  Icons.medical_services_outlined,
                                  color: blue,
                                ),
                                hintText: 'history_hint'.tr(),
                              ),
                            ),
                            const SizedBox(height: 10),
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
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'password_required'.tr();
                                if (v.length < 6) return 'password_length'.tr();
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      buttonIn('Signup'.tr(), () {
                        if (_formKey.currentState!.validate()) {
                          // Sauvegarder les données dans le Provider global
                          final globalData = context.read<GlobalDataProvider>();

                          // On sépare le nom complet en prénom/nom pour la méthode existante
                          List<String> parts = nomController.text.split(' ');
                          String prenom = parts.isNotEmpty ? parts[0] : '';
                          String nom = parts.length > 1
                              ? parts.sublist(1).join(' ')
                              : '';

                          globalData.setPatientInfo(
                            pPrenom: prenom,
                            pNom: nom,
                            pEmail: emailController.text,
                            pPhone: telephoneController.text,
                            pTaille: double.tryParse(tailleController.text),
                            pPoids: double.tryParse(poidsController.text),
                            pHistory: antecedentsController.text,
                          );

                          Navigator.pushNamed(context, '/connexion');
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
                            child: Text(
                              'signin_link'.tr(),
                              style: const TextStyle(
                                color: blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
