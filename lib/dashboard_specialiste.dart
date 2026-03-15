import 'package:flutter/material.dart';
import 'package:sahtek/models/dashboard_models.dart';
import 'package:sahtek/services/dashboard_services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/widgets/planning_card.dart';

class DashboardSpecialistePage extends StatelessWidget {
  const DashboardSpecialistePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Logique de rafraîchissement si nécessaire
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: FutureBuilder<SpecialistStats>(
              future: SpecialistDashboardService.getStats(),
              initialData: SpecialistStats.zero(),
              builder: (context, snapshot) {
                final stats = snapshot.data ?? SpecialistStats.zero();
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(stats.doctorName),
                    const SizedBox(height: 32),

                    // Section Statistiques
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallStatCard(
                            'total_patients_label'.tr(),
                            '${stats.totalPatients}',
                            '${stats.patientGrowthPercent > 0 ? "+" : ""}${stats.patientGrowthPercent}%',
                            stats.patientGrowthPercent >= 0
                                ? Colors.green
                                : Colors.red,
                            isLoading: isLoading,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSmallStatCard(
                            'adherence_label'.tr(),
                            '${stats.adherencePercent}%',
                            '${stats.adherenceGrowthPercent > 0 ? "+" : ""}${stats.adherenceGrowthPercent}%',
                            stats.adherenceGrowthPercent >= 0
                                ? Colors.green
                                : Colors.red,
                            isLoading: isLoading,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSmallStatCard(
                            'alerts_label'.tr(),
                            '${stats.activeAlerts}',
                            '${stats.alertsGrowthPercent > 0 ? "+" : ""}${stats.alertsGrowthPercent}%',
                            stats.alertsGrowthPercent >= 0
                                ? Colors.green
                                : Colors.orange,
                            isAlert: true,
                            isLoading: isLoading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Card Gestion du planning
                    const PlanningCard(),

                    const SizedBox(height: 32),

                    // Section Rendez-vous du jour
                    _buildSectionHeader(
                      'todays_appointments'.tr(),
                      onViewAll: () {},
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<SpecialistAppointment>>(
                      future:
                          SpecialistDashboardService.getTodaysAppointments(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyState("no_appointments_today".tr());
                        }
                        return Column(
                          children: snapshot.data!
                              .map((app) => _buildAppointmentCard(app))
                              .toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Section Patients Récents
                    _buildSectionHeader(
                      'recent_patients'.tr(),
                      actionLabel: 'sort_by_rom'.tr(),
                      onViewAll: () {},
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<PatientFollowUp>>(
                      future: SpecialistDashboardService.getRecentPatients(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return _buildEmptyState("no_recent_patients".tr());
                        }
                        return Column(
                          children: snapshot.data!
                              .map((p) => _buildPatientFollowUpCard(p))
                              .toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String doctorName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=doc'),
              radius: 24,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'specialist_sahtech_badge'.tr(),
                  style: TextStyle(
                    color: Colors.blue[300],
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'hello_doctor'.tr(namedArgs: {'name': doctorName}),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildCircleContainer(Icons.notifications_none_outlined),
      ],
    );
  }

  Widget _buildCircleContainer(IconData icon) {
    return InkWell(
      onTap: () {
        print('Notifications cliquées');
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
    );
  }

  Widget _buildSmallStatCard(
    String label,
    String value,
    String growth,
    Color color, {
    bool isAlert = false,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                isAlert ? Icons.warning_amber : Icons.analytics_outlined,
                color: Colors.blue[200],
                size: 14,
              ),
              if (isLoading)
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                growth,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? actionLabel,
    required VoidCallback onViewAll,
  }) {
    final label = actionLabel ?? 'view_all'.tr();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF1A1C1E),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Color.fromARGB(255, 13, 84, 242),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[300], size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(SpecialistAppointment app) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              app.time,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color.fromARGB(255, 13, 84, 242),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  app.reason,
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  'score_imc_label'.tr(
                    namedArgs: {'score': app.score, 'imc': app.imc},
                  ),
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildPatientFollowUpCard(PatientFollowUp p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              p.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'rom_progress_label'.tr(
                        namedArgs: {'progress': p.romProgress.toString()},
                      ),
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'zone_label'.tr(namedArgs: {'zone': p.zone}),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: p.romProgress / 100,
                    backgroundColor: Colors.grey[100],
                    color: p.romProgress > 50 ? Colors.blue : Colors.redAccent,
                    minHeight: 6,
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
