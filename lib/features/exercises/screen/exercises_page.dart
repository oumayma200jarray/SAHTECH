import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sahtek/core/widgets/specialist_bottom_nav_bar.dart';
import 'package:sahtek/features/exercises/controller/exercises_controller.dart';
import 'package:sahtek/models/exercise_model.dart';

// ── Category / side enum labels ───────────────────────────────────────────────

const _categoryLabels = {
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

const _sideLabels = {'BACK': 'Dos', 'FRONT': 'Face'};

const _primaryBlue = Color(0xFF0D54F2);
const _cardBg = Colors.white;

// ── Main page ─────────────────────────────────────────────────────────────────

class ExercisesPage extends StatefulWidget {
  const ExercisesPage({super.key});

  @override
  State<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends State<ExercisesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Search tab filters
  final _searchController = TextEditingController();
  String _filterCategory = '';
  String _filterSide = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        context.read<ExercisesController>().loadPublicExercises();
      }
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExercisesController>().loadMyExercises();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openAddEdit([ExerciseModel? exercise]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AddEditDialog(existing: exercise),
    );
  }

  void _openDelete(ExerciseModel exercise) {
    showDialog(
      context: context,
      builder: (_) => _DeleteDialog(exercise: exercise),
    );
  }

  void _openAssign(ExerciseModel exercise) {
    context.read<ExercisesController>().loadPatients();
    showDialog(
      context: context,
      builder: (_) => _AssignDialog(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ExercisesController>();

    // Filtered public exercises
    final filtered = ctrl.publicExercises.where((ex) {
      final q = _searchController.text.toLowerCase();
      final matchName = q.isEmpty || (ex.name.toLowerCase().contains(q));
      final cats = ex.category.map((c) => c.toUpperCase()).toList();
      final sides = ex.side.map((s) => s.toUpperCase()).toList();
      final matchCat =
          _filterCategory.isEmpty ||
          cats.contains(_filterCategory.toUpperCase());
      final matchSide =
          _filterSide.isEmpty || sides.contains(_filterSide.toUpperCase());
      return matchName && matchCat && matchSide;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: _cardBg,
        elevation: 0,
        surfaceTintColor: _cardBg,
        title: Text(
          'exercises_page_title'.tr(),
          style: const TextStyle(
            color: Color(0xFF0A0F1E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: _cardBg,
            child: TabBar(
              controller: _tabController,
              indicatorColor: _primaryBlue,
              labelColor: _primaryBlue,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: 'exercises_tab_my'.tr()),
                Tab(text: 'exercises_tab_search'.tr()),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              backgroundColor: _primaryBlue,
              onPressed: () => _openAddEdit(),
              child: const Icon(Iconsax.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: const SpecialistBottomNavBar(currentIndex: 3),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 0: My Exercises ──────────────────────────────────────────
          _buildMyTab(ctrl),

          // ── Tab 1: Search / Public ───────────────────────────────────────
          _buildSearchTab(ctrl, filtered),
        ],
      ),
    );
  }

  // ─── My Exercises tab ─────────────────────────────────────────────────────

  Widget _buildMyTab(ExercisesController ctrl) {
    if (ctrl.isLoadingMy) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.myError != null) {
      return _ErrorState(message: ctrl.myError!, onRetry: ctrl.loadMyExercises);
    }
    if (ctrl.myExercises.isEmpty) {
      return _EmptyState(
        icon: Iconsax.activity,
        title: 'exercises_empty_title'.tr(),
        subtitle: 'exercises_empty_sub'.tr(),
        actionLabel: 'exercises_add'.tr(),
        onAction: () => _openAddEdit(),
      );
    }
    return RefreshIndicator(
      onRefresh: ctrl.loadMyExercises,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.46,
        ),
        itemCount: ctrl.myExercises.length,
        itemBuilder: (_, i) {
          final ex = ctrl.myExercises[i];
          return _MyExerciseCard(
            exercise: ex,
            onAssign: () => _openAssign(ex),
            onEdit: () => _openAddEdit(ex),
            onDelete: () => _openDelete(ex),
          );
        },
      ),
    );
  }

  // ─── Search tab ───────────────────────────────────────────────────────────

  Widget _buildSearchTab(
    ExercisesController ctrl,
    List<ExerciseModel> filtered,
  ) {
    return Column(
      children: [
        // Filters bar
        Container(
          color: _cardBg,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name search
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'exercises_search_hint'.tr(),
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(Iconsax.search_normal, size: 18),
                  filled: true,
                  fillColor: const Color(0xFFF7F9FC),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Category dropdown
              DropdownButtonFormField<String>(
                value: _filterCategory.isEmpty ? null : _filterCategory,
                hint: Text(
                  'exercises_filter_all'.tr(),
                  style: const TextStyle(fontSize: 13),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF7F9FC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text('exercises_filter_all'.tr()),
                  ),
                  ..._categoryLabels.entries.map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _filterCategory = v ?? ''),
              ),
              const SizedBox(height: 10),
              // Side toggle buttons
              Row(
                children: [
                  _SideChip(
                    label: 'exercises_side_all'.tr(),
                    selected: _filterSide.isEmpty,
                    onTap: () => setState(() => _filterSide = ''),
                  ),
                  const SizedBox(width: 8),
                  ..._sideLabels.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _SideChip(
                        label: e.value,
                        selected: _filterSide == e.key,
                        onTap: () => setState(
                          () => _filterSide = _filterSide == e.key ? '' : e.key,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Active filter chips
              if (_filterCategory.isNotEmpty ||
                  _filterSide.isNotEmpty ||
                  _searchController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        _FilterChipWidget(
                          label: '"${_searchController.text}"',
                          onRemove: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                      if (_filterCategory.isNotEmpty)
                        _FilterChipWidget(
                          label: _categoryLabels[_filterCategory] ?? '',
                          onRemove: () => setState(() => _filterCategory = ''),
                        ),
                      if (_filterSide.isNotEmpty)
                        _FilterChipWidget(
                          label: _sideLabels[_filterSide] ?? '',
                          onRemove: () => setState(() => _filterSide = ''),
                        ),
                      TextButton(
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _filterCategory = '';
                          _filterSide = '';
                        }),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'exercises_clear_filters'.tr(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Results
        Expanded(child: _buildPublicResults(ctrl, filtered)),
      ],
    );
  }

  Widget _buildPublicResults(
    ExercisesController ctrl,
    List<ExerciseModel> filtered,
  ) {
    if (ctrl.isLoadingPublic) {
      return const Center(child: CircularProgressIndicator());
    }
    if (ctrl.publicError != null) {
      return _ErrorState(
        message: ctrl.publicError!,
        onRetry: () {
          ctrl.publicFetched = false;
          ctrl.loadPublicExercises();
        },
      );
    }
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.search_normal, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'exercises_no_results'.tr(),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Text(
            '${filtered.length} exercice${filtered.length > 1 ? 's' : ''} trouvé${filtered.length > 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.56,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final ex = filtered[i];
              return _PublicExerciseCard(
                exercise: ex,
                onAssign: () => _openAssign(ex),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── My Exercise Card ──────────────────────────────────────────────────────────

class _MyExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onAssign;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyExerciseCard({
    required this.exercise,
    required this.onAssign,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const maxAvatars = 4;
    final assigned = exercise.assignedTo;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail
          Stack(
            children: [
              _VideoPlaceholder(videoUrl: exercise.videoUrl),
              if (exercise.isPublic)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Public',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (exercise.side.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Row(
                    children: exercise.side.map((s) {
                      return Container(
                        margin: const EdgeInsets.only(left: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _sideLabels[s] ?? s,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0F1E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Categories
                  if (exercise.category.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: exercise.category.map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _categoryLabels[cat] ?? cat,
                            style: TextStyle(
                              fontSize: 9,
                              color: _primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    exercise.description?.isNotEmpty == true
                        ? exercise.description!
                        : 'exercises_no_description'.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      color: exercise.description?.isNotEmpty == true
                          ? Colors.grey[600]
                          : Colors.grey[400],
                      fontStyle: exercise.description?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Assigned patients
                  if (assigned.isNotEmpty) ...[
                    Text(
                      'exercises_assigned_patients'.tr(
                        args: ['${assigned.length}'],
                      ),
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 20,
                      child: Stack(
                        children: [
                          for (
                            int i = 0;
                            i < assigned.length.clamp(0, maxAvatars);
                            i++
                          )
                            Positioned(
                              left: i * 14.0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _primaryBlue.withValues(alpha: 0.15),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    assigned[i].user.fullName.isNotEmpty
                                        ? assigned[i].user.fullName[0]
                                              .toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (assigned.length > maxAvatars)
                            Positioned(
                              left: maxAvatars * 14.0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '+${assigned.length - maxAvatars}',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Assign button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onAssign,
                      style: TextButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 28),
                      ),
                      child: Text(
                        'exercises_assign'.tr(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Edit / Delete row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onEdit,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: const Size(0, 26),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'exercises_edit'.tr(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF0A0F1E),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onDelete,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: const Size(0, 26),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'exercises_delete'.tr(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Public Exercise Card ──────────────────────────────────────────────────────

class _PublicExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback onAssign;

  const _PublicExerciseCard({required this.exercise, required this.onAssign});

  @override
  Widget build(BuildContext context) {
    final specialist = exercise.specialist?.user;

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail
          if (exercise.side.isNotEmpty)
            Stack(
              children: [
                _VideoPlaceholder(videoUrl: exercise.videoUrl),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Row(
                    children: exercise.side.map((s) {
                      return Container(
                        margin: const EdgeInsets.only(left: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _sideLabels[s] ?? s,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            )
          else
            _VideoPlaceholder(videoUrl: exercise.videoUrl),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0F1E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Categories
                  if (exercise.category.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: exercise.category.map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _categoryLabels[cat] ?? cat,
                            style: TextStyle(
                              fontSize: 9,
                              color: _primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    exercise.description?.isNotEmpty == true
                        ? exercise.description!
                        : 'exercises_no_description'.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      color: exercise.description?.isNotEmpty == true
                          ? Colors.grey[600]
                          : Colors.grey[400],
                      fontStyle: exercise.description?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Specialist
                  if (specialist != null) ...[
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: _primaryBlue.withValues(alpha: 0.15),
                          child: Text(
                            specialist.fullName.isNotEmpty
                                ? specialist.fullName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            specialist.fullName,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Assign button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onAssign,
                      style: TextButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(0, 28),
                      ),
                      child: Text(
                        'exercises_assign'.tr(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Video Placeholder ─────────────────────────────────────────────────────────

class _VideoPlaceholder extends StatelessWidget {
  final String? videoUrl;
  const _VideoPlaceholder({this.videoUrl});

  static Future<void> _openVideo(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      // Try native app / browser first (YouTube, Facebook, etc.)
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        // Fallback: in-app web view (works for direct MinIO / private links)
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir la vidéo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[200]!, Colors.grey[300]!],
          ),
        ),
        child: videoUrl != null && videoUrl!.isNotEmpty
            ? InkWell(
                onTap: () => _openVideo(context, videoUrl!),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.video_play, size: 32, color: Colors.grey[500]),
                    const SizedBox(height: 4),
                    Text(
                      'exercises_watch_video'.tr(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.video_slash, size: 32, color: Colors.grey[400]),
                  const SizedBox(height: 4),
                  Text(
                    'Pas de vidéo',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Add / Edit Dialog ─────────────────────────────────────────────────────────

class _AddEditDialog extends StatefulWidget {
  final ExerciseModel? existing;
  const _AddEditDialog({this.existing});

  @override
  State<_AddEditDialog> createState() => _AddEditDialogState();
}

class _AddEditDialogState extends State<_AddEditDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  List<String> _categories = [];
  List<String> _sides = [];
  bool _isPublic = false;
  bool _videoModeUrl = true;
  File? _videoFile;
  String? _videoFileName;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _nameCtrl.text = ex.name;
      _descCtrl.text = ex.description ?? '';
      _urlCtrl.text = ex.videoUrl ?? '';
      _categories = List.from(ex.category);
      _sides = List.from(ex.side);
      _isPublic = ex.isPublic;
      _videoModeUrl = ex.videoUrl != null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _toggleCategory(String cat) {
    setState(() {
      _categories.contains(cat)
          ? _categories.remove(cat)
          : _categories.add(cat);
    });
  }

  void _toggleSide(String side) {
    setState(() {
      _sides.contains(side) ? _sides.remove(side) : _sides.add(side);
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final sizeMB = file.lengthSync() / (1024 * 1024);
      if (sizeMB > 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('exercises_file_too_large'.tr())),
          );
        }
        return;
      }
      setState(() {
        _videoFile = file;
        _videoFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _show('Le nom est obligatoire.');
      return;
    }
    if (_categories.isEmpty) {
      _show('Sélectionnez au moins une catégorie.');
      return;
    }
    if (_sides.isEmpty) {
      _show('Sélectionnez au moins un côté.');
      return;
    }
    final hasUrl = _urlCtrl.text.trim().isNotEmpty;
    final hasFile = _videoFile != null;
    if (!hasUrl && !hasFile) {
      _show('Fournissez un lien vidéo ou téléchargez un fichier.');
      return;
    }

    final ctrl = context.read<ExercisesController>();
    final ok = await ctrl.saveExercise(
      existing: widget.existing,
      name: name,
      description: _descCtrl.text.trim(),
      categories: _categories,
      sides: _sides,
      videoUrl: _urlCtrl.text.trim(),
      isPublic: _isPublic,
      videoFile: _videoFile,
    );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existing != null
                ? 'Exercice mis à jour avec succès !'
                : 'Exercice créé avec succès !',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _show('Une erreur est survenue. Réessayez.');
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ExercisesController>();
    final isEditing = widget.existing != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing
                  ? 'exercises_edit_title'.tr()
                  : 'exercises_add_title'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    _FormLabel('exercises_name_label'.tr()),
                    _FormField(
                      controller: _nameCtrl,
                      hint: 'Ex : Flexion du poignet',
                    ),

                    // Description
                    const SizedBox(height: 12),
                    _FormLabel('exercises_desc_label'.tr()),
                    _FormField(
                      controller: _descCtrl,
                      hint: 'Instructions...',
                      maxLines: 3,
                    ),

                    // Categories
                    const SizedBox(height: 12),
                    _FormLabel('exercises_category_label'.tr(), required: true),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _categoryLabels.entries.map((e) {
                        final sel = _categories.contains(e.key);
                        return GestureDetector(
                          onTap: () => _toggleCategory(e.key),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? _primaryBlue
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? _primaryBlue
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: sel ? Colors.white : Colors.grey[700],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Side
                    const SizedBox(height: 12),
                    _FormLabel('exercises_side_label'.tr(), required: true),
                    Row(
                      children: _sideLabels.entries.map((e) {
                        final sel = _sides.contains(e.key);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => _toggleSide(e.key),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: e.key == 'BACK' ? 6 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: sel
                                    ? _primaryBlue
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sel
                                      ? _primaryBlue
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Text(
                                e.value,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: sel ? Colors.white : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Video
                    const SizedBox(height: 12),
                    _FormLabel('exercises_video_label'.tr(), required: true),
                    // Mode toggle
                    Row(
                      children: [
                        _ModeButton(
                          label: 'exercises_video_url'.tr(),
                          selected: _videoModeUrl,
                          onTap: () => setState(() {
                            _videoModeUrl = true;
                            _videoFile = null;
                            _videoFileName = null;
                          }),
                        ),
                        const SizedBox(width: 8),
                        _ModeButton(
                          label: 'exercises_video_file'.tr(),
                          selected: !_videoModeUrl,
                          onTap: () => setState(() {
                            _videoModeUrl = false;
                            _urlCtrl.clear();
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_videoModeUrl)
                      _FormField(
                        controller: _urlCtrl,
                        hint: 'https://youtube.com/…',
                      )
                    else
                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Iconsax.video,
                                size: 28,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _videoFileName ?? 'exercises_file_pick'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _videoFileName != null
                                      ? _primaryBlue
                                      : Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // isPublic toggle
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Switch(
                          value: _isPublic,
                          onChanged: (v) => setState(() => _isPublic = v),
                          activeColor: _primaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isPublic
                              ? '${'exercises_public_label'.tr()} — ${'exercises_public_desc'.tr()}'
                              : 'exercises_public_label'.tr(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: ctrl.isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing
                            ? 'exercises_save'.tr()
                            : 'exercises_create'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Delete Dialog ─────────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  final ExerciseModel exercise;
  const _DeleteDialog({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ExercisesController>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '${'exercises_delete_title'.tr()}: ${exercise.name}',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      content: Text('exercises_delete_confirm'.tr()),
      actions: [
        TextButton(
          onPressed: ctrl.isDeleting ? null : () => Navigator.pop(context),
          child: Text('exercises_cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: ctrl.isDeleting
              ? null
              : () async {
                  final ok = await ctrl.deleteExercise(exercise.exerciseId);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'Exercice supprimé.'
                            : 'Erreur lors de la suppression.',
                      ),
                      backgroundColor: ok ? Colors.green : Colors.red,
                    ),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: ctrl.isDeleting
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text('exercises_delete_btn'.tr()),
        ),
      ],
    );
  }
}

// ── Assign Dialog ─────────────────────────────────────────────────────────────

class _AssignDialog extends StatefulWidget {
  final ExerciseModel exercise;
  const _AssignDialog({required this.exercise});

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ExercisesController>();
    final q = _searchCtrl.text.toLowerCase();
    final filtered = ctrl.patients.where((p) {
      if (q.isEmpty) return true;
      final name = (p['fullName'] ?? '').toString().toLowerCase();
      final email = (p['email'] ?? '').toString().toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'exercises_assign_title'.tr()} : ${widget.exercise.name}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            // Search
            TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'exercises_assign_search'.tr(),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Iconsax.search_normal, size: 18),
                filled: true,
                fillColor: const Color(0xFFF7F9FC),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Patient list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ctrl.isLoadingPatients
                  ? const Center(child: CircularProgressIndicator())
                  : ctrl.patientsError != null
                  ? Center(
                      child: Text(
                        ctrl.patientsError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : filtered.isEmpty
                  ? Center(
                      child: Text(
                        'exercises_no_patients_found'.tr(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final p = filtered[i];
                        final name = p['fullName'] ?? '?';
                        final email = p['email'] ?? '';
                        return InkWell(
                          onTap: ctrl.isAssigning
                              ? null
                              : () async {
                                  final ok = await ctrl.assignExercise(
                                    exerciseId: widget.exercise.exerciseId,
                                    patientId: p['userId'] ?? '',
                                  );
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        ok
                                            ? 'Exercice assigné !'
                                            : 'Erreur lors de l\'assignation.',
                                      ),
                                      backgroundColor: ok
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  );
                                },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: _primaryBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Text(
                                    name.isNotEmpty
                                        ? name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _primaryBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        email.toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                if (ctrl.isAssigning)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Iconsax.add, size: 18),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh, size: 16),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SideChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _primaryBlue : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _primaryBlue : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChipWidget({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: _primaryBlue)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 12, color: _primaryBlue),
          ),
        ],
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  final bool required;

  const _FormLabel(this.text, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          if (required)
            const Text(' *', style: TextStyle(color: Colors.red, fontSize: 13)),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _FormField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? _primaryBlue : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? _primaryBlue : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
