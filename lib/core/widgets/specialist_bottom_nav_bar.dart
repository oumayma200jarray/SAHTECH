import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/appointment_notifier.dart';

/// Bottom navigation bar for the specialist role.
/// Shows 4 tabs: Dashboard, Patients, Profile, Availability.
/// The Availability tab shows a badge when new appointments arrive via socket.
class SpecialistBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const SpecialistBottomNavBar({Key? key, required this.currentIndex})
      : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    // Reset the appointment badge when navigating to the availability screen
    if (index == 3) {
      Provider.of<AppointmentNotifier>(context, listen: false).reset();
    }

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
      case 3:
        Navigator.pushReplacementNamed(context, '/gestion_disponibilites');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final newCount =
        context.watch<AppointmentNotifier>().newCount;

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
        BottomNavigationBarItem(
          icon: _BadgedIcon(
            icon: Icons.schedule_outlined,
            count: newCount,
          ),
          activeIcon: _BadgedIcon(
            icon: Icons.schedule,
            count: newCount,
          ),
          label: 'nav_availability'.tr(),
        ),
      ],
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  final IconData icon;
  final int count;

  const _BadgedIcon({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return Icon(icon);
    return Badge(
      label: Text(count > 99 ? '99+' : '$count'),
      backgroundColor: const Color(0xFFEF4444),
      child: Icon(icon),
    );
  }
}
