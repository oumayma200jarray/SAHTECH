import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/ia_tracking_model.dart';
import 'package:intl/intl.dart';

class ResultatsTestIAPage extends StatelessWidget {
  const ResultatsTestIAPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final lastResult = provider.lastTrackingResult;
    if (lastResult == null) {
      return Scaffold(body: Center(child: Text('no_content_available'.tr())));
    }

    final String patientName = provider.profile.fullName.isNotEmpty
        ? provider.profile.fullName
        : "Patient";

    // --- DATA EXTRACTION ---
    final List<Map<String, dynamic>> movements = [
      {'id': 'flexion', 'name': 'Flexion Antérieure', 'max': 180.0, 'unit': '°'},
      {'id': 'abduction', 'name': 'Abduction', 'max': 180.0, 'unit': '°'},
      {'id': 'rotation_externe', 'name': 'Rotation Externe', 'max': 70.0, 'unit': '°'},
      {'id': 'extension', 'name': 'Extension', 'max': 50.0, 'unit': '°'},
      {'id': 'adduction', 'name': 'Adduction', 'max': 30.0, 'unit': '°'},
      {'id': 'rotation_interne', 'name': 'Rotation Interne', 'max': 30.0, 'unit': '°'},
    ];

    final List<Map<String, dynamic>> analysisData = movements.map((m) {
      final gauche = (provider.getValueForSide(m['id'], healthy: true) ?? 0.0).toDouble(); // healthy:true = Gauche
      final droite = (provider.getValueForSide(m['id'], healthy: false) ?? 0.0).toDouble(); // healthy:false = Droite
      
      // Le ROM (Range of Motion) est l'angle le plus grand (max) entre les deux épaules testées.
      // Le déficit représente l'angle le plus faible (min) entre les deux.
      double romVal = 0.0;
      double deficitVal = 0.0;
      if (gauche > 0 || droite > 0) {
        romVal = (gauche > droite) ? gauche : droite;
        deficitVal = (gauche > 0 && droite > 0) 
            ? ((gauche < droite) ? gauche : droite) 
            : (gauche > 0 ? gauche : droite);
      }
      
      // Récupérer la valeur de la séance PRÉCÉDENTE pour ce même exercice
      final prevValue = (provider.getPreviousSessionValue('ia_shoulder_${m['id']}') ?? 
                        provider.getPreviousSessionValue('ia_${m['id']}') ??
                        provider.getPreviousSessionValue(m['id']) ?? 0.0).toDouble();
      
      // Delta = valeur actuelle - valeur précédente
      final delta = (prevValue > 0 && romVal > 0) ? (romVal - prevValue) : 0.0;
      
      return {
        ...m,
        'gauche': gauche,
        'droite': droite,
        'rom': romVal,
        'deficit': deficitVal,
        'delta': delta,
      };
    }).toList();

    // Calculate Global Score (only for performed exercises)
    double totalMobility = 0;
    int performedCount = 0;
    for (var m in analysisData) {
      final double maxVal = (m['max'] as num).toDouble();
      final double romVal = (m['rom'] as num).toDouble();
      if (maxVal > 0 && romVal > 0) {
        totalMobility += (romVal / maxVal) * 100;
        performedCount++;
      }
    }
    final double globalMobility = performedCount > 0 
        ? (totalMobility / performedCount).clamp(0.0, 100.0).toDouble() 
        : 0.0;
    final double painLevel = lastResult.painLevel ?? 0.0;
    final double recoveryScore = (globalMobility * 0.7 + (10 - painLevel) * 10 * 0.3).clamp(0.0, 100.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(lastResult, patientName),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildKinematicsCard(analysisData),
                  const SizedBox(height: 24),
                  _buildDeficitIndicator(analysisData),
                  const SizedBox(height: 24),
                  _buildQualitySection(lastResult),
                  const SizedBox(height: 32),
                  _buildSymmetryScore(analysisData),
                  const SizedBox(height: 32),
                  _buildCorrelationCard(analysisData, painLevel),
                  const SizedBox(height: 32),
                  _buildGlobalRecoveryGauge(recoveryScore, globalMobility, painLevel),
                  const SizedBox(height: 32),
                  _buildConclusionCard(globalMobility, painLevel, lastResult.avgShoulderImbalance),
                  const SizedBox(height: 40),
                  _buildNewSessionButton(context),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            backgroundImage: const AssetImage('lib/assets/images/doc_avatar.png'),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("SAHTECH", style: TextStyle(color: Color(0xFF0D54F2), fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
        ],
      ),
     
    );
  }

  Widget _buildHeader(IATrackingData result, String patientName) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          const Text("Résultat de\nl'Analyse IA", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), height: 1.1)),
          const SizedBox(height: 12),
          Text("Analyse biomécanique avancée et corrélation neurale pour la rééducation de l'épaule.\nPatient : $patientName", style: TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFF0D54F2).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF0D54F2), size: 8),
                    SizedBox(width: 8),
                    Text("Analyse en Direct 100%", style: TextStyle(color: Color(0xFF0D54F2), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKinematicsCard(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("MOTEUR D'ANALYSE D'AMPLITUDE™", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  SizedBox(height: 4),
                  Text("Cinématique\nArticulaire", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                ],
              ),
              _buildSmallBadge("V4.3", "SEM-1"),
            ],
          ),
          const SizedBox(height: 32),
          ...data.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildClinicalProgressBar(
              m['name'].toString(), 
              (m['rom'] as num).toDouble(), 
              (m['max'] as num).toDouble(), 
              (m['delta'] as num).toDouble(),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildClinicalProgressBar(String label, double val, double max, double delta) {
    final bool isPositive = delta >= 0;
    final double progress = (val / max).clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
            Text(
              "${val.toInt()}°  ${isPositive ? '+' : ''}${delta.toInt()}°", 
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isPositive ? const Color(0xFF0D54F2) : const Color(0xFFEF4444)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(height: 6, width: constraints.maxWidth, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(3))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  height: 6,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0D54F2), Color(0xFF3B82F6)]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDeficitIndicator(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF1F5FF), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.analytics_outlined, color: Color(0xFF0D54F2), size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text("Cartographie des Déficits (6 Mouvements)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.map((m) {
            final String name = m['name'].toString();
            final double gauche = (m['gauche'] as num).toDouble();
            final double droite = (m['droite'] as num).toDouble();
            final double rom = (m['rom'] as num).toDouble();
            final double max = (m['max'] as num).toDouble();
            
            final double deficit = max - rom;
            
            String statusText = "";
            Color statusColor = const Color(0xFF10B981);
            
            if (gauche == 0 && droite == 0) {
              statusText = "Non évalué";
              statusColor = Colors.grey;
            } else if (deficit > 15.0) {
              statusText = "Déficit important : -${deficit.toInt()}° [Actuel : ${rom.toInt()}°]";
              statusColor = const Color(0xFFEF4444);
            } else if (deficit > 5.0) {
              statusText = "Déficit léger : -${deficit.toInt()}° [Actuel : ${rom.toInt()}°]";
              statusColor = const Color(0xFFF59E0B);
            } else {
              statusText = "Mobilité normale [Actuel : ${rom.toInt()}°]";
              statusColor = const Color(0xFF10B981);
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.circle, size: 8, color: statusColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                        children: [
                          TextSpan(text: "$name : ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          TextSpan(text: statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }



  Widget _buildQualitySection(IATrackingData result) {
    // ── Contrôle Moteur (Stabilité et fluidité)
    final String motorStatus;
    final Color motorColor;
    final String motorSub;
    if (result.precision >= 0.85) {
      motorStatus = "EXCELLENT";
      motorColor = const Color(0xFF10B981);
      motorSub = "Exécution fluide et trajectoire parfaitement maîtrisée. Précision motrice de ${(result.precision * 100).toInt()}%.";
    } else if (result.precision >= 0.65) {
      motorStatus = "BON";
      motorColor = const Color(0xFF10B981);
      motorSub = "Contrôle satisfaisant avec de légères irrégularités (Précision: ${(result.precision * 100).toInt()}%).";
    } else {
      motorStatus = "INSTABLE";
      motorColor = const Color(0xFFEF4444);
      motorSub = "Mouvement saccadé ou instable. Le coude a fléchi à ${result.minElbowFlexion.toInt()}° (norme > 160°). Un travail de stabilité neuromusculaire est requis.";
    }

    // ── Compensations (Triche articulaire)
    final bool hasCompensation = result.avgTrunkLean.abs() > 8.0;
    final String compSub = hasCompensation
        ? "Triche biomécanique : Inclinaison du tronc de ${result.avgTrunkLean.toStringAsFixed(1)}° (norme < 8°) pour compenser le manque d'amplitude de l'épaule."
        : "Excellente posture axiale. Aucune compensation significative observée durant l'effort.";
    final String compStatus = hasCompensation ? "COMPENSÉ" : "NORMAL";
    final Color compColor = hasCompensation ? const Color(0xFFF59E0B) : const Color(0xFF10B981);

    // ── Pathologies Dynamiques (Dyskinesie Scapulaire)
    final bool hasDyskinesia = result.avgShoulderImbalance > 12.0;
    final String dysSub = hasDyskinesia
        ? "Déséquilibre scapulaire sévère (Asymétrie de ${result.avgShoulderImbalance.toStringAsFixed(1)}%). Signe probable de Dyskinésie nécessitant un travail de recentrage articulaire."
        : "Rythme scapulo-huméral respecté. Symétrie scapulaire dynamique dans les normes (${result.avgShoulderImbalance.toStringAsFixed(1)}%).";
    final String dysStatus = hasDyskinesia ? "DÉPISTÉ" : "NORMAL";
    final Color dysColor = hasDyskinesia ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("ANALYSE DE LA QUALITÉ DU MOUVEMENT™", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 16),
        _buildQualityCard("Contrôle Moteur", motorSub, motorStatus, motorColor),
        const SizedBox(height: 12),
        _buildQualityCard("Compensations", compSub, compStatus, compColor),
        const SizedBox(height: 12),
        _buildQualityCard("Dyskinesie Scapulaire", dysSub, dysStatus, dysColor),
      ],
    );
  }

  Widget _buildQualityCard(String title, String sub, String status, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.check_circle_outline, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ]),
          ),
          Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }

  Widget _buildSymmetryScore(List<Map<String, dynamic>> data) {
    final testedData = data.where((m) => (m['rom'] as num) > 0).toList();
    if (testedData.isEmpty) return const SizedBox.shrink();
    // Average gauche vs droite
    double avgGauche = 0;
    double avgDroite = 0;
    for (var m in testedData) {
      avgGauche += m['gauche'];
      avgDroite += m['droite'];
    }
    avgGauche /= testedData.length;
    avgDroite /= testedData.length;
    
    // On calcule la symétrie absolue (le plus faible par rapport au plus fort)
    final double maxVal = (avgGauche > avgDroite) ? avgGauche : avgDroite;
    final double minVal = (avgGauche < avgDroite) ? avgGauche : avgDroite;
    final int score = maxVal > 0 ? (minVal / maxVal * 100).clamp(0, 100).toInt() : 0;
    
    // Barres : on normalise par rapport à la valeur max globale
    final double leftRatio = maxVal > 0 ? (avgGauche / maxVal) : 0.0;
    final double rightRatio = maxVal > 0 ? (avgDroite / maxVal) : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          const Text("SCORE DE SYMÉTRIE DE L'ÉPAULE™", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSymmetryBar("GAUCHE", leftRatio),
              _buildSymmetryBar("DROITE", rightRatio),
            ],
          ),
          const SizedBox(height: 32),
          Text("$score%", style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
          const Text("Indice de Symétrie Dynamique", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSymmetryBar(String label, double ratio) {
    return Column(
      children: [
        Container(
          width: 90, 
          height: 140 * ratio.clamp(0.1, 1.0), 
          decoration: BoxDecoration(
            color: const Color(0xFF0D54F2), 
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: const Color(0xFF0D54F2).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
          )
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8))),
      ],
    );
  }

  Widget _buildCorrelationCard(List<Map<String, dynamic>> data, double pain) {
    if (data.isEmpty) return const SizedBox.shrink();
    final flexion = data.firstWhere((element) => element['id'] == 'flexion', orElse: () => data.first);
    final double gain = (flexion['delta'] as num).toDouble();
    final String exerciseName = flexion['name'].toString();
    final double flexionRom = (flexion['rom'] as num).toDouble();

    // Génère un titre et un texte analytique basés sur les vraies données
    final bool improving = gain > 0;
    final bool hasPain = pain > 2.0;
    final String correlationTitle = improving
        ? "Amélioration de la mobilité avec diminution de la douleur"
        : "Maintien de l'amplitude — travail de consolidation";
    final String correlationBody = gain != 0
        ? "L'analyse croisée indique un ${improving ? 'gain' : 'déficit'} de ${gain.abs().toInt()}° en $exerciseName "
          "(amplitude actuelle : ${flexionRom.toInt()}°). "
          "${hasPain ? 'La douleur rapportée (${pain.toStringAsFixed(1)}/10) indique une sensibilisation périphérique résiduelle. Un travail de désensibilisation progressive est recommandé.' 
          : 'Absence de douleur significative (${pain.toStringAsFixed(1)}/10) — tolérance tissulaire satisfaisante. Progression vers des amplitudes plus élevées possible.'}"
        : "Première séance enregistrée. Les prochaines sessions permettront de calculer votre courbe de progression personnalisée.";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF0D54F2), Color(0xFF1E40AF)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: const Color(0xFF0D54F2).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CORRÉLATION DOULEUR +\nMOUVEMENT™", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          Text(correlationTitle, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
          const SizedBox(height: 24),
          Text(
            correlationBody,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 32),
          _buildWorkloadChart(),
        ],
      ),
    );
  }

  Widget _buildWorkloadChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Charge de travail", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                Text("1.5", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.normal)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text("+18%", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                Text("(Optimum)", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.normal)),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _miniBar(0.3), _miniBar(0.4), _miniBar(0.6), _miniBar(0.8), _miniBar(1.0, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          const Text("PROJECTION RÉCUPÉRATION : 22 JOURS", style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _miniBar(double h, {Color color = Colors.white54}) => Container(width: 25, height: 40 * h, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)));

  Widget _buildGlobalRecoveryGauge(double score, double mobility, double pain) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
      child: Column(
        children: [
          const Text("SCORE DE RÉCUPÉRATION SAHTECH™", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 180, height: 180, child: CircularProgressIndicator(value: score / 100, strokeWidth: 12, backgroundColor: const Color(0xFFF1F5F9), valueColor: const AlwaysStoppedAnimation(Color(0xFF0D54F2)))),
              Column(
                children: [
                  Text("${score.toInt()}", style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  const Text("/ 100", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _metricSummary("MOBILITÉ GLOBALE", "${mobility.toInt()}%"),
              _metricSummary("SCORE DE DOULEUR", "${(pain * 10).toInt()}%", color: const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricSummary(String label, String val, {Color color = const Color(0xFF1E293B)}) {
    return Column(children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
      const SizedBox(height: 4),
      Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
    ]);
  }

  Widget _buildSmallBadge(String val, String sub) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: Color(0xFFDBEAFE), shape: BoxShape.circle),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0D54F2))),
          Text(sub, style: const TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Color(0xFF0D54F2))),
        ],
      ),
    );
  }

  Widget _buildConclusionCard(double mobility, double pain, double imbalance) {
    String diag = "";
    String spec = "";

    if (mobility < 50 && pain > 5) {
      diag = "Suspicion de Capsulite Rétractile (Épaule gelée) ou lésion sévère de la coiffe des rotateurs.";
      spec = "Chirurgien Orthopédiste ou Rhumatologue";
    } else if (imbalance > 12.0) {
      diag = "Dyskinésie Scapulaire avérée avec potentielle instabilité articulaire périphérique.";
      spec = "Kinésithérapeute (Spécialisé en Biomécanique)";
    } else if (mobility < 80 && pain > 3) {
      diag = "Suspicion de Tendinopathie (coiffe des rotateurs) ou conflit sous-acromial modéré.";
      spec = "Médecin du Sport ou Kinésithérapeute";
    } else if (pain > 5) {
      diag = "Douleur aiguë sans blocage articulaire majeur. Possible inflammation ou bursite.";
      spec = "Médecin Généraliste ou Rhumatologue";
    } else {
      diag = "Mobilité fonctionnelle globale conservée. Possible déficit de contrôle moteur ou tension musculaire bénigne.";
      spec = "Kinésithérapeute (Renforcement) ou Ostéopathe";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF0D54F2).withOpacity(0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Color(0xFF0D54F2), shape: BoxShape.circle),
                child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text("CONCLUSION & ORIENTATION", style: TextStyle(color: Color(0xFF0D54F2), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Diagnostic IA Possible", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(diag, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
          const SizedBox(height: 24),
          Container(height: 1, color: const Color(0xFF0D54F2).withOpacity(0.1)),
          const SizedBox(height: 24),
          const Text("Spécialité Recommandée", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0D54F2), size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(spec, style: const TextStyle(color: Color(0xFF0D54F2), fontSize: 14, fontWeight: FontWeight.w900))),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "* L'analyse SAHTECH est fournie à titre indicatif et ne remplace en aucun cas un diagnostic médical officiel effectué par un professionnel de la santé.",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildNewSessionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<GlobalDataProvider>(context, listen: false).resetCurrentSession();
          Navigator.pushNamedAndRemoveUntil(context, '/selection_test_ia', (route) => false);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D54F2), 
          padding: const EdgeInsets.symmetric(vertical: 20), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: const Color(0xFF0D54F2).withOpacity(0.3),
        ),
        child: const Text("REDÉMARRER UNE SÉANCE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
      ),
    );
  }
}
