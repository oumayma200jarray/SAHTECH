import 'package:flutter/material.dart';
import 'package:sahtek/core/api/endpoint.dart';
import 'package:sahtek/models/medical_session_model.dart';

class PatientSessionDetailPage extends StatefulWidget {
  final String sessionId;
  const PatientSessionDetailPage({super.key, required this.sessionId});

  @override
  State<PatientSessionDetailPage> createState() =>
      _PatientSessionDetailPageState();
}

class _PatientSessionDetailPageState extends State<PatientSessionDetailPage> {
  MedicalSessionModel? _session;
  bool _loading = true;
  String? _error;
  int _physioTab = 0; // 0=Bilan 1=Protocole 2=Résultat

  static const _blue = Color(0xFF0052FF);
  static const _green = Color(0xFF16A34A);
  static const _orange = Color(0xFFEA580C);
  static const _textPrimary = Color(0xFF0A0F1E);
  static const _textSecondary = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFF);
  static const _divider = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _fetchSession();
  }

  Future<void> _fetchSession() async {
    setState(() { _loading = true; _error = null; });
    try {
      final dynamic raw =
          await EndPoint.client.get(EndPoint.userSessionById(widget.sessionId));
      setState(() => _session =
          MedicalSessionModel.fromJson(raw as Map<String, dynamic>));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  static String _fmtDate(DateTime d) {
    const m = ['janvier','février','mars','avril','mai','juin',
      'juillet','août','septembre','octobre','novembre','décembre'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  // ─── Scaffold ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _session != null ? _fmtDate(_session!.sessionDate) : 'Détail session',
          style: const TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_loading && _error != null)
            IconButton(icon: const Icon(Icons.refresh, color: _blue), onPressed: _fetchSession),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _blue));
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.error_outline, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 16),
              const Text('Impossible de charger la session',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textPrimary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(fontSize: 12, color: _textSecondary),
                  textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchSession,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_session == null) return const SizedBox.shrink();

    final s = _session!;
    final hasAny = s.diagnostic != null || s.physiotherapie != null || s.conduiteATenir != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _headerCard(s, hasAny),
        if (s.diagnostic != null) ...[const SizedBox(height: 16), _diagnosticSection(s.diagnostic!)],
        if (s.physiotherapie != null) ...[const SizedBox(height: 16), _physioSection(s.physiotherapie!)],
        if (s.conduiteATenir != null) ...[const SizedBox(height: 16), _conduiteSection(s.conduiteATenir!)],
        if (!hasAny) ...[const SizedBox(height: 16), _emptyCard()],
      ],
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _headerCard(MedicalSessionModel s, bool hasAny) {
    final count = [s.diagnostic, s.physiotherapie, s.conduiteATenir].where((e) => e != null).length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_fmtDate(s.sessionDate),
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          if (s.notes != null && s.notes!.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 2),
                child: Text(s.notes!, style: const TextStyle(color: Colors.white70, fontSize: 12))),
          const SizedBox(height: 4),
          Text(
            hasAny ? '$count section${count > 1 ? 's' : ''} disponible${count > 1 ? 's' : ''}' : 'Aucune information',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ])),
      ]),
    );
  }

  // ─── Diagnostic ─────────────────────────────────────────────────────────────

  Widget _diagnosticSection(DiagnosticModel d) {
    final typeInfo = _typeEpauleInfo(d.typeEpaule);
    final sevColor = _severityColor(d.severite);

    return _card(
      title: 'Diagnostic',
      icon: Icons.biotech_outlined,
      accent: _blue,
      headerBg: const Color(0xFFEFF6FF),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 8, runSpacing: 6, children: [
          _chip(typeInfo.label, typeInfo.color, typeInfo.color.withValues(alpha: 0.12)),
          _chip(_severityLabel(d.severite), sevColor, sevColor.withValues(alpha: 0.12)),
        ]),
        const SizedBox(height: 14),
        if (d.diagnostic.isNotEmpty) _block('Diagnostic principal', d.diagnostic),
        if (_ne(d.diagnosticDiff)) _block('Diagnostic différentiel', d.diagnosticDiff!),
        if (_ne(d.observations)) _block('Observations', d.observations!),
      ]),
    );
  }

  // ─── Physiothérapie ─────────────────────────────────────────────────────────

  Widget _physioSection(PhysiotherapiePatientModel p) {
    return _card(
      title: 'Physiothérapie',
      icon: Icons.accessibility_new_outlined,
      accent: _green,
      headerBg: const Color(0xFFF0FDF4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Sub-tab bar
        _subTabBar(['Bilan', 'Protocole', 'Résultat'], _physioTab, (i) => setState(() => _physioTab = i), _green),
        const SizedBox(height: 16),
        if (_physioTab == 0)
          p.bilanKinesitherapique != null
              ? _bilanContent(p.bilanKinesitherapique!)
              : _noData('Aucun bilan disponible'),
        if (_physioTab == 1)
          p.protocoleReeducation != null
              ? _protocoleContent(p.protocoleReeducation!)
              : _noData('Aucun protocole disponible'),
        if (_physioTab == 2)
          p.resultat != null
              ? _resultatContent(p.resultat!)
              : _noData('Aucun résultat disponible'),
      ]),
    );
  }

  // ─── Bilan content ──────────────────────────────────────────────────────────

  Widget _bilanContent(BilanKinesitherapiqueModel b) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── Douleur ──────────────────────────────────────────────────────
      _sectionLabel('Douleur'),
      if (b.intensiteEVA != null) ...[
        _label('Intensité EVA'),
        const SizedBox(height: 6),
        _evaBar(b.intensiteEVA!),
        const SizedBox(height: 12),
      ],
      if (_ne(b.siegeDouleur)) _row('Siège', b.siegeDouleur!),
      if (_ne(b.irradiation)) _row('Irradiation', b.irradiation!),
      if (_ne(b.typeDouleur)) _row('Type', _douleurLabel(b.typeDouleur!)),
      if (_ne(b.debutDouleur)) _row('Début', _debutLabel(b.debutDouleur!)),
      if (_ne(b.facteurAggravant)) _row('Facteur aggravant', b.facteurAggravant!),
      if (_ne(b.facteurSoulageant)) _row('Facteur soulageant', b.facteurSoulageant!),

      // Impact
      if (b.retentissementAVQ == true || b.retentissementProfessionnel == true || b.retentissementSommeil == true) ...[
        const SizedBox(height: 6),
        _label('Retentissement'),
        if (b.retentissementAVQ == true) _boolRow('Activités quotidiennes', true),
        if (b.retentissementProfessionnel == true) _boolRow('Activité professionnelle', true),
        if (b.retentissementSommeil == true) _boolRow('Sommeil', true),
      ],

      _dividerLine(),

      // ── Amplitude articulaire ─────────────────────────────────────────
      _sectionLabel('Amplitude articulaire (°)'),
      _romHeader(),
      _romRow('Antépulsion', b.antepulsionActive, b.antepulsionPassive),
      _romRow('Extension', b.extensionActive, b.extensionPassive),
      _romRow('Abduction', b.abductionActive, b.abductionPassive),
      _romRow('Adduction', b.adductionActive, b.adductionPassive),
      _romRow('Rétraction', b.retractionActive, b.retractionPassive),
      _romRow('Rot. externe', b.rotationExterneActive, b.rotationExternePassive),
      _romRow('Rot. interne', b.rotationInterneActive, b.rotationInternePassive),

      _dividerLine(),

      // ── Arc douloureux ───────────────────────────────────────────────
      if (b.arcDouloureux != null || _ne(b.finDeCourse)) ...[
        _sectionLabel('Arc douloureux & fin de course'),
        if (b.arcDouloureux != null) _boolRow('Arc douloureux', b.arcDouloureux!),
        if (b.arcDouloureux == true && _ne(b.arcDouloureuxIntervalle))
          Padding(padding: const EdgeInsets.only(left: 28, bottom: 4),
              child: Text(b.arcDouloureuxIntervalle!, style: const TextStyle(fontSize: 12, color: _textSecondary))),
        if (_ne(b.finDeCourse)) _row('Fin de course', _finDeCourseLabel(b.finDeCourse!)),
        _dividerLine(),
      ],

      // ── Tests spécifiques ────────────────────────────────────────────
      if ([b.testJobe, b.testPatte, b.testGerber, b.testNeer, b.testHawkins].any((t) => t != null)) ...[
        _sectionLabel('Tests spécifiques'),
        _testsSpecifiquesTable(b),
        _dividerLine(),
      ],

      // ── Bilan fonctionnel ────────────────────────────────────────────
      if ([b.mainBoucheTest, b.mainTeteTest, b.mainNuqueTest, b.mainDosTest].any((t) => t != null)) ...[
        _sectionLabel('Bilan fonctionnel'),
        _bilanFonctionnelTable(b),
        _dividerLine(),
      ],

      // ── Testing musculaire ───────────────────────────────────────────
      _sectionLabel('Testing musculaire (MRC 0-5)'),
      _muscleTestingGrid(b),

      if (b.deficitMusculaire == true || b.asymetrieDroiteGauche == true) ...[
        const SizedBox(height: 4),
        if (b.deficitMusculaire == true) _boolRow('Déficit musculaire', true),
        if (b.asymetrieDroiteGauche == true) _boolRow('Asymétrie droite/gauche', true),
      ],
      if (_ne(b.syntheseRetractes) || _ne(b.syntheseDouloureux) || _ne(b.syntheseDeficitaires)) ...[
        const SizedBox(height: 8),
        if (_ne(b.syntheseRetractes)) _row('Muscles rétractés', b.syntheseRetractes!),
        if (_ne(b.syntheseDouloureux)) _row('Muscles douloureux', b.syntheseDouloureux!),
        if (_ne(b.syntheseDeficitaires)) _row('Muscles déficitaires', b.syntheseDeficitaires!),
      ],

      // ── Cutané-trophique ─────────────────────────────────────────────
      if ([b.cutanePlaie, b.cutaneCicatrice, b.trophiqueOedeme,
          b.trophiqueEpanchement, b.peauAdherences, b.peauHypersensibilite].any((v) => v == true)) ...[
        _dividerLine(),
        _sectionLabel('Cutané & trophique'),
        if (b.cutanePlaie == true) _boolRow('Plaie', true),
        if (b.cutaneCicatrice == true) _boolRow('Cicatrice', true),
        if (b.trophiqueOedeme == true) _boolRow('Oedème', true),
        if (b.trophiqueEpanchement == true) _boolRow('Épanchement', true),
        if (b.peauAdherences == true) _boolRow('Adhérences', true),
        if (b.peauHypersensibilite == true) _boolRow('Hypersensibilité', true),
      ],

      // ── Présences musculaires ────────────────────────────────────────
      if (b.amyotrophiePresence == true || b.contracturesPresence == true || b.retractionsPresence == true) ...[
        _dividerLine(),
        _sectionLabel('Bilan musculaire'),
        if (b.amyotrophiePresence == true) _boolRow('Amyotrophie présente', true),
        if (b.contracturesPresence == true) _boolRow('Contractures présentes', true),
        if (b.retractionsPresence == true) _boolRow('Rétractations présentes', true),
      ],

      // ── SF-12 & observations ─────────────────────────────────────────
      if (_ne(b.sf12Score) || _ne(b.observations)) ...[
        _dividerLine(),
        if (_ne(b.sf12Score)) _row('Score SF-12', b.sf12Score!),
        if (_ne(b.observations)) _block('Observations', b.observations!),
      ],
    ]);
  }

  // ─── Protocole content ───────────────────────────────────────────────────────

  Widget _protocoleContent(ProtocoleReeducationModel p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Objectifs
      if (_ne(p.objectifsCourt)) _block('Objectifs court terme', p.objectifsCourt!),
      if (_ne(p.objectifsLong)) _block('Objectifs long terme', p.objectifsLong!),

      // Organisation
      if (p.seancesParSemaine != null || p.dureeSemaines != null || p.dureeSeance != null) ...[
        _sectionLabel('Organisation'),
        if (p.seancesParSemaine != null) _row('Séances / semaine', '${p.seancesParSemaine}'),
        if (p.dureeSemaines != null) _row('Durée totale', '${p.dureeSemaines} semaines'),
        if (p.dureeSeance != null) _row('Durée de séance', '${p.dureeSeance} min'),
        _dividerLine(),
      ],

      // Électrophysiothérapie
      if (p.electrophysioActifs.isNotEmpty) ...[
        _sectionLabel('Électrophysiothérapie'),
        _chipsWrap(p.electrophysioActifs, _blue, const Color(0xFFEFF6FF)),
        _dividerLine(),
      ],

      // Thérapie manuelle
      if (p.therapieManuActifs.isNotEmpty) ...[
        _sectionLabel('Thérapie manuelle antalgique'),
        _chipsWrap(p.therapieManuActifs, const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
        _dividerLine(),
      ],

      // Techniques kiné
      if (p.techniquesKineActifs.isNotEmpty) ...[
        _sectionLabel('Techniques manuelles kiné'),
        _chipsWrap(p.techniquesKineActifs, _green, const Color(0xFFF0FDF4)),
        _dividerLine(),
      ],

      // Renforcement
      if (p.renforcementActifs.isNotEmpty) ...[
        _sectionLabel('Renforcement musculaire'),
        _chipsWrap(p.renforcementActifs, _orange, const Color(0xFFFFF7ED)),
        _dividerLine(),
      ],

      // Contrôle moteur
      if (p.controleMoteurActifs.isNotEmpty) ...[
        _sectionLabel('Contrôle moteur & proprioception'),
        _chipsWrap(p.controleMoteurActifs, const Color(0xFF0891B2), const Color(0xFFECFEFF)),
        _dividerLine(),
      ],

      // Éducation thérapeutique
      if (p.educationActifs.isNotEmpty || _ne(p.eduNotes)) ...[
        _sectionLabel('Éducation thérapeutique'),
        if (p.educationActifs.isNotEmpty) _chipsWrap(p.educationActifs, _textSecondary, const Color(0xFFF8FAFF)),
        if (_ne(p.eduNotes)) ...[const SizedBox(height: 6), _block('Notes éducation', p.eduNotes!)],
        _dividerLine(),
      ],

      // Orthèse
      if (p.orthese == true) ...[
        _sectionLabel('Orthèse'),
        _boolRow('Orthèse prescrite', true),
        if (_ne(p.typeOrthese)) _row('Type', p.typeOrthese!),
        _dividerLine(),
      ],

      // Exercices
      if (_ne(p.exercicesDetail)) ...[
        _sectionLabel('Exercices prescrits'),
        _block('', p.exercicesDetail!),
        _dividerLine(),
      ],

      // HEP
      if (p.hepPrescrit == true) ...[
        _sectionLabel('Programme à domicile (HEP)'),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _green.withValues(alpha: 0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_ne(p.hepExercices)) _row('Exercices', p.hepExercices!),
            if (p.hepSeancesJour != null) _row('Séances / jour', '${p.hepSeancesJour}'),
            if (p.hepRepetitions != null) _row('Répétitions', '${p.hepRepetitions}'),
            if (p.hepSeries != null) _row('Séries', '${p.hepSeries}'),
            if (_ne(p.hepFrequence)) _row('Fréquence', p.hepFrequence!),
            if (_ne(p.hepConsignesDouleur)) _row('Consignes douleur', p.hepConsignesDouleur!),
          ]),
        ),
      ],
    ]);
  }

  // ─── Résultat content ────────────────────────────────────────────────────────

  Widget _resultatContent(PhysioResultatModel r) {
    final hasRom = [r.antepulsionFinal, r.extensionFinal, r.abductionFinal,
      r.adductionFinal, r.rotationExterneFinal, r.rotationInterneFinal].any((v) => v != null);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (r.evaFinal != null) ...[
        _label('EVA finale'),
        const SizedBox(height: 6),
        _evaBar(r.evaFinal!),
        const SizedBox(height: 12),
      ],
      if (_ne(r.evolutionDouleur) || _ne(r.evolutionMobilite) || _ne(r.evolutionForce) || _ne(r.evolutionFonction)) ...[
        _sectionLabel('Évolution'),
        if (_ne(r.evolutionDouleur)) _row('Douleur', _evolutionLabel(r.evolutionDouleur!)),
        if (_ne(r.evolutionMobilite)) _row('Mobilité', _evolutionLabel(r.evolutionMobilite!)),
        if (_ne(r.evolutionForce)) _row('Force', _evolutionLabel(r.evolutionForce!)),
        if (_ne(r.evolutionFonction)) _row('Fonction', _evolutionLabel(r.evolutionFonction!)),
        _dividerLine(),
      ],
      if (hasRom) ...[
        _sectionLabel('Amplitudes finales (°)'),
        _romRow('Antépulsion', r.antepulsionFinal, null),
        _romRow('Extension', r.extensionFinal, null),
        _romRow('Abduction', r.abductionFinal, null),
        _romRow('Adduction', r.adductionFinal, null),
        _romRow('Rot. externe', r.rotationExterneFinal, null),
        _romRow('Rot. interne', r.rotationInterneFinal, null),
        _dividerLine(),
      ],
      _boolRow('Objectifs atteints', r.objectifsAtteints),
      if (_ne(r.conclusionKine)) ...[const SizedBox(height: 8), _block('Conclusion kinésithérapeute', r.conclusionKine!)],
      if (_ne(r.suitesDonnees)) _block('Suites données', r.suitesDonnees!),
    ]);
  }

  // ─── Conduite à tenir ────────────────────────────────────────────────────────

  Widget _conduiteSection(ConducteATenirModel c) {
    return _card(
      title: 'Conduite à tenir',
      icon: Icons.assignment_outlined,
      accent: _orange,
      headerBg: const Color(0xFFFFF7ED),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // Médicaments
        if (c.hasAnyMedicament) ...[
          _sectionLabel('Traitement médicamenteux'),
          if (_ne(c.antalgiques)) _row('Antalgiques', c.antalgiques!),
          if (_ne(c.antiInflammatoires)) _row('Anti-inflammatoires', c.antiInflammatoires!),
          if (_ne(c.myorelaxants)) _row('Myorelaxants', c.myorelaxants!),
          if (_ne(c.corticoides)) _row('Corticoïdes', c.corticoides!),
          if (_ne(c.autresMedicaments)) _row('Autres', c.autresMedicaments!),
          _dividerLine(),
        ],

        // Traitement local
        if (c.infiltration || c.ondesDeChoc || c.arthroDistension) ...[
          _sectionLabel('Traitement local'),
          if (c.infiltration) ...[
            _boolRow('Infiltration', true),
            if (_ne(c.infiltrationDetail))
              Padding(padding: const EdgeInsets.only(left: 28, bottom: 4),
                  child: Text(c.infiltrationDetail!, style: const TextStyle(fontSize: 12, color: _textSecondary))),
          ],
          if (c.ondesDeChoc) _boolRow('Ondes de choc', true),
          if (c.arthroDistension) _boolRow('Arthrodistension', true),
          _dividerLine(),
        ],

        // Chirurgie
        if (c.chirurgie) ...[
          _sectionLabel('Chirurgie'),
          _boolRow('Intervention chirurgicale', true),
          if (_ne(c.typeChirurgie))
            Padding(padding: const EdgeInsets.only(left: 28, bottom: 4),
                child: Text(c.typeChirurgie!, style: const TextStyle(fontSize: 12, color: _textSecondary))),
          _dividerLine(),
        ],

        // Recommandations
        if (c.reposRelatif || _ne(c.recommandations) || _ne(c.objectifs) || _ne(c.prochainRDV)) ...[
          _sectionLabel('Recommandations'),
          if (c.reposRelatif) _boolRow('Repos relatif', true),
          if (_ne(c.recommandations)) _block('Consignes', c.recommandations!),
          if (_ne(c.objectifs)) _block('Objectifs', c.objectifs!),
          if (_ne(c.prochainRDV)) _row('Prochain rendez-vous', c.prochainRDV!),
        ],
      ]),
    );
  }

  // ─── Shared card shell ───────────────────────────────────────────────────────

  Widget _card({
    required String title,
    required IconData icon,
    required Color accent,
    required Color headerBg,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _blue.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: headerBg,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: accent, size: 18),
            ),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accent)),
          ]),
        ),
        // Content
        Padding(padding: const EdgeInsets.all(16), child: child),
      ]),
    );
  }

  // ─── Sub-tab bar ─────────────────────────────────────────────────────────────

  Widget _subTabBar(List<String> tabs, int selected, void Function(int) onTap, Color activeColor) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(tabs[i], textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                        color: active ? Colors.white : _textSecondary)),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── ROM table ───────────────────────────────────────────────────────────────

  Widget _romHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: const [
        Expanded(flex: 4, child: SizedBox()),
        Expanded(flex: 2, child: Text('Actif', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _textSecondary))),
        Expanded(flex: 2, child: Text('Passif', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _textSecondary))),
      ]),
    );
  }

  Widget _romRow(String label, int? active, int? passive) {
    if (active == null && passive == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Expanded(flex: 4, child: Text(label, style: const TextStyle(fontSize: 12, color: _textPrimary))),
        Expanded(flex: 2, child: Text(
          active != null ? '$active°' : '—',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _blue),
        )),
        Expanded(flex: 2, child: Text(
          passive != null ? '$passive°' : '—',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _blue.withValues(alpha: 0.6)),
        )),
      ]),
    );
  }

  // ─── Tests spécifiques table ─────────────────────────────────────────────────

  Widget _testsSpecifiquesTable(BilanKinesitherapiqueModel b) {
    final tests = [
      ('Jobe', b.testJobe),
      ('Patte', b.testPatte),
      ('Gerber', b.testGerber),
      ('Neer', b.testNeer),
      ('Hawkins', b.testHawkins),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tests.where((t) => t.$2 != null).map((t) {
        final pos = t.$2 == true;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: pos ? Colors.red.withValues(alpha: 0.08) : _green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: pos ? Colors.red.withValues(alpha: 0.3) : _green.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(pos ? Icons.add : Icons.remove, size: 12, color: pos ? Colors.red : _green),
            const SizedBox(width: 4),
            Text(t.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: pos ? Colors.red : _green)),
          ]),
        );
      }).toList(),
    );
  }

  // ─── Bilan fonctionnel table ──────────────────────────────────────────────────

  Widget _bilanFonctionnelTable(BilanKinesitherapiqueModel b) {
    final tests = [
      ('Main → Bouche', b.mainBoucheTest),
      ('Main → Tête', b.mainTeteTest),
      ('Main → Nuque', b.mainNuqueTest),
      ('Main → Dos', b.mainDosTest),
    ];
    return Column(
      children: tests.where((t) => t.$2 != null).map((t) {
        final val = t.$2!;
        final color = val == 'effectue' ? _green : val == 'difficulte' ? _orange : Colors.red;
        final label = val == 'effectue' ? 'Effectué' : val == 'difficulte' ? 'Avec difficulté' : 'Impossible';
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Expanded(child: Text(t.$1, style: const TextStyle(fontSize: 12, color: _textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
            ),
          ]),
        );
      }).toList(),
    );
  }

  // ─── Muscle testing grid ─────────────────────────────────────────────────────

  Widget _muscleTestingGrid(BilanKinesitherapiqueModel b) {
    final muscles = [
      ('Deltoïde', b.deltoideTesting),
      ('Supra-épineux', b.supraEpineuxTesting),
      ('Infra-épineux', b.infraEpineuxTesting),
      ('Subscapulaire', b.subscapulaireTesting),
      ('Grand pectoral', b.grandPectoralTesting),
      ('Grand dorsal', b.grandDorsalTesting),
      ('Trap. supérieur', b.trapSuperieurTesting),
      ('Trap. moyen', b.trapMoyenTesting),
      ('Trap. inférieur', b.trapInferieurTesting),
      ('Dentelé ant.', b.denteleAntTesting),
      ('Long biceps', b.longBicepsTesting),
      ('Triceps long', b.tricepsLongTesting),
    ].where((e) => e.$2 != null).toList();

    if (muscles.isEmpty) return const SizedBox.shrink();

    return Column(
      children: muscles.map((m) {
        final grade = m.$2!;
        final color = grade >= 4 ? _green : grade >= 3 ? _orange : Colors.red;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(children: [
            Expanded(child: Text(m.$1, style: const TextStyle(fontSize: 12, color: _textPrimary))),
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text('$grade / 5', textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ),
          ]),
        );
      }).toList(),
    );
  }

  // ─── Common primitives ────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(text.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1, color: _textSecondary)),
    );
  }

  Widget _label(String text) {
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textSecondary));
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 12, color: _textSecondary, fontWeight: FontWeight.w500))),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12, color: _textPrimary, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _block(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (label.isNotEmpty)
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textSecondary, letterSpacing: 0.2)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _divider),
          ),
          child: Text(value, style: const TextStyle(fontSize: 13, color: _textPrimary, height: 1.4)),
        ),
      ]),
    );
  }

  Widget _boolRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: value ? _green.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(value ? Icons.check : Icons.close, size: 13, color: value ? _green : Colors.grey),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: _textPrimary, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _chip(String label, Color text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text)),
    );
  }

  Widget _chipsWrap(List<String> items, Color text, Color bg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items.map((t) => _chip(t, text, bg)).toList(),
      ),
    );
  }

  Widget _dividerLine() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(color: _divider, height: 1),
    );
  }

  Widget _evaBar(num eva) {
    final clamped = eva.clamp(0, 10).toDouble();
    final Color color = clamped <= 3 ? _green : clamped <= 6 ? _orange : Colors.red;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: clamped / 10,
          backgroundColor: const Color(0xFFE2E8F0),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
        ),
      ),
      const SizedBox(height: 4),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('0', style: TextStyle(fontSize: 10, color: _textSecondary)),
        Text('${eva.toStringAsFixed(eva.truncateToDouble() == eva ? 0 : 1)} / 10',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        const Text('10', style: TextStyle(fontSize: 10, color: _textSecondary)),
      ]),
    ]);
  }

  Widget _noData(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(msg, style: const TextStyle(fontSize: 13, color: _textSecondary)),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: _blue.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: const Column(children: [
        Icon(Icons.info_outline, color: _textSecondary, size: 40),
        SizedBox(height: 12),
        Text('Aucune information disponible pour cette session.',
            style: TextStyle(fontSize: 13, color: _textSecondary), textAlign: TextAlign.center),
      ]),
    );
  }

  // ─── Value translators ────────────────────────────────────────────────────────

  static bool _ne(String? v) => v != null && v.trim().isNotEmpty;

  Color _severityColor(String s) {
    switch (s.toLowerCase()) {
      case 'light': return _green;
      case 'severe': return Colors.red;
      default: return _orange;
    }
  }

  String _severityLabel(String s) {
    switch (s.toLowerCase()) {
      case 'light': return 'Légère';
      case 'severe': return 'Sévère';
      default: return 'Modérée';
    }
  }

  ({String label, Color color}) _typeEpauleInfo(String t) {
    switch (t) {
      case 'hyperalgique': return (label: 'Hyperalgique', color: _orange);
      case 'pseudo_paralytique': return (label: 'Pseudo-paralytique', color: Colors.red);
      case 'bloquee': return (label: 'Épaule bloquée', color: const Color(0xFF7C3AED));
      default: return (label: 'Douloureuse simple', color: _blue);
    }
  }

  String _douleurLabel(String t) {
    switch (t) {
      case 'mecanique': return 'Mécanique';
      case 'inflammatoire': return 'Inflammatoire';
      case 'mixte': return 'Mixte';
      case 'neuropathique': return 'Neuropathique';
      default: return t;
    }
  }

  String _debutLabel(String t) {
    switch (t) {
      case 'progressif': return 'Progressif';
      case 'brutal': return 'Brutal';
      case 'traumatique': return 'Traumatique';
      default: return t;
    }
  }

  String _finDeCourseLabel(String t) {
    switch (t) {
      case 'souple': return 'Souple';
      case 'dure': return 'Dure';
      case 'elastique': return 'Élastique';
      default: return t;
    }
  }

  String _evolutionLabel(String t) {
    switch (t) {
      case 'ameliore': return 'Amélioré';
      case 'stable': return 'Stable';
      case 'aggrave': return 'Aggravé';
      default: return t;
    }
  }
}
