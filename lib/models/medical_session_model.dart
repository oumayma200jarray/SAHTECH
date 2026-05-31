// Patient-facing medical session models.
// Field names match the Prisma schema returned by GET /users/sessions and
// GET /users/sessions/:id.

class MedicalSessionModel {
  final String sessionId;
  final DateTime sessionDate;
  final String? notes;
  final DiagnosticModel? diagnostic;
  final PhysiotherapiePatientModel? physiotherapie;
  final ConducteATenirModel? conduiteATenir;

  MedicalSessionModel({
    required this.sessionId,
    required this.sessionDate,
    this.notes,
    this.diagnostic,
    this.physiotherapie,
    this.conduiteATenir,
  });

  factory MedicalSessionModel.fromJson(Map<String, dynamic> json) {
    return MedicalSessionModel(
      sessionId: (json['sessionId'] ?? json['id'] ?? '').toString(),
      sessionDate: _parseDate(json['sessionDate'] ?? json['date']),
      notes: json['notes'],
      diagnostic: json['diagnostic'] != null
          ? DiagnosticModel.fromJson(json['diagnostic'] as Map<String, dynamic>)
          : null,
      physiotherapie: json['physiotherapie'] != null
          ? PhysiotherapiePatientModel.fromJson(
              json['physiotherapie'] as Map<String, dynamic>)
          : null,
      conduiteATenir: json['conduiteATenir'] != null
          ? ConducteATenirModel.fromJson(
              json['conduiteATenir'] as Map<String, dynamic>)
          : null,
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return DateTime.now();
    }
  }
}

// ─── Diagnostic ───────────────────────────────────────────────────────────────

class DiagnosticModel {
  /// douloureuse_simple | hyperalgique | pseudo_paralytique | bloquee
  final String typeEpaule;
  final String diagnostic;
  final String? diagnosticDiff;
  /// light | moderate | severe
  final String severite;
  final String? observations;

  DiagnosticModel({
    required this.typeEpaule,
    required this.diagnostic,
    this.diagnosticDiff,
    required this.severite,
    this.observations,
  });

  factory DiagnosticModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticModel(
      typeEpaule: json['typeEpaule'] ?? 'douloureuse_simple',
      diagnostic: json['diagnostic'] ?? '',
      diagnosticDiff: json['diagnosticDiff'],
      severite: json['severite'] ?? 'moderate',
      observations: json['observations'],
    );
  }
}

// ─── Conduite à tenir ─────────────────────────────────────────────────────────

class ConducteATenirModel {
  final String? antalgiques;
  final String? antiInflammatoires;
  final String? myorelaxants;
  final String? corticoides;
  final String? autresMedicaments;
  final bool infiltration;
  final String? infiltrationDetail;
  final bool ondesDeChoc;
  final bool arthroDistension;
  final bool chirurgie;
  final String? typeChirurgie;
  final bool reposRelatif;
  final String? recommandations;
  final String? objectifs;
  final String? prochainRDV;

  ConducteATenirModel({
    this.antalgiques,
    this.antiInflammatoires,
    this.myorelaxants,
    this.corticoides,
    this.autresMedicaments,
    this.infiltration = false,
    this.infiltrationDetail,
    this.ondesDeChoc = false,
    this.arthroDistension = false,
    this.chirurgie = false,
    this.typeChirurgie,
    this.reposRelatif = false,
    this.recommandations,
    this.objectifs,
    this.prochainRDV,
  });

  bool get hasAnyMedicament =>
      _ne(antalgiques) ||
      _ne(antiInflammatoires) ||
      _ne(myorelaxants) ||
      _ne(corticoides) ||
      _ne(autresMedicaments);

  static bool _ne(String? v) => v != null && v.trim().isNotEmpty;

  factory ConducteATenirModel.fromJson(Map<String, dynamic> json) {
    return ConducteATenirModel(
      antalgiques: json['antalgiques'],
      antiInflammatoires: json['antiInflammatoires'],
      myorelaxants: json['myorelaxants'],
      corticoides: json['corticoides'],
      autresMedicaments: json['autresMedicaments'],
      infiltration: json['infiltration'] ?? false,
      infiltrationDetail: json['infiltrationDetail'],
      ondesDeChoc: json['ondesDeChoc'] ?? false,
      arthroDistension: json['arthroDistension'] ?? false,
      chirurgie: json['chirurgie'] ?? false,
      typeChirurgie: json['typeChirurgie'],
      reposRelatif: json['reposRelatif'] ?? false,
      recommandations: json['recommandations'],
      objectifs: json['objectifs'],
      prochainRDV: json['prochainRDV'],
    );
  }
}

// ─── Physiothérapie ───────────────────────────────────────────────────────────

class PhysiotherapiePatientModel {
  final BilanKinesitherapiqueModel? bilanKinesitherapique;
  final ProtocoleReeducationModel? protocoleReeducation;
  final PhysioResultatModel? resultat;

  PhysiotherapiePatientModel({
    this.bilanKinesitherapique,
    this.protocoleReeducation,
    this.resultat,
  });

  factory PhysiotherapiePatientModel.fromJson(Map<String, dynamic> json) {
    return PhysiotherapiePatientModel(
      bilanKinesitherapique: json['bilanKinesitherapique'] != null
          ? BilanKinesitherapiqueModel.fromJson(
              json['bilanKinesitherapique'] as Map<String, dynamic>)
          : null,
      protocoleReeducation: json['protocoleReeducation'] != null
          ? ProtocoleReeducationModel.fromJson(
              json['protocoleReeducation'] as Map<String, dynamic>)
          : null,
      resultat: json['resultat'] != null
          ? PhysioResultatModel.fromJson(
              json['resultat'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ─── Bilan kinésithérapique ───────────────────────────────────────────────────

class BilanKinesitherapiqueModel {
  // Douleur
  final num? intensiteEVA; // can be 2.5 (double) or 5 (int)
  final String? siegeDouleur;
  final String? irradiation;
  final String? typeDouleur;
  final String? facteurAggravant;
  final String? facteurSoulageant;
  final String? debutDouleur;
  final bool? retentissementAVQ;
  final bool? retentissementProfessionnel;
  final bool? retentissementSommeil;
  // Arc douloureux & fin de course
  final bool? arcDouloureux;
  final String? arcDouloureuxIntervalle;
  final String? finDeCourse;
  // Cutané-trophique
  final bool? cutanePlaie;
  final bool? cutaneCicatrice;
  final bool? trophiqueOedeme;
  final bool? trophiqueEpanchement;
  final bool? peauAdherences;
  final bool? peauHypersensibilite;
  // ROM active
  final int? antepulsionActive;
  final int? extensionActive;
  final int? abductionActive;
  final int? adductionActive;
  final int? retractionActive;
  final int? rotationExterneActive;
  final int? rotationInterneActive;
  // ROM passive
  final int? antepulsionPassive;
  final int? extensionPassive;
  final int? abductionPassive;
  final int? adductionPassive;
  final int? retractionPassive;
  final int? rotationExternePassive;
  final int? rotationInternePassive;
  // Testing musculaire MRC (0-5)
  final int? deltoideTesting;
  final int? supraEpineuxTesting;
  final int? infraEpineuxTesting;
  final int? subscapulaireTesting;
  final int? grandPectoralTesting;
  final int? grandDorsalTesting;
  final int? trapSuperieurTesting;
  final int? trapMoyenTesting;
  final int? trapInferieurTesting;
  final int? denteleAntTesting;
  final int? longBicepsTesting;
  final int? tricepsLongTesting;
  final bool? deficitMusculaire;
  final bool? asymetrieDroiteGauche;
  // Synthèse musculaire
  final String? syntheseRetractes;
  final String? syntheseDouloureux;
  final String? syntheseDeficitaires;
  // Présences (amyotrophie / contractures / rétractations)
  final bool? amyotrophiePresence;
  final bool? contracturesPresence;
  final bool? retractionsPresence;
  // Tests spécifiques
  final bool? testJobe;
  final bool? testPatte;
  final bool? testGerber;
  final bool? testNeer;
  final bool? testHawkins;
  // Bilan fonctionnel — testsSimples ("effectue" | "difficulte" | "impossible")
  final String? mainBoucheTest;
  final String? mainTeteTest;
  final String? mainNuqueTest;
  final String? mainDosTest;
  // SF-12 & observations
  final String? sf12Score;
  final String? observations;

  BilanKinesitherapiqueModel({
    this.intensiteEVA,
    this.siegeDouleur,
    this.irradiation,
    this.typeDouleur,
    this.facteurAggravant,
    this.facteurSoulageant,
    this.debutDouleur,
    this.retentissementAVQ,
    this.retentissementProfessionnel,
    this.retentissementSommeil,
    this.arcDouloureux,
    this.arcDouloureuxIntervalle,
    this.finDeCourse,
    this.cutanePlaie,
    this.cutaneCicatrice,
    this.trophiqueOedeme,
    this.trophiqueEpanchement,
    this.peauAdherences,
    this.peauHypersensibilite,
    this.antepulsionActive,
    this.extensionActive,
    this.abductionActive,
    this.adductionActive,
    this.retractionActive,
    this.rotationExterneActive,
    this.rotationInterneActive,
    this.antepulsionPassive,
    this.extensionPassive,
    this.abductionPassive,
    this.adductionPassive,
    this.retractionPassive,
    this.rotationExternePassive,
    this.rotationInternePassive,
    this.deltoideTesting,
    this.supraEpineuxTesting,
    this.infraEpineuxTesting,
    this.subscapulaireTesting,
    this.grandPectoralTesting,
    this.grandDorsalTesting,
    this.trapSuperieurTesting,
    this.trapMoyenTesting,
    this.trapInferieurTesting,
    this.denteleAntTesting,
    this.longBicepsTesting,
    this.tricepsLongTesting,
    this.deficitMusculaire,
    this.asymetrieDroiteGauche,
    this.syntheseRetractes,
    this.syntheseDouloureux,
    this.syntheseDeficitaires,
    this.amyotrophiePresence,
    this.contracturesPresence,
    this.retractionsPresence,
    this.testJobe,
    this.testPatte,
    this.testGerber,
    this.testNeer,
    this.testHawkins,
    this.mainBoucheTest,
    this.mainTeteTest,
    this.mainNuqueTest,
    this.mainDosTest,
    this.sf12Score,
    this.observations,
  });

  factory BilanKinesitherapiqueModel.fromJson(Map<String, dynamic> json) {
    final syn = json['syntheseMusculaire'] as Map<String, dynamic>?;
    final bf = json['bilanFonctionnel'] as Map<String, dynamic>?;
    final ts = bf?['testsSimples'] as Map<String, dynamic>?;

    return BilanKinesitherapiqueModel(
      intensiteEVA: json['intensiteEVA'] as num?,
      siegeDouleur: json['siegeDouleur'],
      irradiation: json['irradiation'],
      typeDouleur: json['typeDouleur'],
      facteurAggravant: json['facteurAggravant'],
      facteurSoulageant: json['facteurSoulageant'],
      debutDouleur: json['debutDouleur'],
      retentissementAVQ: json['retentissementAVQ'],
      retentissementProfessionnel: json['retentissementProfessionnel'],
      retentissementSommeil: json['retentissementSommeil'],
      arcDouloureux: json['arcDouloureux'],
      arcDouloureuxIntervalle: json['arcDouloureuxIntervalle'],
      finDeCourse: json['finDeCourse'],
      cutanePlaie: json['cutanePlaie'],
      cutaneCicatrice: json['cutaneCicatrice'],
      trophiqueOedeme: json['trophiqueOedeme'],
      trophiqueEpanchement: json['trophiqueEpanchement'],
      peauAdherences: json['peauAdherences'],
      peauHypersensibilite: json['peauHypersensibilite'],
      antepulsionActive: json['antepulsionActive'],
      extensionActive: json['extensionActive'],
      abductionActive: json['abductionActive'],
      adductionActive: json['adductionActive'],
      retractionActive: json['retractionActive'],
      rotationExterneActive: json['rotationExterneActive'],
      rotationInterneActive: json['rotationInterneActive'],
      antepulsionPassive: json['antepulsionPassive'],
      extensionPassive: json['extensionPassive'],
      abductionPassive: json['abductionPassive'],
      adductionPassive: json['adductionPassive'],
      retractionPassive: json['retractionPassive'],
      rotationExternePassive: json['rotationExternePassive'],
      rotationInternePassive: json['rotationInternePassive'],
      deltoideTesting: json['deltoideTesting'],
      supraEpineuxTesting: json['supraEpineuxTesting'],
      infraEpineuxTesting: json['infraEpineuxTesting'],
      subscapulaireTesting: json['subscapulaireTesting'],
      grandPectoralTesting: json['grandPectoralTesting'],
      grandDorsalTesting: json['grandDorsalTesting'],
      trapSuperieurTesting: json['trapSuperieurTesting'],
      trapMoyenTesting: json['trapMoyenTesting'],
      trapInferieurTesting: json['trapInferieurTesting'],
      denteleAntTesting: json['denteleAntTesting'],
      longBicepsTesting: json['longBicepsTesting'],
      tricepsLongTesting: json['tricepsLongTesting'],
      deficitMusculaire: json['deficitMusculaire'],
      asymetrieDroiteGauche: json['asymetrieDroiteGauche'],
      syntheseRetractes: syn?['musclesRetractes'],
      syntheseDouloureux: syn?['musclesDouloureux'],
      syntheseDeficitaires: syn?['musclesDeficitaires'],
      amyotrophiePresence: json['amyotrophiePresence'],
      contracturesPresence: json['contracturesPresence'],
      retractionsPresence: json['retractionsPresence'],
      testJobe: json['testJobe'],
      testPatte: json['testPatte'],
      testGerber: json['testGerber'],
      testNeer: json['testNeer'],
      testHawkins: json['testHawkins'],
      mainBoucheTest: ts?['mainBouche'],
      mainTeteTest: ts?['mainTete'],
      mainNuqueTest: ts?['mainNuque'],
      mainDosTest: ts?['mainDos'],
      sf12Score: json['sf12Score'],
      observations: json['observations'],
    );
  }
}

// ─── Protocole de rééducation ─────────────────────────────────────────────────

class ProtocoleReeducationModel {
  // Objectifs & organisation
  final String? objectifsCourt;
  final String? objectifsLong;
  final int? seancesParSemaine;
  final int? dureeSemaines;
  final int? dureeSeance;
  final String? exercicesDetail;
  // Électrophysiothérapie
  final bool? tensAntalgique;
  final bool? courantsExcitoMoteurs;
  final bool? ultrasons;
  final bool? ondesDeChoc;
  final bool? cryotherapie;
  final bool? thermotherapie;
  final String? electrophysioAutre;
  // Thérapie manuelle antalgique
  final bool? massageDecontracturant;
  final bool? mtp;
  final bool? triggerPoints;
  final bool? drainageLymphatique;
  final String? therapieManuAutre;
  // Balnéothérapie & taping
  final bool? balneotherapie;
  final String? balneotherapiePrecisions;
  final bool? taping;
  final String? tapingType;
  // Techniques manuelles kiné
  final bool? mobPassivesGlenoHumerales;
  final bool? mobPassivesScapulothoraciques;
  final bool? mulligan;
  final bool? mobActivesAssistees;
  final bool? pendulairesCodeman;
  final bool? etirementsCapsulairesPost;
  final bool? etirementsCapsulairesAnt;
  final bool? etirementsCapsulairesInf;
  final bool? pompagesCapsulaires;
  final bool? leveesDeTension;
  final String? techManuAutre;
  // Renforcement
  final bool? renfIsometrique;
  final bool? renfConcentrique;
  final bool? renfExcentrique;
  final bool? renfPliometrique;
  final bool? muscleCoiffe;
  final bool? muscleDeltoide;
  final bool? muscleStabilisateursScap;
  final String? renforcementAutre;
  // Contrôle moteur
  final bool? stabilisationScapDyn;
  final bool? recentrageGH;
  final bool? coordinationScapHum;
  final bool? proprioStatique;
  final bool? proprioDynamique;
  final bool? travailPostural;
  final bool? correctionCompensations;
  // Orthèse
  final bool? orthese;
  final String? typeOrthese;
  // HEP
  final bool? hepPrescrit;
  final String? hepExercices;
  final int? hepSeancesJour;
  final int? hepRepetitions;
  final int? hepSeries;
  final String? hepFrequence;
  final String? hepConsignesDouleur;
  // Éducation thérapeutique
  final bool? eduPosturaux;
  final bool? eduLoadManagement;
  final bool? eduSommeil;
  final bool? eduNeuroscienceDouleur;
  final String? eduNotes;

  ProtocoleReeducationModel({
    this.objectifsCourt,
    this.objectifsLong,
    this.seancesParSemaine,
    this.dureeSemaines,
    this.dureeSeance,
    this.exercicesDetail,
    this.tensAntalgique,
    this.courantsExcitoMoteurs,
    this.ultrasons,
    this.ondesDeChoc,
    this.cryotherapie,
    this.thermotherapie,
    this.electrophysioAutre,
    this.massageDecontracturant,
    this.mtp,
    this.triggerPoints,
    this.drainageLymphatique,
    this.therapieManuAutre,
    this.balneotherapie,
    this.balneotherapiePrecisions,
    this.taping,
    this.tapingType,
    this.mobPassivesGlenoHumerales,
    this.mobPassivesScapulothoraciques,
    this.mulligan,
    this.mobActivesAssistees,
    this.pendulairesCodeman,
    this.etirementsCapsulairesPost,
    this.etirementsCapsulairesAnt,
    this.etirementsCapsulairesInf,
    this.pompagesCapsulaires,
    this.leveesDeTension,
    this.techManuAutre,
    this.renfIsometrique,
    this.renfConcentrique,
    this.renfExcentrique,
    this.renfPliometrique,
    this.muscleCoiffe,
    this.muscleDeltoide,
    this.muscleStabilisateursScap,
    this.renforcementAutre,
    this.stabilisationScapDyn,
    this.recentrageGH,
    this.coordinationScapHum,
    this.proprioStatique,
    this.proprioDynamique,
    this.travailPostural,
    this.correctionCompensations,
    this.orthese,
    this.typeOrthese,
    this.hepPrescrit,
    this.hepExercices,
    this.hepSeancesJour,
    this.hepRepetitions,
    this.hepSeries,
    this.hepFrequence,
    this.hepConsignesDouleur,
    this.eduPosturaux,
    this.eduLoadManagement,
    this.eduSommeil,
    this.eduNeuroscienceDouleur,
    this.eduNotes,
  });

  factory ProtocoleReeducationModel.fromJson(Map<String, dynamic> json) {
    return ProtocoleReeducationModel(
      objectifsCourt: json['objectifsCourt'],
      objectifsLong: json['objectifsLong'],
      seancesParSemaine: json['seancesParSemaine'],
      dureeSemaines: json['dureeSemaines'],
      dureeSeance: json['dureeSeance'],
      exercicesDetail: json['exercicesDetail'],
      tensAntalgique: json['tensAntalgique'],
      courantsExcitoMoteurs: json['courantsExcitoMoteurs'],
      ultrasons: json['ultrasons'],
      ondesDeChoc: json['ondesDeChoc'],
      cryotherapie: json['cryotherapie'],
      thermotherapie: json['thermotherapie'],
      electrophysioAutre: json['electrophysioAutre'],
      massageDecontracturant: json['massageDecontracturant'],
      mtp: json['mtp'],
      triggerPoints: json['triggerPoints'],
      drainageLymphatique: json['drainageLymphatique'],
      therapieManuAutre: json['therapieManuAutre'],
      balneotherapie: json['balneotherapie'],
      balneotherapiePrecisions: json['balneotherapiePrecisions'],
      taping: json['taping'],
      tapingType: json['tapingType'],
      mobPassivesGlenoHumerales: json['mobPassivesGlenoHumerales'],
      mobPassivesScapulothoraciques: json['mobPassivesScapulothoraciques'],
      mulligan: json['mulligan'],
      mobActivesAssistees: json['mobActivesAssistees'],
      pendulairesCodeman: json['pendulairesCodeman'],
      etirementsCapsulairesPost: json['etirementsCapsulairesPost'],
      etirementsCapsulairesAnt: json['etirementsCapsulairesAnt'],
      etirementsCapsulairesInf: json['etirementsCapsulairesInf'],
      pompagesCapsulaires: json['pompagesCapsulaires'],
      leveesDeTension: json['leveesDeTension'],
      techManuAutre: json['techManuAutre'],
      renfIsometrique: json['renfIsometrique'],
      renfConcentrique: json['renfConcentrique'],
      renfExcentrique: json['renfExcentrique'],
      renfPliometrique: json['renfPliometrique'],
      muscleCoiffe: json['muscleCoiffe'],
      muscleDeltoide: json['muscleDeltoide'],
      muscleStabilisateursScap: json['muscleStabilisateursScap'],
      renforcementAutre: json['renforcementAutre'],
      stabilisationScapDyn: json['stabilisationScapDyn'],
      recentrageGH: json['recentrageGH'],
      coordinationScapHum: json['coordinationScapHum'],
      proprioStatique: json['proprioStatique'],
      proprioDynamique: json['proprioDynamique'],
      travailPostural: json['travailPostural'],
      correctionCompensations: json['correctionCompensations'],
      orthese: json['orthese'],
      typeOrthese: json['typeOrthese'],
      hepPrescrit: json['hepPrescrit'],
      hepExercices: json['hepExercices'],
      hepSeancesJour: json['hepSeancesJour'],
      hepRepetitions: json['hepRepetitions'],
      hepSeries: json['hepSeries'],
      hepFrequence: json['hepFrequence'],
      hepConsignesDouleur: json['hepConsignesDouleur'],
      eduPosturaux: json['eduPosturaux'],
      eduLoadManagement: json['eduLoadManagement'],
      eduSommeil: json['eduSommeil'],
      eduNeuroscienceDouleur: json['eduNeuroscienceDouleur'],
      eduNotes: json['eduNotes'],
    );
  }

  /// Returns labels of all active electrophysio techniques.
  List<String> get electrophysioActifs {
    final r = <String>[];
    if (tensAntalgique == true) r.add('TENS antalgique');
    if (courantsExcitoMoteurs == true) r.add('Courants excito-moteurs');
    if (ultrasons == true) r.add('Ultrasons');
    if (ondesDeChoc == true) r.add('Ondes de choc');
    if (cryotherapie == true) r.add('Cryothérapie');
    if (thermotherapie == true) r.add('Thermothérapie');
    if (_ne(electrophysioAutre)) r.add(electrophysioAutre!);
    return r;
  }

  List<String> get therapieManuActifs {
    final r = <String>[];
    if (massageDecontracturant == true) r.add('Massage décontracturant');
    if (mtp == true) r.add('MTP');
    if (triggerPoints == true) r.add('Trigger points');
    if (drainageLymphatique == true) r.add('Drainage lymphatique');
    if (balneotherapie == true) {
      r.add(balneotherapiePrecisions?.isNotEmpty == true
          ? 'Balnéothérapie ($balneotherapiePrecisions)'
          : 'Balnéothérapie');
    }
    if (taping == true) {
      r.add(tapingType?.isNotEmpty == true ? 'Taping ($tapingType)' : 'Taping');
    }
    if (_ne(therapieManuAutre)) r.add(therapieManuAutre!);
    return r;
  }

  List<String> get techniquesKineActifs {
    final r = <String>[];
    if (mobPassivesGlenoHumerales == true) r.add('Mob. passives gléno-humérales');
    if (mobPassivesScapulothoraciques == true) r.add('Mob. passives scapulo-thoraciques');
    if (mulligan == true) r.add('Mulligan');
    if (mobActivesAssistees == true) r.add('Mob. actives assistées');
    if (pendulairesCodeman == true) r.add('Pendulaires Codeman');
    if (etirementsCapsulairesPost == true) r.add('Étirements capsulaires post.');
    if (etirementsCapsulairesAnt == true) r.add('Étirements capsulaires ant.');
    if (etirementsCapsulairesInf == true) r.add('Étirements capsulaires inf.');
    if (pompagesCapsulaires == true) r.add('Pompages capsulaires');
    if (leveesDeTension == true) r.add('Levées de tension');
    if (_ne(techManuAutre)) r.add(techManuAutre!);
    return r;
  }

  List<String> get renforcementActifs {
    final r = <String>[];
    if (renfIsometrique == true) r.add('Isométrique');
    if (renfConcentrique == true) r.add('Concentrique');
    if (renfExcentrique == true) r.add('Excentrique');
    if (renfPliometrique == true) r.add('Pliométrique');
    if (muscleCoiffe == true) r.add('Coiffe des rotateurs');
    if (muscleDeltoide == true) r.add('Deltoïde');
    if (muscleStabilisateursScap == true) r.add('Stabilisateurs scapulaires');
    if (_ne(renforcementAutre)) r.add(renforcementAutre!);
    return r;
  }

  List<String> get controleMoteurActifs {
    final r = <String>[];
    if (stabilisationScapDyn == true) r.add('Stabilisation scapulaire dyn.');
    if (recentrageGH == true) r.add('Recentrage G-H');
    if (coordinationScapHum == true) r.add('Coordination scapulo-humérale');
    if (proprioStatique == true) r.add('Proprioception statique');
    if (proprioDynamique == true) r.add('Proprioception dynamique');
    if (travailPostural == true) r.add('Travail postural');
    if (correctionCompensations == true) r.add('Correction des compensations');
    return r;
  }

  List<String> get educationActifs {
    final r = <String>[];
    if (eduPosturaux == true) r.add('Conseils posturaux');
    if (eduLoadManagement == true) r.add('Load management');
    if (eduSommeil == true) r.add('Hygiène du sommeil');
    if (eduNeuroscienceDouleur == true) r.add('Éducation à la douleur');
    return r;
  }

  static bool _ne(String? v) => v != null && v.trim().isNotEmpty;
}

// ─── Résultat physiothérapie ──────────────────────────────────────────────────

class PhysioResultatModel {
  final num? evaFinal;
  final String? evolutionDouleur;
  final String? evolutionMobilite;
  final String? evolutionForce;
  final String? evolutionFonction;
  // Final ROM
  final int? antepulsionFinal;
  final int? extensionFinal;
  final int? abductionFinal;
  final int? adductionFinal;
  final int? rotationExterneFinal;
  final int? rotationInterneFinal;
  final bool objectifsAtteints;
  final String? conclusionKine;
  final String? suitesDonnees;

  PhysioResultatModel({
    this.evaFinal,
    this.evolutionDouleur,
    this.evolutionMobilite,
    this.evolutionForce,
    this.evolutionFonction,
    this.antepulsionFinal,
    this.extensionFinal,
    this.abductionFinal,
    this.adductionFinal,
    this.rotationExterneFinal,
    this.rotationInterneFinal,
    this.objectifsAtteints = false,
    this.conclusionKine,
    this.suitesDonnees,
  });

  factory PhysioResultatModel.fromJson(Map<String, dynamic> json) {
    return PhysioResultatModel(
      evaFinal: json['evaFinal'] as num?,
      evolutionDouleur: json['evolutionDouleur'],
      evolutionMobilite: json['evolutionMobilite'],
      evolutionForce: json['evolutionForce'],
      evolutionFonction: json['evolutionFonction'],
      antepulsionFinal: json['antepulsionFinal'],
      extensionFinal: json['extensionFinal'],
      abductionFinal: json['abductionFinal'],
      adductionFinal: json['adductionFinal'],
      rotationExterneFinal: json['rotationExterneFinal'],
      rotationInterneFinal: json['rotationInterneFinal'],
      objectifsAtteints: json['objectifsAtteints'] ?? false,
      conclusionKine: json['conclusionKine'],
      suitesDonnees: json['suitesDonnees'],
    );
  }
}
