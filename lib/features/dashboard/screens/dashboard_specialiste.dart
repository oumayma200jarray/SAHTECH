// Redesigned following SAHTECK brand guidelines

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sahtek/core/services/storage_service.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/core/widgets/role_gate.dart';
import 'package:sahtek/core/widgets/specialist_bottom_nav_bar.dart';
import 'package:sahtek/features/dashboard/screens/nouvelle_publication.dart';
import 'package:sahtek/features/dashboard/services/dashboard_services.dart';
import 'package:sahtek/models/content_model.dart';
import 'package:sahtek/models/dashboard_models.dart';
import 'package:sahtek/models/doctor_models.dart';
import 'package:sahtek/services/chat_service.dart';

class DashboardSpecialistePage extends StatefulWidget {
  const DashboardSpecialistePage({super.key});

  @override
  State<DashboardSpecialistePage> createState() =>
      _DashboardSpecialistePageState();
}

class _DashboardSpecialistePageState extends State<DashboardSpecialistePage> {
  List<bool> _isSelected = [true, false];
  late Future<_DashboardData> _dashboardFuture;
  String? _heroImageUrl;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
    _loadHeroImage();
  }

  Future<void> _loadHeroImage() async {
    final imageUrl = await StorageService.getImageUrl();
    if (!mounted) return;
    setState(() {
      _heroImageUrl = UrlHelper.fixImageUrl(imageUrl ?? '');
    });
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _dashboardFuture = _loadDashboardData();
    });
    await _dashboardFuture;
  }

  Future<_DashboardData> _loadDashboardData() async {
    final results = await Future.wait<dynamic>([
      SpecialistDashboardService.getStats(),
      ChatRestService.getUnreadCount(),
      SpecialistDashboardService.getDoctorAppointments(),
      SpecialistDashboardService.getAllPatients(),
      SpecialistDashboardService.getRecentDocuments(),
    ]);

    return _DashboardData(
      stats: results[0] as SpecialistStats,
      unreadCount: results[1] as int,
      appointments: results[2] as List<DoctorAppointmentModel>,
      patients: results[3] as List<DoctorPatientModel>,
      documents: results[4] as List<ContentModel>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleGate(
      allowedRoles: const ['SPECIALIST', 'SPECIALISTE', 'DOCTOR'],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        bottomNavigationBar: const SpecialistBottomNavBar(currentIndex: 0),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: FutureBuilder<_DashboardData>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                final data = snapshot.data ?? _DashboardData.empty();
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    _buildModeToggle(context),
                    const SizedBox(height: 14),
                    _buildHeroCard(context, data.stats.doctorName),
                    const SizedBox(height: 14),
                    _buildOverviewGrid(context, data),
                    const SizedBox(height: 16),
                    _buildQuickAccessSection(context),
                    const SizedBox(height: 16),
                    _buildAppointmentsSection(
                      context,
                      data.upcomingAppointments,
                    ),
                    const SizedBox(height: 16),
                    _buildPatientsSection(context, data.patients),
                    const SizedBox(height: 16),
                    _buildDocumentsSection(context, data.documents),
                    const SizedBox(height: 16),
                    _buildNewPublicationButton(context),
                    if (isLoading) ...[
                      const SizedBox(height: 12),
                      const LinearProgressIndicator(minHeight: 2),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, String doctorName) {
    final doctorInitial = doctorName.trim().isNotEmpty
        ? doctorName.trim()[0].toUpperCase()
        : 'U';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Image(
                image: AssetImage('assets/logo/logo.png'),
                width: 52,
                height: 52,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 21,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      _heroImageUrl != null && _heroImageUrl!.isNotEmpty
                      ? NetworkImage(_heroImageUrl!)
                      : null,
                  child: _heroImageUrl == null || _heroImageUrl!.isEmpty
                      ? Text(
                          doctorInitial,
                          style: const TextStyle(
                            color: Color(0xFF0052FF),
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'specialist_sahtech_badge'.tr(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'hello_doctor'.tr(namedArgs: {'name': doctorName}),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t(
              context,
              fr: 'Vue claire des patients, rendez-vous, messages et contenus.',
              en: 'Clear view of patients, appointments, messages and content.',
            ),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewGrid(BuildContext context, _DashboardData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.16,
      children: [
        _buildStatTile(
          label: _t(context, fr: 'Patients', en: 'Patients'),
          value: data.stats.totalPatients.toString(),
          subtitle: _t(
            context,
            fr: 'depuis le serveur',
            en: 'from API response',
          ),
          icon: Iconsax.user,
          color: const Color(0xFF0052FF),
        ),
        _buildStatTile(
          label: _t(context, fr: 'RDV à venir', en: 'Upcoming RDVs'),
          value: data.upcomingAppointments.length.toString(),
          subtitle: _t(context, fr: 'programmés', en: 'scheduled'),
          icon: Iconsax.calendar_1,
          color: const Color(0xFF10B981),
        ),
        _buildStatTile(
          label: _t(context, fr: 'Messages', en: 'Messages'),
          value: data.unreadCount.toString(),
          subtitle: _t(context, fr: 'non lus', en: 'unread'),
          icon: Iconsax.sms,
          color: const Color(0xFFF59E0B),
        ),
        _buildStatTile(
          label: _t(context, fr: 'Publications', en: 'Posts'),
          value: data.documents.length.toString(),
          subtitle: _t(context, fr: 'récentes', en: 'recent'),
          icon: Iconsax.activity,
          color: const Color(0xFFE14C4C),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0052FF).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0052FF)),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0A0F1E),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final actions = [
      _QuickAction(
        label: _t(context, fr: 'Patients', en: 'Patients'),
        icon: Iconsax.user,
        route: '/liste_patients',
      ),
      _QuickAction(
        label: _t(context, fr: 'Planning', en: 'Planning'),
        icon: Iconsax.calendar_1,
        route: '/gestion_disponibilites',
      ),
      _QuickAction(
        label: _t(context, fr: 'Messages', en: 'Messages'),
        icon: Iconsax.sms,
        route: '/messagerie',
      ),
      _QuickAction(
        label: _t(context, fr: 'Profil', en: 'Profile'),
        icon: Iconsax.user,
        route: '/profile',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          _t(context, fr: 'Accès rapides', en: 'Quick access'),
          onViewAll: () => Navigator.pushNamed(context, '/liste_patients'),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) =>
              _buildQuickActionCard(context, actions[index]),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, _QuickAction action) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, action.route),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0052FF).withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(action.icon, color: const Color(0xFF0052FF)),
            ),
            const SizedBox(height: 10),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0F1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsSection(
    BuildContext context,
    List<DoctorAppointmentModel> appointments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          _t(context, fr: 'Rendez-vous', en: 'Appointments'),
          onViewAll: () =>
              Navigator.pushNamed(context, '/gestion_disponibilites'),
        ),
        const SizedBox(height: 12),
        if (appointments.isEmpty)
          _buildEmptyState(
            _t(
              context,
              fr: 'Aucun rendez-vous à venir',
              en: 'No upcoming appointments',
            ),
          )
        else
          Column(
            children: appointments
                .take(3)
                .map(
                  (appointment) => _buildAppointmentCard(context, appointment),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    DoctorAppointmentModel appointment,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0052FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('HH:mm').format(appointment.startTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF0052FF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM').format(appointment.date),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appointment.patientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(appointment.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  appointment.place,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
                if (_clinicText(appointment).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _clinicText(appointment),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientsSection(
    BuildContext context,
    List<DoctorPatientModel> patients,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          _t(context, fr: 'Patients', en: 'Patients'),
          onViewAll: () => Navigator.pushNamed(context, '/liste_patients'),
        ),
        const SizedBox(height: 12),
        if (patients.isEmpty)
          _buildEmptyState(
            _t(context, fr: 'Aucun patient trouvé', en: 'No patients found'),
          )
        else
          Column(
            children: patients
                .take(4)
                .map((patient) => _buildPatientCard(context, patient))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildPatientCard(BuildContext context, DoctorPatientModel patient) {
    final details = patient.patientDetails;
    final initials = patient.fullName.trim().isNotEmpty
        ? patient.fullName.trim()[0].toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF0052FF).withOpacity(0.12),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF0052FF),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  patient.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  patient.phone,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
              ],
            ),
          ),
          if (details != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _t(context, fr: 'Âge', en: 'Age'),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                ),
                Text(
                  '${details.age}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context, List<ContentModel> docs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          _t(context, fr: 'Publications récentes', en: 'Recent posts'),
          onViewAll: () => Navigator.pushNamed(context, '/accueil'),
        ),
        const SizedBox(height: 12),
        if (docs.isEmpty)
          _buildEmptyState(
            _t(
              context,
              fr: 'Aucune publication récente',
              en: 'No recent posts',
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildDocumentCard(docs[index]),
          ),
      ],
    );
  }

  Widget _buildDocumentCard(ContentModel doc) {
    final isVideo = doc.videoUrl != null && doc.videoUrl!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isVideo
                      ? const Color(0xFFE14C4C).withOpacity(0.12)
                      : const Color(0xFF0052FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isVideo ? Iconsax.video_play : Iconsax.activity,
                  color: isVideo
                      ? const Color(0xFFE14C4C)
                      : const Color(0xFF0052FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: Color(0xFF0A0F1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVideo
                          ? _t(context, fr: 'Vidéo', en: 'Video')
                          : _t(context, fr: 'Article', en: 'Article'),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewPublicationButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NouvellePublicationPage(),
          ),
        );
        if (result == true) {
          _refreshDashboard();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.add, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'new_publication'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'publish_article_video'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF0A0F1E),
          ),
        ),
        title != "Accès rapides" && title != "Quick access"
            ? TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _t(context, fr: 'Voir tout', en: 'View all'),
                  style: const TextStyle(
                    color: Color(0xFF0052FF),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : SizedBox(height: 0),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Iconsax.info_circle, color: Colors.grey[300], size: 36),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCE7FF)),
        ),
        child: ToggleButtons(
          isSelected: _isSelected,
          onPressed: (int index) {
            if (index == 1) {
              Navigator.pushReplacementNamed(context, '/accueil');
            } else {
              setState(() {
                _isSelected = [true, false];
              });
            }
          },
          borderRadius: BorderRadius.circular(16),
          selectedColor: Colors.white,
          fillColor: const Color(0xFF0052FF),
          color: Colors.grey[600],
          constraints: BoxConstraints(
            minHeight: 40,
            minWidth: (MediaQuery.of(context).size.width - 50) / 2,
          ),
          children: [
            Text(
              'mode_specialist'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              'mode_patient'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _clinicText(DoctorAppointmentModel appointment) {
    if (appointment.clinicName.isNotEmpty &&
        appointment.clinicAddress.isNotEmpty) {
      return '${appointment.clinicName} • ${appointment.clinicAddress}';
    }
    if (appointment.clinicName.isNotEmpty) return appointment.clinicName;
    return appointment.place;
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACEPTED':
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _t(BuildContext context, {required String fr, required String en}) {
    return context.locale.languageCode == 'fr' ? fr : en;
  }
}

class _DashboardData {
  final SpecialistStats stats;
  final int unreadCount;
  final List<DoctorAppointmentModel> appointments;
  final List<DoctorPatientModel> patients;
  final List<ContentModel> documents;

  const _DashboardData({
    required this.stats,
    required this.unreadCount,
    required this.appointments,
    required this.patients,
    required this.documents,
  });

  factory _DashboardData.empty() {
    return _DashboardData(
      stats: SpecialistStats.zero(),
      unreadCount: 0,
      appointments: const [],
      patients: const [],
      documents: const [],
    );
  }

  List<DoctorAppointmentModel> get upcomingAppointments {
    final now = DateTime.now();
    final items = appointments
        .where((item) => item.startTime.isAfter(now))
        .toList();
    items.sort((a, b) => a.startTime.compareTo(b.startTime));
    return items;
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String route;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });
}
