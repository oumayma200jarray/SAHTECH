import 'package:flutter/material.dart';
import 'package:sahtek/models/specialist_model.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/appointment_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/availability_model.dart';

class ReserverRDVPage extends StatefulWidget {
  const ReserverRDVPage({Key? key}) : super(key: key);

  @override
  State<ReserverRDVPage> createState() => _ReserverRDVPageState();
}

class _ReserverRDVPageState extends State<ReserverRDVPage> {
  bool isPresentiel = true;
  int selectedDateIndex = 0;
  String selectedTime = '';

  late List<Map<String, String>> dates;

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  void _generateDates() {
    final now = DateTime.now();
    dates = List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return {
        'day': DateFormat('EEE', 'fr').format(date).toUpperCase().replaceAll('.', ''),
        'date': DateFormat('dd').format(date),
        'fullDate': date.toIso8601String(),
        'weekday': date.weekday.toString(),
      };
    });
  }

  List<String> _generateTimeSlots(List<AvailabilitySlot> availabilities, int weekday, bool isCabinet, bool morning) {
    final relevantSlots = availabilities.where((s) => 
      s.dayOfWeek == weekday && 
      ((isCabinet && s.type == AvailabilityType.cabinet) || (!isCabinet && s.type == AvailabilityType.video))
    ).toList();

    List<String> timeSlots = [];
    for (var slot in relevantSlots) {
      final startParts = slot.startTime.split(':');
      final endParts = slot.endTime.split(':');
      
      int currentHour = int.parse(startParts[0]);
      int currentMin = int.parse(startParts[1]);
      int endHour = int.parse(endParts[0]);
      int endMin = int.parse(endParts[1]);

      while (currentHour < endHour || (currentHour == endHour && currentMin < endMin)) {
        if ((morning && currentHour < 12) || (!morning && currentHour >= 12)) {
          timeSlots.add('${currentHour.toString().padLeft(2, '0')}:${currentMin.toString().padLeft(2, '0')}');
        }
        
        currentMin += 30;
        if (currentMin >= 60) {
          currentHour += 1;
          currentMin -= 60;
        }
      }
    }
    return timeSlots;
  }

  @override
  Widget build(BuildContext context) {
    final SpecialistModel specialist =
        ModalRoute.of(context)!.settings.arguments as SpecialistModel;
    final provider = Provider.of<GlobalDataProvider>(context);
    
    final int selectedWeekday = int.parse(dates[selectedDateIndex]['weekday']!);
    final List<String> morningSlots = _generateTimeSlots(provider.availabilitySlots, selectedWeekday, isPresentiel, true);
    final List<String> afternoonSlots = _generateTimeSlots(provider.availabilitySlots, selectedWeekday, isPresentiel, false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.08),
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF0D54F2), size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'book_appointment_title'.tr(),
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSpecialistCard(specialist),
            const SizedBox(height: 24),
            Text('consultation_type'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTypeConsultation("presentiel".tr(), Icons.groups, isPresentiel, () {
                    setState(() {
                      isPresentiel = true;
                      selectedTime = '';
                    });
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeConsultation("distance".tr(), Icons.videocam, !isPresentiel, () {
                    setState(() {
                      isPresentiel = false;
                      selectedTime = '';
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDateSelector(),
            const SizedBox(height: 24),
            _buildPeriodSection('morning'.tr(), Icons.wb_sunny_outlined, morningSlots),
            const SizedBox(height: 24),
            _buildPeriodSection('afternoon'.tr(), Icons.nights_stay_outlined, afternoonSlots),
            const SizedBox(height: 24),
            _buildNoteSection(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(specialist),
    );
  }

  Widget _buildSpecialistCard(SpecialistModel specialist) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFFE3EAFF),
            child: Text(
              specialist.fullName.isNotEmpty ? specialist.fullName[0].toUpperCase() : 'S',
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
                Text(specialist.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D54F2))),
                Text('${specialist.specialty} - ${specialist.clinic}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey, size: 14),
                    Text(specialist.location, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(width: 8),
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text('${specialist.rating} (${specialist.reviewsCount} avis)', style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
            Text('choose_date'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(DateFormat('MMMM yyyy', 'fr').format(DateTime.now()), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
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

  Widget _buildPeriodSection(String title, IconData icon, List<String> slots) {
    if (slots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 18),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: slots.map((time) => _buildTimeSlot(time)).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('note_for_practitioner'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'describe_reason_hint'.tr(),
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(SpecialistModel specialist) {
    final bool canConfirm = selectedTime.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.black12))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                canConfirm ? 'Rappel : ${dates[selectedDateIndex]['day']}, ${dates[selectedDateIndex]['date']} à $selectedTime' : 'Sélectionnez un créneau',
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const Text('60,00 €', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: buttonC('confirm_booking'.tr(), () {
              if (!canConfirm) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un créneau')));
                return;
              }
              final provider = Provider.of<GlobalDataProvider>(context, listen: false);
              final newApp = AppointmentModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                specialistName: specialist.fullName,
                specialty: specialist.specialty,
                date: DateTime.parse(dates[selectedDateIndex]['fullDate']!),
                time: selectedTime,
                status: 'Confirmé',
                type: isPresentiel ? 'Présentiel' : 'Téléconsultation',
                imageUrl: specialist.imageUrl,
              );
              provider.addAppointment(newApp);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("booking_confirmed_snack".tr(namedArgs: {'doctor': specialist.fullName}))));
              Navigator.of(context).pushNamedAndRemoveUntil('/score_constant', (route) => false);
            }, icon: Icons.calendar_today),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeConsultation(String title, IconData icon, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? const Color(0xFF0D54F2) : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? const Color(0xFF0D54F2) : Colors.grey),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: selected ? const Color(0xFF0D54F2) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
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
      }),
      child: Container(
        width: 60,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D54F2) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(dates[index]['day']!, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(dates[index]['date']!, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    bool selected = selectedTime == time;
    return InkWell(
      onTap: () => setState(() => selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0D54F2) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
        ),
        child: Text(time, style: TextStyle(color: selected ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }
}
