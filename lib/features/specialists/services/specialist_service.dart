import 'package:sahtek/models/specialist_model.dart';

class SpecialistService {
  static Future<List<SpecialistModel>> fetchSpecialists() async {
    // Simulation du délai réseau
    await Future.delayed(const Duration(milliseconds: 800));

    // Données fictives supprimées pour se préparer au Backend
    return [];
  }
}
