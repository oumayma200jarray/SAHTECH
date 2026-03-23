import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/models/specialist_model.dart';

class ProfileService {
  static Future<PatientModel> getPatientProfile() async {
    final response = await EndPoint.client.get(EndPoint.profile);
    return PatientModel.fromJson(response);
  }

  static Future<SpecialistModel> getSpecialistProfile() async {
    final response = await EndPoint.client.get(EndPoint.profile);
    return SpecialistModel.fromJson(response);
  }

  static Future<void> updatePatientProfile(PatientModel patient) async {
    await EndPoint.client.patch(EndPoint.updateUser, body: patient.toJson());
  }

  static Future<void> updateSpecialistProfile(
    SpecialistModel specialist,
  ) async {
    await EndPoint.client.patch(EndPoint.updateUser, body: specialist.toJson());
  }
}
