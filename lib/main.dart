import 'package:flutter/material.dart';
import 'package:sahtek/core/config/app_config.dart';
import 'package:sahtek/core/services/auth_init_service.dart';
import 'package:sahtek/core/services/chat_realtime_service.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:sahtek/features/auth/controllers/auth_controller.dart';
import 'package:sahtek/features/auth/controllers/google_auth_controller.dart';
import 'package:sahtek/features/auth/controllers/otp_controller.dart';
import 'package:sahtek/features/auth/screens/connexion.dart';
import 'package:sahtek/features/auth/screens/inscription.dart';
import 'package:sahtek/features/auth/screens/OtpVerificationPage.dart';
import 'package:sahtek/features/content_library/screens/localisation_douleur.dart';
import 'package:sahtek/features/home/screens/accueil.dart';
import 'package:sahtek/features/ia_tracking/screens/selection_test_ia.dart';
import 'package:sahtek/features/ia_tracking/screens/preparation_test_ia.dart';
import 'package:sahtek/features/content_library/screens/exercices_zone.dart';
import 'package:sahtek/features/ia_tracking/screens/resultat_test_ia.dart';
import 'package:sahtek/features/profile/controller/profile_controller.dart';
import 'package:sahtek/features/specialists/screens/trouver_specialiste.dart';
import 'package:sahtek/features/appointments/screens/reserver_rdv.dart';
import 'package:sahtek/features/appointments/screens/mes_rdv_page.dart';
import 'package:sahtek/features/appointments/screens/details_rdv_page.dart';
import 'package:sahtek/features/ia_tracking/screens/score_constant_page.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sahtek/features/messaging/screens/messagerie_page.dart';
import 'package:sahtek/features/dashboard/screens/dashboard_specialiste.dart';
import 'package:sahtek/features/profile/screens/profile_page.dart';
import 'package:sahtek/features/profile/screens/personal_info_page.dart';
import 'package:sahtek/features/profile/screens/medical_folder_page.dart';
import 'package:sahtek/features/content_library/screens/favorites_page.dart';
import 'package:sahtek/features/profile/screens/security_privacy_page.dart';
import 'package:sahtek/features/notifications/screens/notifications_page.dart';
import 'package:sahtek/features/ia_tracking/screens/suivi_ia_direct.dart';
import 'package:sahtek/features/appointments/screens/gestion_disponibilites_page.dart';
import 'package:sahtek/features/specialists/screens/specialiste_details.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/features/auth/controllers/signup_controller.dart';
import 'package:sahtek/features/specialists/screens/ListPatients.dart';
import 'package:sahtek/features/specialists/screens/publier_exercice.dart';
import 'package:sahtek/features/specialists/screens/specialist_medical_folder_page.dart';
import 'package:sahtek/features/specialists/screens/medical_category_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.initialize();
  await EasyLocalization.ensureInitialized();
  await ChatRealtimeService.instance.start();

  initializeDateFormatting('fr_FR', null).then((_) {
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('fr'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: const Locale('fr'),
        startLocale: const Locale('fr'),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) {
                final provider = GlobalDataProvider();
                provider.initializeAppointments();
                return provider;
              },
            ),
            ChangeNotifierProvider(create: (_) => AuthController()),
            ChangeNotifierProvider(create: (_) => OtpController()),
            ChangeNotifierProvider(create: (_) => SignupController()),
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider(create: (_) => GoogleAuthController()),
          ],
          child: const MyApp(),
        ),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAHTECH',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routes: {
        '/': (context) => const Ppage(),
        '/connexion': (context) => Connexion(),
        '/inscription': (context) => Inscription(),
        '/otp-verification': (context) => const OtpVerificationPage(),
        '/accueil': (context) => AccueilPage(),
        '/selection_test_ia': (context) => SelectionTestIAPage(),
        '/preparation_test_ia': (context) => PreparationTestIAPage(),
        '/localisation_douleur': (context) => LocalisationDouleurPage(),
        '/exercices_zone': (context) => ExercicesZonePage(),
        '/resultat_test_ia': (context) => ResultatsTestIAPage(),
        '/trouver_specialiste': (context) => TrouverSpecialistePage(),
        '/reserver_rdv': (context) => ReserverRDVPage(),
        '/mes_rdv': (context) => const MesRdvPage(),
        '/details_rdv': (context) => const DetailsRdvPage(),
        '/score_constant': (context) => const ScoreConstantPage(),
        '/messagerie': (context) => const MessageriePage(),
        '/dashboard_specialiste': (context) => const DashboardSpecialistePage(),
        '/profile': (context) => const ProfilePage(),
        '/personal_info': (context) => const PersonalInfoPage(),
        '/medical_folder': (context) => const MedicalFolderPage(),
        '/favorites': (context) => const FavoritesPage(),
        '/security_privacy': (context) => const SecurityPrivacyPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/suivi_ia_direct': (context) => const SuiviIADirectPage(),
        '/gestion_disponibilites': (context) =>
            const GestionDisponibilitesPage(),
        '/specialiste_details': (context) => const SpecialisteDetailsPage(),
        '/liste_patients': (context) => const ListePatientsPage(),
        '/publier_exercice': (context) => const PublierExercicePage(),
        '/specialist_medical_folder': (context) =>
            const SpecialistMedicalFolderPage(),
        '/medical_category_detail': (context) =>
            const MedicalCategoryDetailPage(),
      },
    );
  }
}

class Ppage extends StatefulWidget {
  const Ppage({super.key});

  @override
  State<Ppage> createState() => _PpageState();
}

class _PpageState extends State<Ppage> {
  bool _tInPlace = false;
  bool _sessionChecked = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _tInPlace = true);
        // check session after animation
        _checkSession();
      }
    });
  }

  Future<void> _checkSession() async {
    final accessToken = await StorageService.getAccessToken();

    if (accessToken != null) {
      // user has tokens → restore session silently
      if (!mounted) return;
      await AuthInitService.checkAndRestoreSession(context);
    } else {
      // no tokens → show login/signup buttons
      if (mounted) setState(() => _sessionChecked = true);
    }
  }

  static const _blue = Color.fromARGB(255, 13, 84, 242);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: _tInPlace
                    ? SizedBox(
                        key: const ValueKey('sahtech'),
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Image.asset(
                              'lib/assets/images/sah.png',
                              width: 550,
                              height: 550,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              left: 30,
                              bottom: 45,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: const Color.fromARGB(
                                  0,
                                  0,
                                  0,
                                  0,
                                ),

                                child: Image.asset(
                                  'lib/assets/images/trans.png',
                                  width: 400,
                                  height: 400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : CircleAvatar(
                        radius: 100,
                        backgroundColor: const Color.fromARGB(255, 13, 84, 242),

                        child: Center(
                          child: Image.asset('lib/assets/images/trans.png'),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              Text(
                'SAHTECH',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _blue,
                ),
              ),
              Text(
                'application_subtitle'.tr(),
                style: TextStyle(fontSize: 14, color: _blue),
              ),
              const SizedBox(height: 20),
              if (!_sessionChecked)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    buttonC(
                      'Login'.tr(),
                      () => Navigator.pushNamed(context, '/connexion'),
                      width: 320,
                    ),
                    const SizedBox(height: 20),
                    buttonIn(
                      'Signup'.tr(),
                      () => Navigator.pushNamed(context, '/inscription'),
                      width: 320,
                    ),
                    const SizedBox(height: 20),
                    // divider
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 130,
                          child: Divider(color: Colors.grey.shade400),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'or'.tr(),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                        SizedBox(
                          width: 130,
                          child: Divider(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Google button
                    Consumer<GoogleAuthController>(
                      builder: (context, googleController, _) {
                        return googleController.isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: 320,
                                height: 48,
                                child: OutlinedButton.icon(
                                  onPressed: () => googleController
                                      .signInWithGoogle(context: context),
                                  icon: Image.asset(
                                    'lib/assets/images/google_logo.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  label: Text(
                                    'signin_with_google'.tr(),
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
