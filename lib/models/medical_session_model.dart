/// Medical Session and related models for Doctor/Specialist endpoints
/// Based on DOCTOR_API_DOCUMENTATION.md

class MedicalSessionModel {
  final int sessionId;
  final DateTime sessionDate;
  final String? notes;
  final ExamenCliniqueModel? examenClinique;
  final DiagnosticModel? diagnostic;
  final PhysiotherapieModel? physiotherapie;
  final ConducteATenirModel? conduiteATenir;
  final List<ComplementaryExamModel> examenComplementaire;

  MedicalSessionModel({
    required this.sessionId,
    required this.sessionDate,
    this.notes,
    this.examenClinique,
    this.diagnostic,
    this.physiotherapie,
    this.conduiteATenir,
    this.examenComplementaire = const [],
  });

  factory MedicalSessionModel.fromJson(Map<String, dynamic> json) {
    var examList = json['examenComplementaire'] as List? ?? [];
    List<ComplementaryExamModel> exams =
        examList.map((i) => ComplementaryExamModel.fromJson(i)).toList();

    return MedicalSessionModel(
      sessionId: json['sessionId'] ?? json['id'] ?? 0,
      sessionDate: json['sessionDate'] != null
          ? DateTime.parse(json['sessionDate'])
          : DateTime.now(),
      notes: json['notes'],
      examenClinique: json['examenClinique'] != null
          ? ExamenCliniqueModel.fromJson(json['examenClinique'])
          : null,
      diagnostic: json['diagnostic'] != null
          ? DiagnosticModel.fromJson(json['diagnostic'])
          : null,
      physiotherapie: json['physiotherapie'] != null
          ? PhysiotherapieModel.fromJson(json['physiotherapie'])
          : null,
      conduiteATenir: json['conduiteATenir'] != null
          ? ConducteATenirModel.fromJson(json['conduiteATenir'])
          : null,
      examenComplementaire: exams,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'sessionDate': sessionDate.toIso8601String(),
      'notes': notes,
      'examenClinique': examenClinique?.toJson(),
      'diagnostic': diagnostic?.toJson(),
      'physiotherapie': physiotherapie?.toJson(),
      'conduiteATenir': conduiteATenir?.toJson(),
      'examenComplementaire': examenComplementaire.map((e) => e.toJson()).toList(),
    };
  }
}

/// Clinical Exam (Examen Clinique)
class ExamenCliniqueModel {
  final String plainte;
  final String historique;
  final int intensiteEVA;
  final Map<String, dynamic>? constantScore;
  final Map<String, dynamic>? quickDashScore;
  final Map<String, dynamic>? dashArabeScore;
  final int? antepulsionActive;
  final int? antepulsionPassive;
  final int? abductionActive;
  final int? abductionPassive;
  final int? retractionActive;
  final int? retractionPassive;
  final int? rotationExterneActive;
  final int? rotationExternePassive;
  final int? rotationInterneActive;
  final int? rotationInternePassive;
  final int? deltoideTesting;
  final int? susEpineuxTesting;
  final int? infraEpineuxTesting;
  final int? subScapulaireTesting;
  final String? testJobe;
  final String? testPatte;
  final String? testGerber;
  final String? testNeer;
  final String? testHawkins;
  final int? mainBouche;
  final int? mainTete;
  final int? mainNuque;
  final int? mainDos;
  final String? observations;

  ExamenCliniqueModel({
    required this.plainte,
    required this.historique,
    required this.intensiteEVA,
    this.constantScore,
    this.quickDashScore,
    this.dashArabeScore,
    this.antepulsionActive,
    this.antepulsionPassive,
    this.abductionActive,
    this.abductionPassive,
    this.retractionActive,
    this.retractionPassive,
    this.rotationExterneActive,
    this.rotationExternePassive,
    this.rotationInterneActive,
    this.rotationInternePassive,
    this.deltoideTesting,
    this.susEpineuxTesting,
    this.infraEpineuxTesting,
    this.subScapulaireTesting,
    this.testJobe,
    this.testPatte,
    this.testGerber,
    this.testNeer,
    this.testHawkins,
    this.mainBouche,
    this.mainTete,
    this.mainNuque,
    this.mainDos,
    this.observations,
  });

  factory ExamenCliniqueModel.fromJson(Map<String, dynamic> json) {
    return ExamenCliniqueModel(
      plainte: json['plainte'] ?? '',
      historique: json['historique'] ?? '',
      intensiteEVA: json['intensiteEVA'] ?? 0,
      constantScore: json['constantScore'],
      quickDashScore: json['quickDashScore'],
      dashArabeScore: json['dashArabeScore'],
      antepulsionActive: json['antepulsionActive'],
      antepulsionPassive: json['antepulsionPassive'],
      abductionActive: json['abductionActive'],
      abductionPassive: json['abductionPassive'],
      retractionActive: json['retractionActive'],
      retractionPassive: json['retractionPassive'],
      rotationExterneActive: json['rotationExterneActive'],
      rotationExternePassive: json['rotationExternePassive'],
      rotationInterneActive: json['rotationInterneActive'],
      rotationInternePassive: json['rotationInternePassive'],
      deltoideTesting: json['deltoideTesting'],
      susEpineuxTesting: json['susEpineuxTesting'],
      infraEpineuxTesting: json['infraEpineuxTesting'],
      subScapulaireTesting: json['subScapulaireTesting'],
      testJobe: json['testJobe'],
      testPatte: json['testPatte'],
      testGerber: json['testGerber'],
      testNeer: json['testNeer'],
      testHawkins: json['testHawkins'],
      mainBouche: json['mainBouche'],
      mainTete: json['mainTete'],
      mainNuque: json['mainNuque'],
      mainDos: json['mainDos'],
      observations: json['observations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plainte': plainte,
      'historique': historique,
      'intensiteEVA': intensiteEVA,
      'constantScore': constantScore,
      'quickDashScore': quickDashScore,
      'dashArabeScore': dashArabeScore,
      'antepulsionActive': antepulsionActive,
      'antepulsionPassive': antepulsionPassive,
      'abductionActive': abductionActive,
      'abductionPassive': abductionPassive,
      'retractionActive': retractionActive,
      'retractionPassive': retractionPassive,
      'rotationExterneActive': rotationExterneActive,
      'rotationExternePassive': rotationExternePassive,
      'rotationInterneActive': rotationInterneActive,
      'rotationInternePassive': rotationInternePassive,
      'deltoideTesting': deltoideTesting,
      'susEpineuxTesting': susEpineuxTesting,
      'infraEpineuxTesting': infraEpineuxTesting,
      'subScapulaireTesting': subScapulaireTesting,
      'testJobe': testJobe,
      'testPatte': testPatte,
      'testGerber': testGerber,
      'testNeer': testNeer,
      'testHawkins': testHawkins,
      'mainBouche': mainBouche,
      'mainTete': mainTete,
      'mainNuque': mainNuque,
      'mainDos': mainDos,
      'observations': observations,
    };
  }
}

/// Complementary Exam (Examen Complémentaire)
class ComplementaryExamModel {
  final int? id;
  final String examType; // IRM, CT, X-Ray, etc.
  final String result;
  final String? fileUrl;

  ComplementaryExamModel({
    this.id,
    required this.examType,
    required this.result,
    this.fileUrl,
  });

  factory ComplementaryExamModel.fromJson(Map<String, dynamic> json) {
    return ComplementaryExamModel(
      id: json['id'],
      examType: json['examType'] ?? '',
      result: json['result'] ?? '',
      fileUrl: json['fileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examType': examType,
      'result': result,
      'fileUrl': fileUrl,
    };
  }
}

/// Diagnostic (Diagnosis)
class DiagnosticModel {
  final String diagnosticType; // SIMPLE, HYPERALGESIC, PSEUDO_PARALYTIC, FROZEN
  final String severity; // MILD, MODERATE, SEVERE
  final String description;
  final String? observations;

  DiagnosticModel({
    required this.diagnosticType,
    required this.severity,
    required this.description,
    this.observations,
  });

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticModel(
      diagnosticType: json['diagnosticType'] ?? 'SIMPLE',
      severity: json['severity'] ?? 'MODERATE',
      description: json['description'] ?? '',
      observations: json['observations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diagnosticType': diagnosticType,
      'severity': severity,
      'description': description,
      'observations': observations,
    };
  }
}

/// Treatment Plan (Conduite à Tenir)
class ConducteATenirModel {
  final String? medicamenteux;
  final bool infiltration;
  final String? infiltrationDetail;
  final String? prochainRDV;

  ConducteATenirModel({
    this.medicamenteux,
    this.infiltration = false,
    this.infiltrationDetail,
    this.prochainRDV,
  });

  factory ConducteATenirModel.fromJson(Map<String, dynamic> json) {
    return ConducteATenirModel(
      medicamenteux: json['medicamenteux'],
      infiltration: json['infiltration'] ?? false,
      infiltrationDetail: json['infiltrationDetail'],
      prochainRDV: json['prochainRDV'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicamenteux': medicamenteux,
      'infiltration': infiltration,
      'infiltrationDetail': infiltrationDetail,
      'prochainRDV': prochainRDV,
    };
  }
}

/// Physiotherapy Models (Physiothérapie)
class PhysiotherapieModel {
  final PhysioAssessmentModel? bilan;
  final PhysioProtocoleModel? protocole;
  final PhysioResultatModel? resultat;

  PhysiotherapieModel({
    this.bilan,
    this.protocole,
    this.resultat,
  });

  factory PhysiotherapieModel.fromJson(Map<String, dynamic> json) {
    return PhysiotherapieModel(
      bilan: json['bilan'] != null
          ? PhysioAssessmentModel.fromJson(json['bilan'])
          : null,
      protocole: json['protocole'] != null
          ? PhysioProtocoleModel.fromJson(json['protocole'])
          : null,
      resultat: json['resultat'] != null
          ? PhysioResultatModel.fromJson(json['resultat'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bilan': bilan?.toJson(),
      'protocole': protocole?.toJson(),
      'resultat': resultat?.toJson(),
    };
  }
}

/// Physiotherapy Assessment (Bilan)
class PhysioAssessmentModel {
  final String plainte;
  final String historique;
  final int intensiteEVA;
  final Map<String, dynamic>? constantScore;
  final Map<String, dynamic>? quickDashScore;
  final Map<String, dynamic>? dashArabeScore;
  final int? antepulsionActive;
  final int? antepulsionPassive;
  final int? abductionActive;
  final int? abductionPassive;
  final int? deltoideTesting;
  final String? testJobe;
  final String? observations;

  PhysioAssessmentModel({
    required this.plainte,
    required this.historique,
    required this.intensiteEVA,
    this.constantScore,
    this.quickDashScore,
    this.dashArabeScore,
    this.antepulsionActive,
    this.antepulsionPassive,
    this.abductionActive,
    this.abductionPassive,
    this.deltoideTesting,
    this.testJobe,
    this.observations,
  });

  factory PhysioAssessmentModel.fromJson(Map<String, dynamic> json) {
    return PhysioAssessmentModel(
      plainte: json['plainte'] ?? '',
      historique: json['historique'] ?? '',
      intensiteEVA: json['intensiteEVA'] ?? 0,
      constantScore: json['constantScore'],
      quickDashScore: json['quickDashScore'],
      dashArabeScore: json['dashArabeScore'],
      antepulsionActive: json['antepulsionActive'],
      antepulsionPassive: json['antepulsionPassive'],
      abductionActive: json['abductionActive'],
      abductionPassive: json['abductionPassive'],
      deltoideTesting: json['deltoideTesting'],
      testJobe: json['testJobe'],
      observations: json['observations'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plainte': plainte,
      'historique': historique,
      'intensiteEVA': intensiteEVA,
      'constantScore': constantScore,
      'quickDashScore': quickDashScore,
      'dashArabeScore': dashArabeScore,
      'antepulsionActive': antepulsionActive,
      'antepulsionPassive': antepulsionPassive,
      'abductionActive': abductionActive,
      'abductionPassive': abductionPassive,
      'deltoideTesting': deltoideTesting,
      'testJobe': testJobe,
      'observations': observations,
    };
  }
}

/// Physiotherapy Protocol (Protocole)
class PhysioProtocoleModel {
  final String? objectifsCourt;
  final String? objectifsLong;
  final bool physiotherapieAntalgique;
  final List<String> typesPhysio;
  final bool massage;
  final bool balneotherapie;
  final bool mobilisationsPassives;
  final bool mobilisationsActives;
  final bool renforcement;
  final bool proprioception;
  final String? exercicesDetail;
  final int? seancesParSemaine;
  final int? dureeSemaines;
  final bool orthese;
  final String? typeOrthese;

  PhysioProtocoleModel({
    this.objectifsCourt,
    this.objectifsLong,
    this.physiotherapieAntalgique = false,
    this.typesPhysio = const [],
    this.massage = false,
    this.balneotherapie = false,
    this.mobilisationsPassives = false,
    this.mobilisationsActives = false,
    this.renforcement = false,
    this.proprioception = false,
    this.exercicesDetail,
    this.seancesParSemaine,
    this.dureeSemaines,
    this.orthese = false,
    this.typeOrthese,
  });

  factory PhysioProtocoleModel.fromJson(Map<String, dynamic> json) {
    var typesList = json['typesPhysio'] as List? ?? [];
    List<String> types = typesList.map((i) => i.toString()).toList();

    return PhysioProtocoleModel(
      objectifsCourt: json['objectifsCourt'],
      objectifsLong: json['objectifsLong'],
      physiotherapieAntalgique: json['physiotherapieAntalgique'] ?? false,
      typesPhysio: types,
      massage: json['massage'] ?? false,
      balneotherapie: json['balnéotherapie'] ?? false,
      mobilisationsPassives: json['mobilisationsPassives'] ?? false,
      mobilisationsActives: json['mobilisationsActives'] ?? false,
      renforcement: json['renforcement'] ?? false,
      proprioception: json['proprioception'] ?? false,
      exercicesDetail: json['exercicesDetail'],
      seancesParSemaine: json['seancesParSemaine'],
      dureeSemaines: json['dureeSemaines'],
      orthese: json['orthese'] ?? false,
      typeOrthese: json['typeOrthese'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'objectifsCourt': objectifsCourt,
      'objectifsLong': objectifsLong,
      'physiotherapieAntalgique': physiotherapieAntalgique,
      'typesPhysio': typesPhysio,
      'massage': massage,
      'balnéotherapie': balneotherapie,
      'mobilisationsPassives': mobilisationsPassives,
      'mobilisationsActives': mobilisationsActives,
      'renforcement': renforcement,
      'proprioception': proprioception,
      'exercicesDetail': exercicesDetail,
      'seancesParSemaine': seancesParSemaine,
      'dureeSemaines': dureeSemaines,
      'orthese': orthese,
      'typeOrthese': typeOrthese,
    };
  }
}

/// Physiotherapy Results (Résultat)
class PhysioResultatModel {
  final Map<String, dynamic>? constantScoreFinal;
  final Map<String, dynamic>? quickDashScoreFinal;
  final int? evaFinale;
  final String? evolutionDouleur;
  final String? evolutionMobilite;
  final String? evolutionForce;
  final String? evolutionFonction;
  final int? antepulsionFinal;
  final int? abductionFinal;
  final int? rotationExterneFinal;
  final int? rotationInterneFinal;
  final bool objectifsAtteints;
  final String? conclusionKine;
  final String? suitesDonnees;

  PhysioResultatModel({
    this.constantScoreFinal,
    this.quickDashScoreFinal,
    this.evaFinale,
    this.evolutionDouleur,
    this.evolutionMobilite,
    this.evolutionForce,
    this.evolutionFonction,
    this.antepulsionFinal,
    this.abductionFinal,
    this.rotationExterneFinal,
    this.rotationInterneFinal,
    this.objectifsAtteints = false,
    this.conclusionKine,
    this.suitesDonnees,
  });

  factory PhysioResultatModel.fromJson(Map<String, dynamic> json) {
    return PhysioResultatModel(
      constantScoreFinal: json['constantScoreFinal'],
      quickDashScoreFinal: json['quickDashScoreFinal'],
      evaFinale: json['evaFinale'],
      evolutionDouleur: json['evolutionDouleur'],
      evolutionMobilite: json['evolutionMobilite'],
      evolutionForce: json['evolutionForce'],
      evolutionFonction: json['evolutionFonction'],
      antepulsionFinal: json['antepulsionFinal'],
      abductionFinal: json['abductionFinal'],
      rotationExterneFinal: json['rotationExterneFinal'],
      rotationInterneFinal: json['rotationInterneFinal'],
      objectifsAtteints: json['objectifsAtteints'] ?? false,
      conclusionKine: json['conclusionKine'],
      suitesDonnees: json['suitesDonnees'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'constantScoreFinal': constantScoreFinal,
      'quickDashScoreFinal': quickDashScoreFinal,
      'evaFinale': evaFinale,
      'evolutionDouleur': evolutionDouleur,
      'evolutionMobilite': evolutionMobilite,
      'evolutionForce': evolutionForce,
      'evolutionFonction': evolutionFonction,
      'antepulsionFinal': antepulsionFinal,
      'abductionFinal': abductionFinal,
      'rotationExterneFinal': rotationExterneFinal,
      'rotationInterneFinal': rotationInterneFinal,
      'objectifsAtteints': objectifsAtteints,
      'conclusionKine': conclusionKine,
      'suitesDonnees': suitesDonnees,
    };
  }
}
