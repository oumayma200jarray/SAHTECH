import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/models/availability_model.dart';
import 'package:sahtek/widgets/buttons.dart';
import 'package:sahtek/widgets/availability/availability_calendar_grid.dart';
import 'package:sahtek/widgets/availability/availability_slot_card.dart';

class GestionDisponibilitesPage extends StatelessWidget {
  const GestionDisponibilitesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final slots = provider.availabilitySlots;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'availability_mgmt_title'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'availability_mgmt_subtitle'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildSyncBadge(),
            const SizedBox(height: 24),
            AvailabilityCalendarGrid(slots: slots),
            const SizedBox(height: 32),
            _buildSectionHeader('weekly_slots'.tr()),
            const SizedBox(height: 16),
            ...slots.map((slot) => AvailabilitySlotCard(
              slot: slot,
              onEdit: () => _showSlotDialog(context, existingSlot: slot),
            )).toList(),
            _buildAddSlotPlaceholder(context),
            const SizedBox(height: 24),
            _buildInfoBox(),
            const SizedBox(height: 32),
            _buildSaveButton(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sync, color: Color(0xFF2E7D32), size: 16),
          const SizedBox(width: 8),
          Text(
            'sync_with_patient_page'.tr(),
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildAddSlotPlaceholder(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      child: buttonIn(
        'add_slot'.tr(),
        () => _showSlotDialog(context),
      ),
    );
  }

  void _showSlotDialog(BuildContext context, {AvailabilitySlot? existingSlot}) {
    showDialog(
      context: context,
      builder: (context) => _SlotDialog(existingSlot: existingSlot),
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

  Widget _buildSaveButton(BuildContext context) {
    return buttonC(
      'save_modifications'.tr(),
      () => Navigator.pop(context),
      icon: Icons.save,
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
  late AvailabilityType type;

  @override
  void initState() {
    super.initState();
    dayOfWeek = widget.existingSlot?.dayOfWeek ?? 1;
    startTime = widget.existingSlot?.startTime ?? '09:00';
    endTime = widget.existingSlot?.endTime ?? '12:00';
    type = widget.existingSlot?.type ?? AvailabilityType.cabinet;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingSlot == null ? 'Ajouter un créneau' : 'Modifier le créneau'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: dayOfWeek,
            items: List.generate(7, (i) => DropdownMenuItem(value: i + 1, child: Text(_getDayName(i + 1)))),
            onChanged: (v) => setState(() => dayOfWeek = v!),
            decoration: const InputDecoration(labelText: 'Jour'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: startTime),
                  decoration: const InputDecoration(labelText: 'Début (HH:MM)'),
                  onChanged: (v) => startTime = v,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: endTime),
                  decoration: const InputDecoration(labelText: 'Fin (HH:MM)'),
                  onChanged: (v) => endTime = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Type: '),
              ChoiceChip(
                label: const Text('Cabinet'),
                selected: type == AvailabilityType.cabinet,
                onSelected: (s) => setState(() => type = AvailabilityType.cabinet),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Vidéo'),
                selected: type == AvailabilityType.video,
                onSelected: (s) => setState(() => type = AvailabilityType.video),
              ),
            ],
          ),
        ],
      ),
      actions: [
        buttonIn(
          'Annuler',
          () => Navigator.pop(context),
          width: 100,
        ),
        buttonC(
          'Valider',
          () {
            final provider = Provider.of<GlobalDataProvider>(context, listen: false);
            final slot = AvailabilitySlot(
              id: widget.existingSlot?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
              dayOfWeek: dayOfWeek,
              startTime: startTime,
              endTime: endTime,
              type: type,
            );
            if (widget.existingSlot == null) {
              provider.addAvailabilitySlot(slot);
            } else {
              provider.updateAvailabilitySlot(slot);
            }
            Navigator.pop(context);
          },
          width: 120,
        ),
      ],
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
  }
}
