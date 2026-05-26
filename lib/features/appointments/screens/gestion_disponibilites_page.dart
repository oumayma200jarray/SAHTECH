// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/core/widgets/specialist_bottom_nav_bar.dart';
import 'package:sahtek/features/appointments/services/doctor_api_service.dart';
import 'package:sahtek/models/clinic_model.dart';

class GestionDisponibilitesPage extends StatefulWidget {
  const GestionDisponibilitesPage({super.key});

  @override
  State<GestionDisponibilitesPage> createState() =>
      _GestionDisponibilitesPageState();
}

class _GestionDisponibilitesPageState extends State<GestionDisponibilitesPage> {
  // ─── State ───────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _slots = [];
  List<Map<String, dynamic>> _appointments = [];
  bool _loadingSlots = true;
  bool _loadingAppointments = true;
  String? _updatingAppointmentId;
  late String _selectedDayKey;
  String _appointmentFilter = 'ALL';
  final DateTime _today = DateTime.now();
  final ScrollController _slotsScrollController = ScrollController();

  static const _filters = [
    {'key': 'ALL', 'label': 'Tous'},
    {'key': 'SCHEDULED', 'label': 'Nouveaux'},
    {'key': 'ACEPTED', 'label': 'Acceptés'},
    {'key': 'COMPLETED', 'label': 'Terminés'},
    {'key': 'REJECTED', 'label': 'Rejetés'},
    {'key': 'CANCELLED', 'label': 'Annulés'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDayKey = _toDateKey(_today);
    _loadData();
  }

  @override
  void dispose() {
    _slotsScrollController.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  String _toDateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // Handles both int (API sends 8) and ISO string (API stores DateTime)
  String _formatHour(dynamic value) {
    if (value == null) return '-';
    if (value is int) return '${value.toString().padLeft(2, '0')}:00';
    final dt = DateTime.tryParse(value.toString());
    if (dt != null) return DateFormat('HH:mm').format(dt.toLocal());
    return '-';
  }

  int _toHour(dynamic value) {
    if (value is int) return value;
    final dt = DateTime.tryParse(value.toString());
    if (dt != null) return dt.toLocal().hour;
    return int.tryParse(value.toString().split(':').first) ?? 8;
  }

  // Prefer the date field; fall back to startTime ISO if date is absent
  String _resolveDate(dynamic rawDate, dynamic rawStart) {
    final fromDate = DateTime.tryParse((rawDate ?? '').toString());
    if (fromDate != null) return _toDateKey(fromDate.toLocal());
    final fromStart = DateTime.tryParse((rawStart ?? '').toString());
    if (fromStart != null) return _toDateKey(fromStart.toLocal());
    return _toDateKey(_today);
  }

  String _dateLabel(String key) {
    final parts = key.split('-');
    if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
    return key;
  }

  // ─── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _loadSlots() async {
    try {
      setState(() => _loadingSlots = true);
      final raw = await DoctorApiService.getDailySlots();
      final list =
          raw.map<Map<String, dynamic>>((item) {
            final id = (item['availabilityId'] ?? item['id'] ?? '').toString();
            final dateKey = _resolveDate(item['date'], item['startTime']);
            return {
              'id': id,
              'dateKey': dateKey,
              'dateLabel': _dateLabel(dateKey),
              'startLabel': _formatHour(item['startTime']),
              'endLabel': _formatHour(item['endTime']),
              'startHour': _toHour(item['startTime']),
              'endHour': _toHour(item['endTime']),
              'rawDate': (item['date'] ?? dateKey).toString(),
              'isBooked': item['isBooked'] == true,
              'place': (item['place'] ?? '-').toString(),
            };
          }).toList()..sort((a, b) {
            final ka =
                '${a['dateKey']}${(a['startHour'] as int).toString().padLeft(2, '0')}';
            final kb =
                '${b['dateKey']}${(b['startHour'] as int).toString().padLeft(2, '0')}';
            return ka.compareTo(kb);
          });
      if (mounted) setState(() => _slots = list);
    } catch (e) {
      debugPrint('Failed to load slots: $e');
    } finally {
      if (mounted) setState(() => _loadingSlots = false);
    }
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() => _loadingAppointments = true);
      final raw = await DoctorApiService.getAppointments();
      final list =
          raw.map<Map<String, dynamic>>((item) {
            final slot =
                (item['AvailableSlot'] as Map?)?.cast<String, dynamic>() ?? {};
            final dateKey = _resolveDate(slot['date'], slot['startTime']);
            return {
              'appointmentId': (item['appointmentId'] ?? '').toString(),
              'status': (item['status'] ?? 'SCHEDULED').toString(),
              'reason': (item['reason'] ?? '-').toString(),
              'patientName':
                  item['patient']?['user']?['fullName']?.toString() ??
                  'Patient',
              'patientImage':
                  item['patient']?['user']?['imageUrl']?.toString() ?? '',
              'dateLabel': _dateLabel(dateKey),
              'startLabel': _formatHour(slot['startTime']),
              'endLabel': _formatHour(slot['endTime']),
              'place': (slot['place'] ?? '-').toString(),
            };
          }).toList()..sort(
            (a, b) =>
                (b['dateLabel'] as String).compareTo(a['dateLabel'] as String),
          );
      if (mounted) setState(() => _appointments = list);
    } catch (e) {
      debugPrint('Failed to load appointments: $e');
    } finally {
      if (mounted) setState(() => _loadingAppointments = false);
    }
  }

  Future<void> _loadData() => Future.wait([_loadSlots(), _loadAppointments()]);

  // ─── Computed ─────────────────────────────────────────────────────────────────

  Map<String, List<Map<String, dynamic>>> get _slotsByDay {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final s in _slots) {
      map.putIfAbsent(s['dateKey'] as String, () => []).add(s);
    }
    return map;
  }

  List<Map<String, dynamic>> get _filteredAppointments =>
      _appointmentFilter == 'ALL'
      ? _appointments
      : _appointments.where((a) => a['status'] == _appointmentFilter).toList();

  Map<String, int> get _appointmentCounts {
    final counts = <String, int>{'ALL': 0};
    for (final a in _appointments) {
      counts['ALL'] = (counts['ALL'] ?? 0) + 1;
      final s = a['status'] as String;
      counts[s] = (counts[s] ?? 0) + 1;
    }
    return counts;
  }

  // ─── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _updateAppointment(String id, String status) async {
    try {
      setState(() => _updatingAppointmentId = id);
      await DoctorApiService.modifyAppointment(id, {
        'appointmentId': id,
        'status': status,
      });
      await _loadAppointments();
      // Rejecting frees the slot → refresh slots too
      if (status == 'REJECTED') await _loadSlots();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de modifier le rendez-vous'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _updatingAppointmentId = null);
    }
  }

  void _showAddSlotSheet() async {
    final payload = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddSlotSheet(),
    );
    if (payload == null || !mounted) return;
    try {
      await DoctorApiService.createDailySlots(payload);
      await _loadSlots();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Créneau ajouté avec succès')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'ajouter le créneau")),
        );
      }
    }
  }

  void _showEditSlotSheet(Map<String, dynamic> slot) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditSlotSheet(slot: slot),
    );
    if (result == null || !mounted) return;

    final id = slot['id'] as String;

    if (result['_delete'] == true) {
      try {
        await DoctorApiService.deleteDailySlots(id);
        await _loadSlots();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Créneau supprimé')));
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de supprimer le créneau')),
          );
        }
      }
      return;
    }

    try {
      await DoctorApiService.updateDailySlots(id, result);
      await _loadSlots();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Créneau mis à jour')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de modifier le créneau')),
        );
      }
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final slotsByDay = _slotsByDay;
    final weekStart = DateTime(
      _today.year,
      _today.month,
      _today.day,
    ).subtract(const Duration(days: 1));
    final weekDays = List<DateTime>.generate(8, (i) {
      final d = weekStart.add(Duration(days: i));
      return DateTime(d.year, d.month, d.day);
    });

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
              color: const Color(0xFF0D54F2),
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildWeeklyCalendar(weekDays, slotsByDay),
                    const SizedBox(height: 20),
                    _buildSlotsPanel(slotsByDay),
                    const SizedBox(height: 24),
                    _buildInfoBox(),
                    const SizedBox(height: 28),
                    _buildAppointmentsSection(),
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

  Widget _buildHeader() {
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
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFDAE7FF)),
              ),
              child: Text(
                '${_slots.length} créneau${_slots.length > 1 ? 'x' : ''}',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _showAddSlotSheet,
          icon: const Icon(Icons.add, size: 18),
          label: Text('add_slot'.tr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D54F2),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyCalendar(
    List<DateTime> weekDays,
    Map<String, List<Map<String, dynamic>>> slotsByDay,
  ) {
    // weekday is 1=Mon … 7=Sun
    const dayNames = ['', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
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
          Text(
            'weekly_slots'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: weekDays.map((day) {
                final dayKey = _toDateKey(day);
                final daySlots = slotsByDay[dayKey] ?? [];
                final isToday = dayKey == _toDateKey(_today);
                final isSelected = dayKey == _selectedDayKey;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDayKey = dayKey),
                  child: Container(
                    width: 88,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFEEF2FF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0D54F2)
                            : isToday
                            ? const Color(0xFFBBC7FF)
                            : Colors.grey.withOpacity(0.12),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          dayNames[day.weekday],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isToday
                                ? const Color(0xFF0D54F2)
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isToday
                                ? const Color(0xFF0D54F2)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...daySlots
                            .take(2)
                            .map(
                              (s) => Container(
                                margin: const EdgeInsets.only(top: 3),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D54F2),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  s['startLabel'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        if (daySlots.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              '+${daySlots.length - 2}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF0D54F2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

  Widget _buildSlotsPanel(Map<String, List<Map<String, dynamic>>> slotsByDay) {
    final daySlots = slotsByDay[_selectedDayKey] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créneaux du ${_dateLabel(_selectedDayKey)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          height: 380,
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
          child: _loadingSlots
              ? const Center(child: CircularProgressIndicator())
              : daySlots.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 40,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucun créneau pour ce jour',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : Scrollbar(
                  controller: _slotsScrollController,
                  thumbVisibility: true,
                  child: ListView.separated(
                    controller: _slotsScrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: daySlots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildSlotCard(daySlots[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(Map<String, dynamic> slot) {
    final isBooked = slot['isBooked'] as bool;
    return InkWell(
      onTap: () => _showEditSlotSheet(slot),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isBooked
                ? const Color(0xFFFF9800).withOpacity(0.3)
                : const Color(0xFF0D54F2).withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Color(0xFF0D54F2),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${slot['startLabel']} — ${slot['endLabel']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    slot['place'] as String,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildStatusPill(isBooked ? 'Réservé' : 'Disponible', isBooked),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Color(0xFFB0B7C3), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(String label, bool isBooked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isBooked ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBooked ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isBooked ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
        ),
      ),
    );
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

  Widget _buildAppointmentsSection() {
    final counts = _appointmentCounts;
    final filtered = _filteredAppointments;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rendez-vous patients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gérer les demandes et suivis',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${counts['ALL'] ?? 0} total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D54F2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((f) {
              final key = f['key']!;
              final isActive = _appointmentFilter == key;
              final count = counts[key] ?? 0;
              return GestureDetector(
                onTap: () => setState(() => _appointmentFilter = key),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF0D54F2) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF0D54F2)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    '${f['label']} ($count)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (_loadingAppointments)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(),
            ),
          )
        else if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'Aucun rendez-vous pour ce filtre',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          )
        else
          ...filtered.map(_buildAppointmentCard),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> app) {
    final id = app['appointmentId'] as String;
    final status = app['status'] as String;
    final isUpdating = _updatingAppointmentId == id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient row + badge
          Row(
            children: [
              _buildAvatar(
                app['patientImage'] as String,
                app['patientName'] as String,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app['patientName'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      app['reason'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildAppointmentBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          // Date / time / place
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _infoChip(
                Icons.calendar_today_outlined,
                app['dateLabel'] as String,
              ),
              _infoChip(
                Icons.access_time,
                '${app['startLabel']} — ${app['endLabel']}',
              ),
              _infoChip(Icons.location_on_outlined, app['place'] as String),
            ],
          ),
          // Action buttons
          if (isUpdating) ...[
            const SizedBox(height: 14),
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ] else if (status == 'SCHEDULED') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    'Accepter',
                    Icons.check_circle_outline,
                    const Color(0xFF0EA5A4),
                    () => _updateAppointment(id, 'ACEPTED'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionBtn(
                    'Rejeter',
                    Icons.cancel_outlined,
                    const Color(0xFFF43F5E),
                    () => _updateAppointment(id, 'REJECTED'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ghostBtn(
                    'Annuler',
                    () => _updateAppointment(id, 'CANCELLED'),
                  ),
                ),
              ],
            ),
          ] else if (status == 'ACEPTED') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    'Marquer terminé',
                    Icons.task_alt_rounded,
                    const Color(0xFF16A34A),
                    () => _updateAppointment(id, 'COMPLETED'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ghostBtn(
                    'Annuler',
                    () => _updateAppointment(id, 'CANCELLED'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, String name) {
    if (imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (_, __) {},
        backgroundColor: const Color(0xFFEEF2FF),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFEEF2FF),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'P',
        style: const TextStyle(
          color: Color(0xFF0D54F2),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildAppointmentBadge(String status) {
    String label;
    Color bg, border, text;
    switch (status) {
      case 'SCHEDULED':
        label = 'Programmé';
        bg = const Color(0xFFFFF3E0);
        border = const Color(0xFFFF9800);
        text = const Color(0xFFE65100);
        break;
      case 'ACEPTED':
        label = 'Accepté';
        bg = const Color(0xFFE8F5E9);
        border = const Color(0xFF4CAF50);
        text = const Color(0xFF2E7D32);
        break;
      case 'REJECTED':
        label = 'Rejeté';
        bg = const Color(0xFFFFEBEE);
        border = const Color(0xFFF43F5E);
        text = const Color(0xFFC62828);
        break;
      case 'COMPLETED':
        label = 'Terminé';
        bg = const Color(0xFFE3F2FD);
        border = const Color(0xFF2196F3);
        text = const Color(0xFF1565C0);
        break;
      default:
        label = 'Annulé';
        bg = const Color(0xFFF5F5F5);
        border = const Color(0xFF9E9E9E);
        text = const Color(0xFF757575);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
      ],
    );
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _ghostBtn(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFD6E4FF)),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}

// ─── Add Slot Bottom Sheet ────────────────────────────────────────────────────

class _AddSlotSheet extends StatefulWidget {
  const _AddSlotSheet();

  @override
  State<_AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<_AddSlotSheet> {
  DateTime _selectedDate = DateTime.now();
  int _startHour = 8;
  int _endHour = 17;
  final TextEditingController _placeCtrl = TextEditingController();
  List<ClinicModel> _clinics = [];
  ClinicModel? _selectedClinic;
  bool _loadingClinics = false;

  @override
  void initState() {
    super.initState();
    _loadClinics();
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    setState(() => _loadingClinics = true);
    try {
      final list = await DoctorApiService.getDoctorClinics();
      if (mounted) setState(() => _clinics = list);
    } finally {
      if (mounted) setState(() => _loadingClinics = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (_placeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le lieu est obligatoire')));
      return;
    }
    if (_startHour >= _endHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "L'heure de fin doit être supérieure à l'heure de début",
          ),
        ),
      );
      return;
    }
    final dateKey =
        '${_selectedDate.year.toString().padLeft(4, '0')}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';
    final payload = <String, dynamic>{
      'date': dateKey,
      'startTime': _startHour,
      'endTime': _endHour,
      'place': _placeCtrl.text.trim(),
    };
    if (_selectedClinic != null) {
      payload['clinicId'] = _selectedClinic!.clinicId;
    }
    Navigator.pop(context, payload);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajouter un créneau',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Date picker
          _SheetField(
            label: 'Date',
            child: InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Color(0xFF0D54F2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Hour pickers
          Row(
            children: [
              Expanded(
                child: _SheetField(
                  label: 'Heure début',
                  child: _HourDropdown(
                    value: _startHour,
                    onChanged: (v) => setState(() => _startHour = v),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SheetField(
                  label: 'Heure fin',
                  child: _HourDropdown(
                    value: _endHour,
                    onChanged: (v) => setState(() => _endHour = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Place
          _SheetField(
            label: 'Lieu (salle / cabinet) *',
            child: TextField(
              controller: _placeCtrl,
              decoration: InputDecoration(
                hintText: 'Ex: Salle 3 / Couloir B',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
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
            ),
          ),
          const SizedBox(height: 14),
          // Clinic dropdown (optional, non-critical if empty)
          _SheetField(
            label: 'Clinique (optionnel)',
            child: _loadingClinics
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<ClinicModel?>(
                    value: _selectedClinic,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
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
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          '— Lieu externe (aucune clinique) —',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      ..._clinics.map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                            c.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedClinic = v),
                  ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D54F2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ajouter le créneau',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Edit Slot Bottom Sheet ───────────────────────────────────────────────────

class _EditSlotSheet extends StatefulWidget {
  final Map<String, dynamic> slot;
  const _EditSlotSheet({required this.slot});

  @override
  State<_EditSlotSheet> createState() => _EditSlotSheetState();
}

class _EditSlotSheetState extends State<_EditSlotSheet> {
  late DateTime _selectedDate;
  late int _startHour;
  late int _endHour;
  late TextEditingController _placeCtrl;
  late bool _isBooked;

  @override
  void initState() {
    super.initState();
    // Parse from dateKey (YYYY-MM-DD) to avoid timezone boundary issues
    final dateKey = (widget.slot['dateKey'] as String?) ?? '';
    final parts = dateKey.split('-');
    if (parts.length == 3) {
      _selectedDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } else {
      _selectedDate = DateTime.now();
    }
    _startHour = (widget.slot['startHour'] as int?) ?? 8;
    _endHour = (widget.slot['endHour'] as int?) ?? 17;
    _placeCtrl = TextEditingController(
      text: widget.slot['place'] as String? ?? '',
    );
    _isBooked = (widget.slot['isBooked'] as bool?) ?? false;
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le créneau'),
        content: const Text('Confirmer la suppression de ce créneau ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, {'_delete': true}); // close sheet
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_placeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Le lieu est obligatoire')));
      return;
    }
    if (_startHour >= _endHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "L'heure de fin doit être supérieure à l'heure de début",
          ),
        ),
      );
      return;
    }
    final dateKey =
        '${_selectedDate.year.toString().padLeft(4, '0')}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';
    Navigator.pop(context, {
      'date': dateKey,
      'startTime': _startHour,
      'endTime': _endHour,
      'place': _placeCtrl.text.trim(),
      'isBooked': _isBooked,
    });
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + delete icon
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Détails du créneau',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _confirmDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFF43F5E),
                ),
                tooltip: 'Supprimer',
              ),
            ],
          ),
          // Current slot summary
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF0D54F2).withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Color(0xFF0D54F2),
                ),
                const SizedBox(width: 8),
                Text(
                  '${slot['dateLabel']}  •  '
                  "${slot['startLabel']} — ${slot['endLabel']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Date
          _SheetField(
            label: 'Date',
            child: InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Color(0xFF0D54F2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Hour pickers
          Row(
            children: [
              Expanded(
                child: _SheetField(
                  label: 'Heure début',
                  child: _HourDropdown(
                    value: _startHour,
                    onChanged: (v) => setState(() => _startHour = v),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SheetField(
                  label: 'Heure fin',
                  child: _HourDropdown(
                    value: _endHour,
                    onChanged: (v) => setState(() => _endHour = v),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Place
          _SheetField(
            label: 'Lieu *',
            child: TextField(
              controller: _placeCtrl,
              decoration: InputDecoration(
                hintText: 'Ex: Salle 3 / Couloir B',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
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
            ),
          ),
          const SizedBox(height: 14),
          // isBooked toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statut du créneau',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Marquer comme réservé ou disponible',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isBooked,
                  onChanged: (v) => setState(() => _isBooked = v),
                  activeColor: const Color(0xFF0D54F2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D54F2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Enregistrer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared sheet helpers ─────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final String label;
  final Widget child;
  const _SheetField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _HourDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _HourDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
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
      items: List.generate(
        24,
        (h) => DropdownMenuItem(
          value: h,
          child: Text('${h.toString().padLeft(2, '0')}:00'),
        ),
      ),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
