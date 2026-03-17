import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/availability_model.dart';

class AvailabilityCalendarGrid extends StatelessWidget {
  final List<AvailabilitySlot> slots;

  const AvailabilityCalendarGrid({Key? key, required this.slots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chevron_left, color: Colors.black54),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const Spacer(),
        Column(
          children: [
            Text(
              'week_label'.tr(namedArgs: {'start': '14', 'end': '20'}),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.chevron_right, color: Colors.black54),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        Container(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: Text(
              'add_slot'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D54F2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Column
        _buildTimeColumn(),
        const VerticalDivider(width: 1),
        // Days Columns
        Expanded(child: _buildDayColumn(1, 'monday_short'.tr(), '14')),
        Expanded(child: _buildDayColumn(2, 'tuesday_short'.tr(), '15')),
        Expanded(child: _buildDayColumn(3, 'wednesday_short'.tr(), '16')),
      ],
    );
  }

  Widget _buildTimeColumn() {
    return Column(
      children: [
        const SizedBox(height: 50), // Header space
        ...['08:00', '10:00', '12:00', '14:00', '16:00', '18:00'].map((time) => Container(
              height: 60,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 12),
              child: Text(
                time,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            )),
      ],
    );
  }

  Widget _buildDayColumn(int dayIndex, String label, String dayOfMonth) {
    final daySlots = slots.where((s) => s.dayOfWeek == dayIndex).toList();

    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          _buildDayHeader(label, dayOfMonth),
          const Divider(height: 1),
          Stack(
            children: [
              Column(
                children: List.generate(6, (index) => Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[50]!)),
                  ),
                )),
              ),
              ...daySlots.map((slot) => _buildSlotInGrid(slot)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String label, String dayOfMonth) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
          Text(dayOfMonth, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSlotInGrid(AvailabilitySlot slot) {
    // Basic calculation for positioning (to be refined)
    // Assuming 08:00 is the start (top = 0)
    final startParts = slot.startTime.split(':');
    final startHour = int.parse(startParts[0]);
    final startMin = int.parse(startParts[1]);
    
    final endParts = slot.endTime.split(':');
    final endHour = int.parse(endParts[0]);
    final endMin = int.parse(endParts[1]);

    final double height = ((endHour - startHour) * 60 + (endMin - startMin)) * 0.5;

    return Positioned(
      top: 20 + (startHour - 8) * 30 + (startMin/2), // Adjusted for 60px height blocks
      left: 4,
      right: 4,
      child: Container(
        height: height > 40 ? height : 40,
        decoration: BoxDecoration(
          color: slot.type == AvailabilityType.cabinet ? const Color(0xFFE8EAF6) : const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: slot.type == AvailabilityType.cabinet ? const Color(0xFF3F51B5) : const Color(0xFF2196F3), width: 4)),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${slot.startTime}-${slot.endTime}',
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            Text(
              slot.type == AvailabilityType.cabinet ? 'Cabinet' : 'Télécons.',
              style: TextStyle(fontSize: 7, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
