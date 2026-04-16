import 'package:flutter/material.dart';
import 'package:sahtek/models/specialist_model.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/appointment_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/features/appointments/services/appointment_api_service.dart';

class ReserverRDVPage extends StatefulWidget {
  const ReserverRDVPage({Key? key}) : super(key: key);

  @override
  State<ReserverRDVPage> createState() => _ReserverRDVPageState();
}

class _ReserverRDVPageState extends State<ReserverRDVPage> {
  bool isPresentiel = true;
  int selectedDateIndex = 0;
  String selectedTime = '';
  String selectedAvailabilityId = '';
  bool _isLoadingSlots = false;
  bool _slotsInitialized = false;
  SpecialistModel? _specialist;
  final TextEditingController _reasonController = TextEditingController();
  List<AvailableAppointmentSlot> _availableSlots = [];

  late List<Map<String, String>> dates;

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_slotsInitialized) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is SpecialistModel) {
      _specialist = args;
      _slotsInitialized = true;
      _loadAvailableSlots();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _generateDates() {
    final now = DateTime.now();
    dates = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return {
        'day': DateFormat(
          'EEE',
          'fr',
        ).format(date).toUpperCase().replaceAll('.', ''),
        'date': DateFormat('dd').format(date),
        'fullDate': date.toIso8601String(),
        'weekday': date.weekday.toString(),
      };
    });
  }

  Future<void> _loadAvailableSlots() async {
    final specialist = _specialist;
    if (specialist == null) return;

    setState(() {
      _isLoadingSlots = true;
    });

    try {
      final slots = await AppointmentApiService.fetchAvailableSlots(
        specialist.userId,
      );
      if (!mounted) return;
      setState(() {
        _availableSlots = slots;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des créneaux')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingSlots = false;
      });
    }
  }

  DateTime get _selectedDate {
    final parsed = DateTime.parse(dates[selectedDateIndex]['fullDate']!);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  String get _selectedDateKey => DateFormat('yyyy-MM-dd').format(_selectedDate);

  List<AvailableAppointmentSlot> get _filteredSlots {
    final selectedDateKey = _selectedDateKey;
    final slots = _availableSlots.where((slot) {
      return slot.effectiveDateKey == selectedDateKey &&
          slot.matchesConsultationType(isPresentiel);
    }).toList();

    slots.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return slots;
  }

  List<AvailableAppointmentSlot> get _morningSlots =>
      _filteredSlots.where((slot) => slot.isMorning).toList();

  List<AvailableAppointmentSlot> get _afternoonSlots =>
      _filteredSlots.where((slot) => !slot.isMorning).toList();

  AvailableAppointmentSlot? get _selectedSlot {
    if (selectedAvailabilityId.isEmpty) return null;
    for (final slot in _availableSlots) {
      if (slot.availabilityId == selectedAvailabilityId) {
        return slot;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final SpecialistModel specialist =
        _specialist ??
        ModalRoute.of(context)!.settings.arguments as SpecialistModel;
    final List<AvailableAppointmentSlot> morningSlots = _morningSlots;
    final List<AvailableAppointmentSlot> afternoonSlots = _afternoonSlots;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9FF),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.08),
            radius: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFF0D54F2),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'book_appointment_title'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F9FF), Color(0xFFFFFFFF)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpecialistCard(specialist),
              const SizedBox(height: 24),
              Text(
                'consultation_type'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1D2B53),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeConsultation(
                      "presentiel".tr(),
                      Icons.groups,
                      isPresentiel,
                      () {
                        setState(() {
                          isPresentiel = true;
                          selectedTime = '';
                          selectedAvailabilityId = '';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTypeConsultation(
                      "distance".tr(),
                      Icons.videocam,
                      !isPresentiel,
                      () {
                        setState(() {
                          isPresentiel = false;
                          selectedTime = '';
                          selectedAvailabilityId = '';
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDateSelector(),
              if (_isLoadingSlots) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              if (!_isLoadingSlots && _filteredSlots.isEmpty) ...[
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFDCE7FF)),
                  ),
                  child: const Text(
                    'Aucun créneau disponible pour cette date.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildPeriodSection(
                'morning'.tr(),
                Icons.wb_sunny_outlined,
                morningSlots,
              ),
              const SizedBox(height: 24),
              _buildPeriodSection(
                'afternoon'.tr(),
                Icons.nights_stay_outlined,
                afternoonSlots,
              ),
              const SizedBox(height: 24),
              _buildNoteSection(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomBar(specialist),
    );
  }

  Widget _buildSpecialistCard(SpecialistModel specialist) {
    return Container(
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
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE3EAFF),
            child: Text(
              specialist.fullName.isNotEmpty
                  ? specialist.fullName[0].toUpperCase()
                  : 'S',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D54F2),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialist.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF0D54F2),
                  ),
                ),
                Text(
                  '${specialist.specialty} - ${specialist.clinic}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 14),
                    Text(
                      specialist.location,
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(
                      '${specialist.rating} (${specialist.reviewsCount} avis)',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'choose_date'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              DateFormat('MMMM yyyy', 'fr').format(DateTime.now()),
              style: const TextStyle(
                color: Color(0xFF0D54F2),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) => _buildDateItem(index),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSection(
    String title,
    IconData icon,
    List<AvailableAppointmentSlot> slots,
  ) {
    if (slots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((slot) => _buildTimeSlot(slot)).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'note_for_practitioner'.tr()} *',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Color(0xFF1D2B53),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _reasonController,
            maxLines: 3,
            maxLength: 300,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'describe_reason_hint'.tr(),
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              counterStyle: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(SpecialistModel specialist) {
    final bool hasReason = _reasonController.text.trim().isNotEmpty;
    final bool canConfirm = selectedAvailabilityId.isNotEmpty && hasReason;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                canConfirm
                    ? 'Rappel : ${dates[selectedDateIndex]['day']}, ${dates[selectedDateIndex]['date']} à $selectedTime'
                    : 'Sélectionnez un créneau et ajoutez une raison',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '60,00 dt',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: buttonC('confirm_booking'.tr(), () async {
              if (!canConfirm) {
                final hasSlot = selectedAvailabilityId.isNotEmpty;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      hasSlot
                          ? 'La raison du rendez-vous est obligatoire'
                          : 'Veuillez sélectionner un créneau',
                    ),
                  ),
                );
                return;
              }
              final selectedSlot = _selectedSlot;
              if (selectedSlot == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Créneau invalide, veuillez réessayer'),
                  ),
                );
                return;
              }

              try {
                await AppointmentApiService.createApointment(
                  specialistId: specialist.userId,
                  availabilityId: selectedAvailabilityId,
                  reason: _reasonController.text.trim(),
                );
              } catch (_) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Échec de la réservation')),
                );
                return;
              }

              final provider = Provider.of<GlobalDataProvider>(
                context,
                listen: false,
              );
              final newApp = AppointmentModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                specialistName: specialist.fullName,
                specialty: specialist.specialty,
                date: selectedSlot.localDay,
                time: selectedTime,
                status: 'SCHEDULED',
                type: isPresentiel ? 'Présentiel' : 'Téléconsultation',
                imageUrl: specialist.imageUrl,
              );
              provider.addAppointment(newApp);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "booking_confirmed_snack".tr(
                      namedArgs: {'doctor': specialist.fullName},
                    ),
                  ),
                ),
              );
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/accueil', (route) => false);
            }, icon: Icons.calendar_today),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeConsultation(
    String title,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF2F6FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF0D54F2) : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x140D54F2),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? const Color(0xFF0D54F2) : Colors.grey),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: selected ? const Color(0xFF0D54F2) : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateItem(int index) {
    bool selected = selectedDateIndex == index;
    return InkWell(
      onTap: () => setState(() {
        selectedDateIndex = index;
        selectedTime = '';
        selectedAvailabilityId = '';
      }),
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D54F2) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFDCE7FF),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dates[index]['day']!,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dates[index]['date']!,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(AvailableAppointmentSlot slot) {
    final time = slot.displayStartTime;
    bool selected = selectedAvailabilityId == slot.availabilityId;
    return InkWell(
      onTap: () => setState(() {
        selectedAvailabilityId = slot.availabilityId;
        selectedTime = time;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D54F2) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFDCE7FF),
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x220D54F2),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Text(
          time,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
