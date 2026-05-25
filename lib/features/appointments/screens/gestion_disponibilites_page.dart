// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/availability_model.dart';
import 'package:sahtek/models/clinic_model.dart';
import 'package:sahtek/core/widgets/buttons.dart';
// removed unused import: availability_calendar_grid
import 'package:sahtek/features/appointments/widgets/availability_slot_card.dart';
import 'package:sahtek/core/widgets/specialist_bottom_nav_bar.dart';
import 'package:sahtek/features/appointments/services/doctor_api_service.dart';
// intl functionality is available via easy_localization import

// API calls are handled in services/doctor_api_service.dart

class GestionDisponibilitesPage extends StatefulWidget {
  const GestionDisponibilitesPage({super.key});

  @override
  State<GestionDisponibilitesPage> createState() =>
      _GestionDisponibilitesPageState();
}

class _GestionDisponibilitesPageState extends State<GestionDisponibilitesPage> {
  final List<AvailabilitySlot> _slots = [];
  final List<Map<String, dynamic>> _appointments = [];
  bool _loading = true;
  String? _updatingAppointmentId;
  final Map<String, String> _slotDateKeys = {}; // slotId -> YYYY-MM-DD
  late String _selectedDayKey;
  final DateTime _today = DateTime.now();
  late final ScrollController _slotsScrollController;

  @override
  void initState() {
    super.initState();
    _selectedDayKey =
        '${_today.year.toString().padLeft(4, '0')}-${_today.month.toString().padLeft(2, '0')}-${_today.day.toString().padLeft(2, '0')}';
    _slotsScrollController = ScrollController();
    _loadData();
  }

  @override
  void dispose() {
    _slotsScrollController.dispose();
    super.dispose();
  }

  DateTime _shiftHour(DateTime value) => value.add(const Duration(hours: 1));

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final rawSlots = await DoctorApiService.getDailySlots();
      final apps = await DoctorApiService.getAppointments();
      final slots = rawSlots.map<AvailabilitySlot>((item) {
        final id =
            (item['availabilityId'] ??
                    item['id'] ??
                    DateTime.now().millisecondsSinceEpoch.toString())
                .toString();
        final rawStart = (item['startTime'] ?? item['date'] ?? '').toString();
        DateTime? parsedStart = DateTime.tryParse(rawStart);
        final parsedDate = DateTime.tryParse((item['date'] ?? '').toString());
        final date = parsedStart ?? parsedDate ?? DateTime.now();
        final start = _shiftHour(parsedStart ?? date);
        final end = _shiftHour(
          DateTime.tryParse((item['endTime'] ?? '').toString()) ??
              (parsedStart ?? date).add(const Duration(hours: 1)),
        );
        final startLabel = DateFormat('HH:mm').format(start);
        final endLabel = DateFormat('HH:mm').format(end);

        // compute dateKey YYYY-MM-DD (prefer iso in rawStart if present)
        String dateKey;
        final isoLike = RegExp(r'^\d{4}-\d{2}-\d{2}');
        if (isoLike.hasMatch(rawStart)) {
          dateKey = rawStart.substring(0, 10);
        } else if (parsedDate != null) {
          dateKey =
              '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
        } else {
          dateKey =
              '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
        _slotDateKeys[id] = dateKey;

        final place = (item['place'] ?? '').toString().toLowerCase();
        final type =
            (place.contains('video') ||
                place.contains('tele') ||
                place.contains('online'))
            ? AvailabilityType.video
            : AvailabilityType.cabinet;

        return AvailabilitySlot(
          id: id,
          dayOfWeek: start.weekday,
          startTime: startLabel,
          endTime: endLabel,
          type: type,
        );
      }).toList();

      final appointments = apps.map<Map<String, dynamic>>((item) {
        final slot =
            (item['AvailableSlot'] as Map?)?.cast<String, dynamic>() ?? {};
        final parsedStart = DateTime.tryParse(
          (slot['startTime'] ?? '').toString(),
        );
        final parsedEnd = DateTime.tryParse((slot['endTime'] ?? '').toString());
        final displayStart = parsedStart != null
            ? _shiftHour(parsedStart)
            : null;
        final displayEnd = parsedEnd != null ? _shiftHour(parsedEnd) : null;
        final displayDate =
            displayStart ??
            DateTime.tryParse((slot['date'] ?? '').toString()) ??
            DateTime.now();

        return {
          'appointmentId': item['appointmentId'],
          'status': item['status'],
          'reason': item['reason'] ?? '-',
          'patientName': item['patient']?['user']?['fullName'] ?? 'Patient',
          'patientImage': item['patient']?['user']?['imageUrl'] ?? '',
          'date': displayDate,
          'dateLabel': DateFormat.yMMMd().format(displayDate),
          'startLabel': displayStart != null
              ? DateFormat('HH:mm').format(displayStart)
              : '-',
          'endLabel': displayEnd != null
              ? DateFormat('HH:mm').format(displayEnd)
              : '-',
          'place': slot['place']?.toString() ?? '-',
        };
      }).toList();

      setState(() {
        _slots
          ..clear()
          ..addAll(slots);
        _appointments
          ..clear()
          ..addAll(appointments);
      });
    } catch (e) {
      // ignore errors for now; keep local fallback
    }
    setState(() => _loading = false);
  }

  Future<void> _refreshPage() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final slots = _slots.isNotEmpty ? _slots : provider.availabilitySlots;
    // group slots by dateKey using _slotDateKeys
    Map<String, List<AvailabilitySlot>> slotsByDay = {};
    for (final s in slots) {
      final key = _slotDateKeys[s.id] ?? '${s.dayOfWeek}';
      slotsByDay.putIfAbsent(key, () => []).add(s);
    }
    // selected day key already initialized in initState
    // show yesterday + today + the next 6 days
    final weekStart = DateTime(
      _today.year,
      _today.month,
      _today.day,
    ).subtract(const Duration(days: 1));
    final weekDays = List<DateTime>.generate(8, (i) {
      final day = weekStart.add(Duration(days: i));
      return DateTime(day.year, day.month, day.day);
    });
    String formatDateKey(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FF),
      bottomNavigationBar: const SpecialistBottomNavBar(currentIndex: 2),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D54F2).withOpacity(0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            left: -90,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16A34A).withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshPage,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopHeader(slots.length),
                    const SizedBox(height: 18),
                    _buildHeroCard(),
                    const SizedBox(height: 18),
                    _buildWeeklySection(
                      context,
                      weekDays,
                      slotsByDay,
                      formatDateKey,
                    ),
                    const SizedBox(height: 20),
                    _buildSlotsPanel(context, slotsByDay),
                    const SizedBox(height: 24),
                    _buildInfoBox(),
                    const SizedBox(height: 28),
                    _buildSectionHeader('appointments'.tr()),
                    const SizedBox(height: 12),
                    ..._appointments.map(_buildAppointmentTile),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'availability_mgmt_title'.tr(),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFDAE7FF)),
              ),
              child: Text(
                '$count creneaux',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE7FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x130D54F2),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.calendar_month, color: Color(0xFF0D54F2)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestion des créneaux',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Swipe dans la box pour voir plus de créneaux et actualise la page en tirant vers le bas.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySection(
    BuildContext context,
    List<DateTime> weekDays,
    Map<String, List<AvailabilitySlot>> slotsByDay,
    String Function(DateTime) formatDateKey,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDCE7FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildSectionHeader('weekly_slots'.tr())),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showSlotDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text('add_slot'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D54F2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: weekDays.map((day) {
                final dayKey = formatDateKey(day);
                final daySlots = slotsByDay[dayKey] ?? [];
                final isToday = dayKey == formatDateKey(_today);
                final isSelected = dayKey == _selectedDayKey;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayKey = dayKey),
                  child: Container(
                    width: 96,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEEF2FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday
                            ? const Color(0xFFBBC7FF)
                            : Colors.grey.withOpacity(0.12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('EEE').format(day),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${day.day}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (daySlots.isNotEmpty)
                          ...daySlots
                              .take(2)
                              .map(
                                (s) => Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3F51B5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    s.startTime,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // sync badge removed

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1C1E),
      ),
    );
  }

  Widget _buildSlotsPanel(
    BuildContext context,
    Map<String, List<AvailabilitySlot>> slotsByDay,
  ) {
    final selectedDaySlots = slotsByDay[_selectedDayKey] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Creneaux du ${DateFormat.yMMMMd().format(DateTime.parse(_selectedDayKey))}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          height: 392,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : selectedDaySlots.isEmpty
              ? Center(
                  child: Text(
                    'Aucun creneau pour ce jour',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : Scrollbar(
                  controller: _slotsScrollController,
                  thumbVisibility: true,
                  child: ListView.separated(
                    controller: _slotsScrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: selectedDaySlots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final slot = selectedDaySlots[index];
                      return AvailabilitySlotCard(
                        slot: slot,
                        onEdit: () => _handleEditSlot(context, slot),
                        onDelete: () => _deleteSlot(slot.id),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _handleEditSlot(BuildContext context, AvailabilitySlot slot) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _SlotDialog(existingSlot: slot),
    );
    if (result == null) return;
    // result should contain either create/update instructions
    if (result['action'] == 'update' && result['id'] != null) {
      await DoctorApiService.updateDailySlots(result['id'], result['payload']);
      await _loadData();
    }
  }

  void _showSlotDialog(
    BuildContext context, {
    AvailabilitySlot? existingSlot,
  }) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _SlotDialog(existingSlot: existingSlot),
    );
    if (result == null) return;
    if (result['action'] == 'create') {
      await DoctorApiService.createDailySlots(result['payload']);
      await _loadData();
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    await DoctorApiService.deleteDailySlots(slotId);
    await _loadData();
  }

  Widget _buildAppointmentTile(Map<String, dynamic> app) {
    final patient = app['patientName'] ?? '—';
    final date = app['dateLabel'] ?? '';
    final timeRange = '${app['startLabel'] ?? '-'} - ${app['endLabel'] ?? '-'}';
    final status = (app['status'] ?? 'SCHEDULED').toString();
    final id = app['appointmentId']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(date),
                const SizedBox(height: 6),
                Text(timeRange, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 6),
                Text(status, style: TextStyle(color: Colors.grey[700])),
              ],
            ),
          ),
          _buildAppointmentActions(id, status),
        ],
      ),
    );
  }

  Widget _buildAppointmentActions(String id, String status) {
    final isUpdating = _updatingAppointmentId == id;

    void handle(String newStatus) async {
      await _updateAppointmentStatus(id, newStatus);
    }

    if (status == 'SCHEDULED') {
      return Column(
        children: [
          _statusActionButton(
            label: 'Accepter',
            icon: Icons.check_circle_outline,
            background: const Color(0xFF0EA5A4),
            foreground: Colors.white,
            onPressed: isUpdating ? null : () => handle('ACEPTED'),
          ),
          const SizedBox(height: 8),
          _statusActionButton(
            label: 'Rejeter',
            icon: Icons.cancel_outlined,
            background: const Color(0xFFF43F5E),
            foreground: Colors.white,
            onPressed: isUpdating ? null : () => handle('REJECTED'),
          ),
        ],
      );
    }

    if (status == 'ACEPTED') {
      // accepted state: can complete or cancel
      return Column(
        children: [
          _statusActionButton(
            label: 'Marquer terminé',
            icon: Icons.task_alt_rounded,
            background: const Color(0xFF16A34A),
            foreground: Colors.white,
            onPressed: isUpdating ? null : () => handle('COMPLETED'),
          ),
          const SizedBox(height: 8),
          _statusGhostButton(
            label: 'Annuler',
            icon: Icons.close_rounded,
            onPressed: isUpdating ? null : () => handle('CANCELLED'),
          ),
        ],
      );
    }

    // For REJECTED, COMPLETED, CANCELLED allow changing via menu
    return PopupMenuButton<String>(
      onSelected: (value) async => await _updateAppointmentStatus(id, value),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'SCHEDULED',
          child: Text('Reprogrammer (SCHEDULED)'),
        ),
        const PopupMenuItem(value: 'ACEPTED', child: Text('Marquer accepté')),
        const PopupMenuItem(value: 'REJECTED', child: Text('Marquer rejeté')),
        const PopupMenuItem(value: 'COMPLETED', child: Text('Marquer terminé')),
        const PopupMenuItem(value: 'CANCELLED', child: Text('Marquer annulé')),
      ],
      child: const Icon(Icons.more_vert),
    );
  }

  Widget _statusActionButton({
    required String label,
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 140,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: foreground),
        label: Text(
          label,
          style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _statusGhostButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 140,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: const Color(0xFF0F172A)),
        label: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD6E4FF)),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Future<void> _updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      setState(() => _updatingAppointmentId = appointmentId);
      await DoctorApiService.modifyAppointment(appointmentId, {
        'appointmentId': appointmentId,
        'status': status,
      });
      await _loadData();
    } finally {
      setState(() => _updatingAppointmentId = null);
    }
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC5CAE9).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Color(0xFF3F51B5), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'info_reminder_title'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F51B5),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'info_reminder_desc'.tr(),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotDialog extends StatefulWidget {
  final AvailabilitySlot? existingSlot;
  const _SlotDialog({this.existingSlot});

  @override
  State<_SlotDialog> createState() => _SlotDialogState();
}

class _SlotDialogState extends State<_SlotDialog> {
  late int dayOfWeek;
  late String startTime;
  late String endTime;
  late String place;

  List<ClinicModel> _clinics = [];
  ClinicModel? _selectedClinic;
  bool _loadingClinics = false;

  @override
  void initState() {
    super.initState();
    dayOfWeek = widget.existingSlot?.dayOfWeek ?? 1;
    startTime = widget.existingSlot?.startTime ?? '09:00';
    endTime = widget.existingSlot?.endTime ?? '12:00';
    place = 'Cabinet';
    _loadClinics();
  }

  Future<void> _loadClinics() async {
    setState(() => _loadingClinics = true);
    try {
      final list = await DoctorApiService.getClinics();
      if (mounted) setState(() => _clinics = list);
    } finally {
      if (mounted) setState(() => _loadingClinics = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingSlot == null
            ? 'Ajouter un créneau'
            : 'Modifier le créneau',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: dayOfWeek,
              items: List.generate(
                7,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_getDayName(i + 1)),
                ),
              ),
              onChanged: (v) => setState(() => dayOfWeek = v!),
              decoration: const InputDecoration(labelText: 'Jour'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: startTime),
                    decoration:
                        const InputDecoration(labelText: 'Début (HH:MM)'),
                    onChanged: (v) => startTime = v,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: endTime),
                    decoration:
                        const InputDecoration(labelText: 'Fin (HH:MM)'),
                    onChanged: (v) => endTime = v,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ─── Clinic dropdown ───────────────────────────────────────
            _loadingClinics
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  )
                : DropdownButtonFormField<ClinicModel?>(
                    value: _selectedClinic,
                    decoration: const InputDecoration(labelText: 'Clinique'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'Aucune clinique / lieu externe',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      ..._clinics.map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.name,
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedClinic = v),
                  ),
            const SizedBox(height: 10),
            // ─── Place (room / cabinet number) ─────────────────────────
            TextField(
              controller: TextEditingController(text: place),
              decoration: const InputDecoration(
                  labelText: 'Lieu (salle, cabinet…)'),
              onChanged: (v) => place = v,
            ),
          ],
        ),
      ),
      actions: [
        buttonIn('Annuler', () => Navigator.pop(context), width: 100),
        buttonC('Valider', () {
          DateTime nextDateForWeekday(int weekday) {
            final now = DateTime.now();
            int diff = (weekday - now.weekday) % 7;
            if (diff < 0) diff += 7;
            final candidate = now.add(Duration(days: diff));
            return DateTime(candidate.year, candidate.month, candidate.day);
          }

          final startHourRaw = int.tryParse(startTime.split(':').first) ?? 9;
          final endHourRaw =
              int.tryParse(endTime.split(':').first) ?? (startHourRaw + 1);
          final startHour = (startHourRaw - 1 + 24) % 24;
          final endHour = (endHourRaw - 1 + 24) % 24;
          final date = nextDateForWeekday(dayOfWeek).toIso8601String();

          final payload = <String, dynamic>{
            'date': date,
            'startTime': startHour,
            'endTime': endHour,
            'place': place.isNotEmpty ? place : 'Cabinet',
          };
          if (_selectedClinic != null) {
            payload['clinicId'] = _selectedClinic!.clinicId;
          }

          if (widget.existingSlot == null) {
            Navigator.pop(context, {'action': 'create', 'payload': payload});
          } else {
            Navigator.pop(context, {
              'action': 'update',
              'id': widget.existingSlot!.id,
              'payload': {...payload, 'isBooked': false},
            });
          }
        }, width: 120),
      ],
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return '';
    }
  }
}
