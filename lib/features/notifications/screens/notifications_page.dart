import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool exercisesReminders = true;
  bool newMessages = true;
  bool appointmentConfirmations = true;
  bool progressAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'notification_settings'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('push_notifications'.tr()),
            _buildNotificationSwitch(
              Icons.directions_run_outlined,
              'daily_exercises_reminders'.tr(),
              'never_miss_session'.tr(),
              exercisesReminders,
              (v) => setState(() => exercisesReminders = v),
              extra: Row(
                children: [
                  Text(
                    'reminder_time'.tr(),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      '08:30',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildNotificationSwitch(
              Icons.chat_bubble_outline,
              'new_messages'.tr(),
              'from_health_specialist'.tr(),
              newMessages,
              (v) => setState(() => newMessages = v),
            ),
            _buildNotificationSwitch(
              Icons.calendar_today_outlined,
              'appointment_confirmations'.tr(),
              'validations_and_reminders'.tr(),
              appointmentConfirmations,
              (v) => setState(() => appointmentConfirmations = v),
            ),
            _buildNotificationSwitch(
              Icons.trending_up,
              'progress_alerts'.tr(),
              'tracking_objectives'.tr(),
              progressAlerts,
              (v) => setState(() => progressAlerts = v),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'notifications_help_desc'.tr(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.blue,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'version'.tr().toUpperCase(),
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    Widget? extra,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.blue,
              ),
            ],
          ),
          if (extra != null) ...[const Divider(height: 1), extra],
        ],
      ),
    );
  }
}
