import 'package:flutter/material.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/models/appointment_model.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/providers/global_data_provider.dart';
import 'package:sahtek/core/widgets/custom_bottom_nav_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:sahtek/core/widgets/buttons.dart';

class MesRdvPage extends StatefulWidget {
  const MesRdvPage({Key? key}) : super(key: key);

  @override
  State<MesRdvPage> createState() => _MesRdvPageState();
}

class _MesRdvPageState extends State<MesRdvPage> {
  bool _isUpcoming = true;
  bool _isScrollRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<GlobalDataProvider>(
        context,
        listen: false,
      ).initializeAppointments(forceRefresh: true);
    });
  }

  Future<void> _refreshAppointments() async {
    await Provider.of<GlobalDataProvider>(
      context,
      listen: false,
    ).initializeAppointments(forceRefresh: true);
  }

  DateTime _appointmentDateTime(AppointmentModel app) {
    final hourParts = app.time.split(':');
    final hour = hourParts.isNotEmpty ? int.tryParse(hourParts[0]) ?? 0 : 0;
    final minute = hourParts.length > 1 ? int.tryParse(hourParts[1]) ?? 0 : 0;
    return DateTime(app.date.year, app.date.month, app.date.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final allAppointments = provider.appointments;

    final filteredAppointments = allAppointments.where((app) {
      final now = DateTime.now();
      final appDateTime = _appointmentDateTime(app);

      if (_isUpcoming) {
        return appDateTime.isAfter(now) || appDateTime.isAtSameMomentAs(now);
      }
      return appDateTime.isBefore(now);
    }).toList();

    filteredAppointments.sort((a, b) {
      final aDt = _appointmentDateTime(a);
      final bDt = _appointmentDateTime(b);
      if (_isUpcoming) {
        return aDt.compareTo(bDt);
      }
      return bDt.compareTo(aDt);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7FF),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(allAppointments.length),
                _buildTabSelector(),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.axis != Axis.vertical) {
                        return false;
                      }

                      final reachedBottom =
                          notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 24;

                      if (reachedBottom && !_isScrollRefreshing) {
                        _isScrollRefreshing = true;
                        _refreshAppointments().whenComplete(() {
                          _isScrollRefreshing = false;
                        });
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: _refreshAppointments,
                      child: filteredAppointments.isEmpty
                          ? _buildEmptyState()
                          : _buildAppointmentsList(filteredAppointments),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'my_appointments'.tr(),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFDAE7FF)),
                ),
                child: Text(
                  '$count rendez-vous',
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDAE7FF)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D54F2).withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF0D54F2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDAE7FF)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isUpcoming = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: _isUpcoming
                        ? const Color(0xFF0D54F2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.upcoming_outlined,
                        size: 16,
                        color: _isUpcoming
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'upcoming'.tr(),
                        style: TextStyle(
                          color: _isUpcoming
                              ? Colors.white
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isUpcoming = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: !_isUpcoming
                        ? const Color(0xFF0D54F2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 16,
                        color: !_isUpcoming
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'past'.tr(),
                        style: TextStyle(
                          color: !_isUpcoming
                              ? Colors.white
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<AppointmentModel> appointments) {
    if (_isUpcoming && appointments.isNotEmpty) {
      final nextApp = appointments.first;
      final others = appointments.skip(1).toList();

      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'next_appointment'.tr(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildNextAppointmentCard(nextApp),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              'other_appointments'.tr(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            ...others.map(_buildAppointmentListItem),
          ],
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: appointments.length,
      itemBuilder: (context, index) =>
          _buildAppointmentListItem(appointments[index]),
    );
  }

  Widget _buildNextAppointmentCard(AppointmentModel app) {
    final visual = _statusVisual(app.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: visual.headerGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: visual.primary.withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  UrlHelper.fixImageUrl(app.imageUrl),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.specialistName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      app.specialty,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(visual.icon, color: Colors.white, size: 11),
                    const SizedBox(width: 5),
                    Text(
                      _statusLabel(app.status).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  DateFormat(
                    'dd MMM yyyy',
                    context.locale.toString(),
                  ).format(app.date),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 24),
                const Icon(Icons.access_time, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(app.time, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          buttonIn(
            'appointment_details'.tr(),
            () => Navigator.pushNamed(context, '/details_rdv', arguments: app),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentListItem(AppointmentModel app) {
    final visual = _statusVisual(app.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: visual.tint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: visual.primary.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(color: visual.primary.withOpacity(0.08), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: visual.primary,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              UrlHelper.fixImageUrl(app.imageUrl),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: visual.primary.withOpacity(0.12),
                child: Icon(Icons.person, color: visual.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.specialistName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  DateFormat(
                    'dd MMM',
                    context.locale.toString(),
                  ).format(app.date).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  app.specialty,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 13, color: visual.primary),
                    const SizedBox(width: 4),
                    Text(
                      app.time,
                      style: TextStyle(
                        color: visual.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: visual.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(visual.icon, size: 11, color: visual.primary),
                          const SizedBox(width: 5),
                          Text(
                            _statusLabel(app.status).toUpperCase(),
                            style: TextStyle(
                              color: visual.primary,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    buttonIn(
                      'details_upper'.tr(),
                      () => Navigator.pushNamed(
                        context,
                        '/details_rdv',
                        arguments: app,
                      ),
                      width: 100,
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

  _StatusVisual _statusVisual(String status) {
    final normalized = status.trim().toUpperCase();
    switch (normalized) {
      case 'ACEPTED':
      case 'ACCEPTED':
        return const _StatusVisual(
          primary: Color(0xFF0D54F2),
          tint: Color(0xFFF3F7FF),
          headerGradient: [Color(0xFF0D54F2), Color(0xFF4B84FF)],
          icon: Icons.verified_rounded,
        );
      case 'SCHEDULED':
      case 'PENDING':
        return const _StatusVisual(
          primary: Color(0xFFF59E0B),
          tint: Color(0xFFFFFAEF),
          headerGradient: [Color(0xFFF59E0B), Color(0xFFFCC45C)],
          icon: Icons.schedule_rounded,
        );
      case 'REJECTED':
        return const _StatusVisual(
          primary: Color(0xFFDC2626),
          tint: Color(0xFFFFF3F3),
          headerGradient: [Color(0xFFDC2626), Color(0xFFEF4444)],
          icon: Icons.block_rounded,
        );
      case 'CANCELLED':
        return const _StatusVisual(
          primary: Color(0xFFB91C1C),
          tint: Color(0xFFFFF1F2),
          headerGradient: [Color(0xFFB91C1C), Color(0xFFEF4444)],
          icon: Icons.cancel_rounded,
        );
      case 'COMPLETED':
        return const _StatusVisual(
          primary: Color(0xFF16A34A),
          tint: Color(0xFFF2FFF7),
          headerGradient: [Color(0xFF16A34A), Color(0xFF34D399)],
          icon: Icons.task_alt_rounded,
        );
      default:
        return const _StatusVisual(
          primary: Color(0xFF64748B),
          tint: Color(0xFFF8FAFC),
          headerGradient: [Color(0xFF64748B), Color(0xFF94A3B8)],
          icon: Icons.info_outline_rounded,
        );
    }
  }

  String _statusLabel(String status) {
    final normalized = status.trim().toUpperCase();
    switch (normalized) {
      case 'SCHEDULED':
        return 'En attente';
      case 'ACEPTED':
      case 'ACCEPTED':
        return 'Confirmé';
      case 'REJECTED':
        return 'Refusé';
      case 'COMPLETED':
        return 'Terminé';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status;
    }
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: 360,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 64,
                  color: Colors.grey.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  _isUpcoming
                      ? 'no_upcoming_appointments'.tr()
                      : 'no_past_appointments'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusVisual {
  final Color primary;
  final Color tint;
  final List<Color> headerGradient;
  final IconData icon;

  const _StatusVisual({
    required this.primary,
    required this.tint,
    required this.headerGradient,
    required this.icon,
  });
}
