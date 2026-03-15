import 'package:flutter/material.dart';
import 'package:sahtek/widgets/buttons.dart';
import 'package:sahtek/connexion.dart';
import 'package:sahtek/inscription.dart';
import 'package:sahtek/OtpVerificationPage.dart';
import 'package:sahtek/accueil.dart';
import 'package:sahtek/selection_test_ia.dart';
import 'package:sahtek/preparation_test_ia.dart';
import 'package:sahtek/localisation_douleur.dart';
import 'package:sahtek/exercices_zone.dart';
import 'package:sahtek/resultat_test_ia.dart';
import 'package:sahtek/trouver_specialiste.dart';
import 'package:sahtek/reserver_rdv.dart';
import 'package:sahtek/mes_rdv_page.dart';
import 'package:sahtek/details_rdv_page.dart';
import 'package:sahtek/score_constant_page.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sahtek/messagerie_page.dart';
import 'package:sahtek/dashboard_specialiste.dart';
import 'package:sahtek/profile_page.dart';
import 'package:sahtek/personal_info_page.dart';
import 'package:sahtek/medical_folder_page.dart';
import 'package:sahtek/favorites_page.dart';
import 'package:sahtek/security_privacy_page.dart';
import 'package:sahtek/notifications_page.dart';
import 'package:sahtek/suivi_ia_direct.dart';
import 'package:sahtek/gestion_disponibilites_page.dart';
import 'package:sahtek/specialiste_details.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

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
      home: const Ppage(),
      routes: {
        '/connexion': (context) => Connexion(),
        '/inscription': (context) => Inscription(),
        '/OtpVerificationPage': (context) => OtpVerificationPage(),
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
        '/gestion_disponibilites': (context) => const GestionDisponibilitesPage(),
        '/specialiste_details': (context) => const SpecialisteDetailsPage(),
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

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _tInPlace = true);
    });
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
            ],
          ),
        ),
      ),
    );
  }
}
