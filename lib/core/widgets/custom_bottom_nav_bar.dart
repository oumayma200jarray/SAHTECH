import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({Key? key, required this.currentIndex})
    : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Depending on your navigation setup, replace these routes with actual page navigations.
    // Replace pushReplacementNamed with standard pushNamed or GoRouter equivalent as your architecture requires.
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          '/accueil',
        ); // Route pour l'accueil
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/trouver_specialiste');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/mes_rdv');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/messagerie');
        break;
      case 4:
        Navigator.pushReplacementNamed(
          context,
          '/selection_test_ia',
        ); // Route pour tests IA
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color.fromARGB(255, 13, 84, 242),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: 'nav_home'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_search_outlined),
          activeIcon: const Icon(Icons.person_search),
          label: 'nav_specialists'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_today_outlined),
          activeIcon: const Icon(Icons.calendar_today),
          label: 'nav_appointments'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline),
          activeIcon: const Icon(Icons.chat_bubble),
          label: 'nav_messages'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.psychology_outlined),
          activeIcon: const Icon(Icons.psychology),
          label: 'nav_ia_tests'.tr(),
        ),
      ],
    );
  }
}
