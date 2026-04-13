import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:sahtek/models/ia_tracking_model.dart';

/// Service responsable de la communication avec le backend pour la génération de rapports.
class ReportService {
  // TODO: Remplacer par l'URL réelle de votre serveur NestJS
  static const String _baseUrl = 'http://YOUR_BACKEND_IP:3000/reports';

  /// Envoie les données de tracking au backend, télécharge le PDF et l'ouvre.
  Future<void> generateAndOpenReport(IATrackingData data) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        await _saveAndOpenPDF(
          response.bodyBytes,
          'Rapport_SAHTECH_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
      } else {
        throw Exception(
          'Erreur serveur (${response.statusCode}) : ${response.body}',
        );
      }
    } catch (e) {
      print('Erreur lors de la génération du rapport : $e');
      rethrow;
    }
  }

  /// Sauvegarde le flux binaire dans un fichier temporaire et l'ouvre avec l'application par défaut.
  Future<void> _saveAndOpenPDF(Uint8List bytes, String fileName) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);

    // Ouvre le fichier avec l'application PDF par défaut du téléphone
    await OpenFilex.open(file.path);
  }
}
