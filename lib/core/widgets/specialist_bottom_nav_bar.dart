import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Bottom navigation bar for the specialist role.
/// Shows 3 tabs: Dashboard, Patients, Profil.
class SpecialistBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const SpecialistBottomNavBar({Key? key, required this.currentIndex})
      : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard_specialiste');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/liste_patients');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
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
          icon: const Icon(Icons.dashboard_outlined),
          activeIcon: const Icon(Icons.dashboard),
          label: 'nav_dashboard'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people_outline),
          activeIcon: const Icon(Icons.people),
          label: 'nav_patients'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: 'nav_profile'.tr(),
        ),
      ],
    );
  }
}
