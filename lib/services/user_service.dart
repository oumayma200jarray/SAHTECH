import 'dart:convert';
import 'package:sahtek/models/patient_model.dart';

class UserService {
  // Simule une URL d'API
  static const String baseUrl = 'https://api.sahtech.com/v1/user';

  // Récupérer le profil du patient (Simulation)
  Future<PatientProfile> getProfile() async {
    try {
      // Simulation d'un délai réseau
      await Future.delayed(const Duration(seconds: 1));

      // Dans un cas réel :
      // final response = await http.get(Uri.parse('$baseUrl/profile'));
      // if (response.statusCode == 200) {
      //   return PatientProfile.fromJson(json.decode(response.body));
      // }

      // Retourne un profil vide par défaut ou mocké pour le moment
      return PatientProfile.empty();
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return PatientProfile.empty();
    }
  }

  // Mettre à jour le profil (Simulation)
  Future<bool> updateProfile(PatientProfile profile) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // Simulation d'un envoi au backend
      final body = json.encode(profile.toJson());
      print('Envoi des données au backend: $body');

      // final response = await http.put(
      //   Uri.parse('$baseUrl/profile'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: body,
      // );

      // return response.statusCode == 200;
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }
}
