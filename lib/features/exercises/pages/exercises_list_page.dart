import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sahtek/features/exercises/controller/patient_exercises_controller.dart';
import 'package:sahtek/models/patient_assignment_model.dart';
import 'package:sahtek/services/exercise_socket_service.dart';

// ── Brand colours ─────────────────────────────────────────────────────────────
const _kBlue = Color(0xFF0052FF);
const _kBg = Color(0xFFF8FAFF);
const _kTextPrimary = Color(0xFF0A0F1E);
const _kTextSecondary = Color(0xFF64748B);
const _kSuccess = Color(0xFF10B981);
const _kWarning = Color(0xFFF59E0B);
const _kCompletedBg = Color(0xFFECFDF5);

// ── Category → icon / label maps ─────────────────────────────────────────────
const _kCategoryIcons = <String, IconData>{
  'NECK': Iconsax.personalcard,
  'LEFT_SHOULDER': Iconsax.activity,
  'RIGHT_SHOULDER': Iconsax.activity,
  'BACK': Iconsax.activity,
  'LEFT_ELBOW': Iconsax.activity,
  'RIGHT_ELBOW': Iconsax.activity,
  'RIGHT_CHEST': Iconsax.heart,
  'LEFT_CHEST': Iconsax.heart,
  'RIGHT_WRIST': Iconsax.activity,
  'LEFT_WRIST': Iconsax.activity,
  'LEFT_HIP': Iconsax.activity,
  'RIGHT_HIP': Iconsax.activity,
  'LEFT_KNEE': Iconsax.activity,
  'RIGHT_KNEE': Iconsax.activity,
  'RIGHT_FOOT': Iconsax.activity,
  'LEFT_FOOT': Iconsax.activity,
};

const _kCategoryLabels = <String, String>{
  'NECK': 'Cou',
  'LEFT_SHOULDER': 'Épaule gauche',
  'RIGHT_SHOULDER': 'Épaule droite',
  'BACK': 'Dos',
  'LEFT_ELBOW': 'Coude gauche',
  'RIGHT_ELBOW': 'Coude droit',
  'RIGHT_CHEST': 'Poitrine droite',
  'LEFT_CHEST': 'Poitrine gauche',
  'RIGHT_WRIST': 'Poignet droit',
  'LEFT_WRIST': 'Poignet gauche',
  'LEFT_HIP': 'Hanche gauche',
  'RIGHT_HIP': 'Hanche droite',
  'LEFT_KNEE': 'Genou gauche',
  'RIGHT_KNEE': 'Genou droit',
  'RIGHT_FOOT': 'Pied droit',
  'LEFT_FOOT': 'Pied gauche',
};

// ── Page ──────────────────────────────────────────────────────────────────────

class ExercisesListPage extends StatefulWidget {
  const ExercisesListPage({super.key});

  @override
  State<ExercisesListPage> createState() => _ExercisesListPageState();
}

class _ExercisesListPageState extends State<ExercisesListPage> {
  final Set<String> _expanded = {};
  OverlayEntry? _bannerEntry;
  StreamSubscription<Map<String, dynamic>>? _socketSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientExercisesController>().loadAssignments(force: true);
      _subscribeSocket();
    });
  }

  void _subscribeSocket() {
    _socketSub = ExerciseSocketService.instance.exerciseAssignedStream.listen((
      payload,
    ) {
      if (!mounted) return;
      final doctorName = payload['doctorName']?.toString() ?? 'Votre médecin';
      final exerciseName = payload['exerciseName']?.toString() ?? 'un exercice';
      _showBanner('Dr. $doctorName vous a assigné un exercice : $exerciseName');
    });
  }

  void _showBanner(String message) {
    _bannerEntry?.remove();
    _bannerEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _kBlue,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Iconsax.activity, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_bannerEntry!);
    Future.delayed(const Duration(seconds: 4), () {
      _bannerEntry?.remove();
      _bannerEntry = null;
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    _bannerEntry?.remove();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: _kTextPrimary),
        title: const Text(
          'Mes Exercices',
          style: TextStyle(
            color: _kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter, color: _kTextPrimary),
            tooltip: 'Filtrer',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<PatientExercisesController>(
        builder: (context, ctrl, _) {
          if (ctrl.isLoading && !ctrl.isFetched) {
            return const _SkeletonList();
          }
          if (ctrl.error != null && !ctrl.isFetched) {
            return _ErrorState(
              error: ctrl.error!,
              onRetry: () => ctrl.loadAssignments(force: true),
            );
          }
          return RefreshIndicator(
            color: _kBlue,
            onRefresh: () => ctrl.loadAssignments(force: true),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _ProgressCard(ctrl: ctrl),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                if (ctrl.filteredAssignments.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((_, i) {
                        final a = ctrl.filteredAssignments[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ExerciseCard(
                            assignment: a,
                            isExpanded: _expanded.contains(a.assignmentId),
                            onToggle: () => setState(() {
                              if (_expanded.contains(a.assignmentId)) {
                                _expanded.remove(a.assignmentId);
                              } else {
                                _expanded.add(a.assignmentId);
                              }
                            }),
                            onMarkComplete: () => _confirmMarkComplete(ctrl, a),
                          ),
                        );
                      }, childCount: ctrl.filteredAssignments.length),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Filter bottom sheet ────────────────────────────────────────────────────

  void _showFilterSheet() {
    final ctrl = context.read<PatientExercisesController>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer par statut',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...ExerciseFilter.values.map((filter) {
                const labels = {
                  ExerciseFilter.all: 'Tous les exercices',
                  ExerciseFilter.todo: 'À faire',
                  ExerciseFilter.done: 'Complétés',
                };
                return RadioListTile<ExerciseFilter>(
                  value: filter,
                  groupValue: ctrl.activeFilter,
                  title: Text(labels[filter]!),
                  activeColor: _kBlue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) {
                    if (v != null) {
                      ctrl.setFilter(v);
                      Navigator.pop(sheetCtx);
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mark complete confirmation ─────────────────────────────────────────────

  Future<void> _confirmMarkComplete(
    PatientExercisesController ctrl,
    PatientAssignment assignment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Exercice terminé ?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Confirmez-vous avoir effectué cet exercice ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: _kTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await ctrl.markCompleted(assignment.assignmentId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Exercice marqué comme terminé !'),
          backgroundColor: _kSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (ctrl.completedCount == ctrl.totalCount && ctrl.totalCount > 0) {
        _showCelebrationDialog();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la mise à jour, réessayez.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Iconsax.award, color: _kWarning, size: 30),
            SizedBox(width: 10),
            Text(
              'Félicitations !',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Bravo ! Vous avez complété tous vos exercices du programme. Continuez sur cette lancée !',
          style: TextStyle(color: _kTextSecondary, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Super !'),
          ),
        ],
      ),
    );
  }
}

// ── Progress header card ───────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final PatientExercisesController ctrl;

  const _ProgressCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final completed = ctrl.completedCount;
    final total = ctrl.totalCount;
    final allDone = total > 0 && completed == total;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: allDone
              ? [const Color(0xFF10B981), const Color(0xFF059669)]
              : [_kBlue, const Color(0xFF003FCC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (allDone ? _kSuccess : _kBlue).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allDone ? Iconsax.award : Iconsax.activity,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                allDone
                    ? 'Bravo, tout est complété !'
                    : 'Continuez vos efforts !',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$completed complétés sur $total exercices',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise card ──────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final PatientAssignment assignment;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onMarkComplete;

  const _ExerciseCard({
    required this.assignment,
    required this.isExpanded,
    required this.onToggle,
    required this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    final ex = assignment.exercise;
    final cat = (ex.category ?? '').toUpperCase();
    final icon = _kCategoryIcons[cat] ?? Iconsax.activity;
    final catLabel = _kCategoryLabels[cat] ?? cat;
    final done = assignment.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: done ? _kCompletedBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: done
            ? const Border(left: BorderSide(color: _kSuccess, width: 4))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Opacity(
        opacity: done ? 0.88 : 1.0,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(icon, catLabel, done),
                if (done && assignment.completedAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Complété le ${DateFormat('dd/MM/yyyy').format(assignment.completedAt!)}',
                    style: const TextStyle(
                      color: _kSuccess,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (isExpanded) _buildExpandedContent(context, done),
                const SizedBox(height: 6),
                Center(
                  child: Icon(
                    isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    size: 16,
                    color: _kTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(IconData icon, String catLabel, bool done) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: done ? _kSuccess.withOpacity(0.1) : _kBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: done ? _kSuccess : _kBlue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                assignment.exercise.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _kTextPrimary,
                ),
              ),
              if (catLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: done
                        ? _kSuccess.withOpacity(0.12)
                        : _kBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    catLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: done ? _kSuccess : _kBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: done ? _kSuccess.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
            border: done
                ? null
                : Border.all(color: _kBlue.withOpacity(0.35), width: 1.5),
          ),
          child: Icon(
            done ? Iconsax.tick_circle : Iconsax.activity,
            color: done ? _kSuccess : _kBlue,
            size: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(BuildContext context, bool done) {
    final ex = assignment.exercise;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),
        const SizedBox(height: 16),

        // Description
        if (ex.description != null && ex.description!.isNotEmpty) ...[
          Text(
            ex.description!,
            style: const TextStyle(
              color: _kTextSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Video button
        if (ex.videoUrl != null && ex.videoUrl!.isNotEmpty) ...[
          OutlinedButton.icon(
            onPressed: () => _launchUrl(ex.videoUrl!),
            icon: const Icon(Iconsax.video_play, size: 17),
            label: const Text('Voir la vidéo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kBlue,
              side: const BorderSide(color: _kBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Training parameters
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              icon: Iconsax.repeat,
              label: '${assignment.repetitions} répétitions',
            ),
            _InfoChip(
              icon: Iconsax.hierarchy_3,
              label: '${assignment.series} séries',
            ),
            _InfoChip(
              icon: Iconsax.clock,
              label: '${assignment.seancesParJour} séances/jour',
            ),
            if (assignment.frequence != null &&
                assignment.frequence!.isNotEmpty)
              _InfoChip(icon: Iconsax.calendar_1, label: assignment.frequence!),
          ],
        ),

        // Pain instructions
        if (assignment.consignesDouleur != null &&
            assignment.consignesDouleur!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kWarning.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kWarning.withOpacity(0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.warning_2, color: _kWarning, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assignment.consignesDouleur!,
                    style: const TextStyle(
                      color: _kTextPrimary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Notes
        if (assignment.notes != null && assignment.notes!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBlue.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.info_circle, color: _kBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    assignment.notes!,
                    style: const TextStyle(
                      color: _kTextPrimary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Mark complete button (only when not done)
        if (!done) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kBlue, Color(0xFF003FCC)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                onPressed: onMarkComplete,
                icon: const Icon(
                  Iconsax.tick_circle,
                  color: Colors.white,
                  size: 18,
                ),
                label: const Text(
                  'Marquer comme terminé',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Small reusable widgets ─────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _kTextSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _kTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Iconsax.activity, size: 64, color: Color(0xFFCBD5E1)),
            SizedBox(height: 16),
            Text(
              'Aucun exercice assigné',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _kTextPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Votre kinésithérapeute vous assignera des exercices bientôt',
              style: TextStyle(color: _kTextSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, size: 48, color: _kWarning),
            const SizedBox(height: 16),
            const Text(
              'Impossible de charger les exercices',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: _kTextSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton loading ──────────────────────────────────────────────────────────

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const _SkeletonBox(height: 110, radius: 20),
          const SizedBox(height: 16),
          const _SkeletonBox(height: 100, radius: 16),
          const SizedBox(height: 12),
          const _SkeletonBox(height: 100, radius: 16),
          const SizedBox(height: 12),
          const _SkeletonBox(height: 100, radius: 16),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatefulWidget {
  final double height;
  final double radius;

  const _SkeletonBox({required this.height, required this.radius});

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}
