import 'package:flutter/material.dart';

class NavigationUtils {
  /// Returns the appropriate dashboard route based on the user's role.
  static String getDashboardRoute(String? role) {
    if (role == null) return '/accueil';
    
    final upperRole = role.toUpperCase();
    if (upperRole == 'SPECIALIST' || 
        upperRole == 'SPECIALISTE' || 
        upperRole == 'DOCTOR') {
      return '/dashboard_specialiste';
    }
    
    return '/accueil';
  }

  /// Navigates to the appropriate dashboard based on the role.
  static void navigateToDashboard(BuildContext context, String? role) {
    final route = getDashboardRoute(role);
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }
}
