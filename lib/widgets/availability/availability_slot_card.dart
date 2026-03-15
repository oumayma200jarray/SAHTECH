import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/models/availability_model.dart';
import 'package:sahtek/widgets/buttons.dart';

class AvailabilitySlotCard extends StatelessWidget {
  final AvailabilitySlot slot;
  final VoidCallback? onEdit;

  const AvailabilitySlotCard({Key? key, required this.slot, this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDayLabel(slot.dayOfWeek),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slot.startTime} — ${slot.endTime}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              _buildTypeBadge(slot.type),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: buttonIn(
                  'Modifier',
                  onEdit ?? () {},
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  Provider.of<GlobalDataProvider>(context, listen: false).removeAvailabilitySlot(slot.id);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDayLabel(int day) {
    switch (day) {
      case 1: return 'Lundi 14 Oct.';
      case 2: return 'Mardi 15 Oct.';
      case 3: return 'Mercredi 16 Oct.';
      case 4: return 'Jeudi 17 Oct.';
      case 5: return 'Vendredi 18 Oct.';
      case 6: return 'Samedi 19 Oct.';
      case 7: return 'Dimanche 20 Oct.';
      default: return 'Inconnu';
    }
  }

  Widget _buildTypeBadge(AvailabilityType type) {
    final bool isCabinet = type == AvailabilityType.cabinet;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCabinet ? const Color(0xFFE8EAF6) : const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCabinet ? 'CABINET' : 'VIDÉO',
        style: TextStyle(
          color: isCabinet ? const Color(0xFF3F51B5) : const Color(0xFF2196F3),
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
