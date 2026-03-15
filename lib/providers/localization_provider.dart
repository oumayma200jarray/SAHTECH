import 'package:flutter/material.dart';

class LocalizationProvider with ChangeNotifier {
  String _currentLanguage = 'fr'; // 'fr' ou 'en'

  String get currentLanguage => _currentLanguage;

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'fr' ? 'en' : 'fr';
    notifyListeners();
  }

  // Dictionnaire de traductions
  final Map<String, Map<String, String>> _localizedStrings = {
    'fr': {
      // Connexion page
      'login_title': 'Connexion',
      'login_subtitle': 'tu as deja un compte ? ',
      'signup_link': 'inscription',
      'email_label': 'EMAIL',
      'password_label': 'MOT DE PASSE',
      'email_hint': 'email',
      'password_hint': 'Mot De Passe',
      'forgot_password': 'Mot de passe oublié ?',
      'login_button': 'Se connecter',
      'email_required': 'Email requis',
      'email_invalid': 'Email invalide',
      'password_required': 'Mot de passe requis',
      'password_length': 'Au moins 6 caractères',
      'password_complex': 'Doit contenir minuscule, majuscule et chiffre',

      // Inscription page
      'signup_main_title': 'SAHTECH',
      'signup_sub_title': 'Sante & Reeducation',
      'create_account': 'Creer un compte',
      'fullname_label': 'NOM COMPLET',
      'fullname_hint': 'Entrez votre nom complet',
      'phone_label': 'NUMERO DE TELEPHONE',
      'phone_hint': '+33 6 00 00 00 00',
      'weight_label': 'POIDS (KG)',
      'height_label': 'TAILLE (CM)',
      'history_label': 'ANTECEDENTS MEDICAUX',
      'history_hint': 'Asthme, allergies, etc.',
      'signup_button': 'Inscription',
      'already_account': 'Deja un compte ? ',
      'signin_link': 'Se connecter',
    },
    'en': {
      // Connexion page
      'login_title': 'Login',
      'login_subtitle': 'Don\'t have an account? ',
      'signup_link': 'Sign up',
      'email_label': 'EMAIL',
      'password_label': 'PASSWORD',
      'email_hint': 'email',
      'password_hint': 'Password',
      'forgot_password': 'Forgot password?',
      'login_button': 'Sign in',
      'email_required': 'Email is required',
      'email_invalid': 'Invalid email format',
      'password_required': 'Password is required',
      'password_length': 'At least 6 characters',
      'password_complex': 'Must contain lowercase, uppercase and a number',

      // Inscription page
      'signup_main_title': 'SAHTECH',
      'signup_sub_title': 'Health & Rehabilitation',
      'create_account': 'Create Account',
      'fullname_label': 'FULL NAME',
      'fullname_hint': 'Enter your full name',
      'phone_label': 'PHONE NUMBER',
      'phone_hint': '+1 555 000 0000',
      'weight_label': 'WEIGHT (KG)',
      'height_label': 'HEIGHT (CM)',
      'history_label': 'MEDICAL HISTORY',
      'history_hint': 'Asthma, allergies, etc.',
      'signup_button': 'Register',
      'already_account': 'Already have an account? ',
      'signin_link': 'Sign in',
    },
  };

  String translate(String key) {
    return _localizedStrings[_currentLanguage]?[key] ?? key;
  }
}
