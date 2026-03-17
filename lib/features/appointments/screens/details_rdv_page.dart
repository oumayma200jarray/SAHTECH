import 'package:flutter/material.dart';
import 'package:sahtek/models/appointment_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/core/widgets/buttons.dart';

class DetailsRdvPage extends StatelessWidget {
  const DetailsRdvPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)!.settings.arguments;

    if (args == null || args is! AppointmentModel) {
      return Scaffold(
        appBar: AppBar(title: Text('error_upper'.tr())),
        body: Center(child: Text('no_appointment_details'.tr())),
      );
    }

    final AppointmentModel app = args;

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
          'appointment_details'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildSpecialistCard(app),
            const SizedBox(height: 32),
            _buildInfoSection(app, context),
            const SizedBox(height: 48),
            _buildActionButtons(app, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialistCard(AppointmentModel app) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFE3EAFF),
            child: Text(
              app.specialistName.isNotEmpty ? app.specialistName[0].toUpperCase() : 'S',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D54F2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            app.specialistName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            app.specialty,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(AppointmentModel app, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'appointment_information'.tr(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        _buildInfoItem(
          Icons.calendar_today_outlined,
          'date'.tr(),
          DateFormat(
            'EEEE, dd MMMM yyyy',
            context.locale.languageCode,
          ).format(app.date),
        ),
        _buildInfoItem(Icons.access_time, 'time'.tr(), app.time),
        _buildInfoItem(
          Icons.videocam_outlined,
          'consultation_type'.tr(),
          app.type,
        ),
        _buildInfoItem(
          Icons.check_circle_outline,
          'status'.tr(),
          app.status,
          isStatus: true,
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    bool isStatus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              isStatus
                  ? Row(
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppointmentModel app, BuildContext context) {
    return Column(
      children: [
        if (app.type == 'Téléconsultation')
          buttonC(
            'join_call'.tr(),
            () {},
            icon: Icons.videocam,
          ),
        const SizedBox(height: 16),
        if (app.status != 'Annulé' && app.status != 'status_cancelled'.tr())
          buttonIn(
            'modify_cancel_appointment'.tr(),
            () {},
          ),
      ],
    );
  }
}
