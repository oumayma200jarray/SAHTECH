import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalDataProvider>(context);
    final allAppointments = provider.appointments;

    final filteredAppointments = allAppointments.where((app) {
      final now = DateTime.now();

      // Combiner date et heure pour la comparaison
      final hourParts = app.time.split(':');
      final appDateTime = DateTime(
        app.date.year,
        app.date.month,
        app.date.day,
        int.parse(hourParts[0]),
        int.parse(hourParts[1]),
      );

      if (_isUpcoming) {
        // À venir : Date/Heure est dans le futur ou maintenant
        return appDateTime.isAfter(now) || appDateTime.isAtSameMomentAs(now);
      } else {
        // Passés : Date/Heure est déjà passée
        return appDateTime.isBefore(now);
      }
    }).toList();

    // Trier par date et heure combinées
    filteredAppointments.sort((a, b) {
      final aDt = DateTime(
        a.date.year,
        a.date.month,
        a.date.day,
        int.parse(a.time.split(':')[0]),
        int.parse(a.time.split(':')[1]),
      );
      final bDt = DateTime(
        b.date.year,
        b.date.month,
        b.date.day,
        int.parse(b.time.split(':')[0]),
        int.parse(b.time.split(':')[1]),
      );

      if (_isUpcoming) {
        return aDt.compareTo(bDt); // Plus proche en premier
      } else {
        return bDt.compareTo(aDt); // Plus récent en premier
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabSelector(),
            Expanded(
              child: filteredAppointments.isEmpty
                  ? _buildEmptyState()
                  : _buildAppointmentsList(filteredAppointments),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'my_appointments'.tr(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D1D),
            ),
          ),
          InkWell(
            onTap: () {
              print('Notifications cliquées');
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.notifications_outlined),
                color: Colors.blue,
                onPressed: () {
                  Navigator.pushNamed(context, '/notifications');
                },
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
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isUpcoming = true),
                child: Container(
                  decoration: BoxDecoration(
                    color: _isUpcoming ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'upcoming'.tr(),
                    style: TextStyle(
                      color: _isUpcoming ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isUpcoming = false),
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isUpcoming ? Colors.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'past'.tr(),
                    style: TextStyle(
                      color: !_isUpcoming ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
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
    // Si on est dans "À venir", on affiche le premier en "PROCHAIN RENDEZ-VOUS"
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
            ...others.map((app) => _buildAppointmentListItem(app)).toList(),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D54F2), Color(0xFF4B84FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
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
                  app.imageUrl,
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
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'confirmed'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              app.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.person, color: Colors.blue),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(app.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        app.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(app.status),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
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

  Color _getStatusColor(String status) {
    if (status == 'Confirmé' || status == 'status_confirmed'.tr()) {
      return Colors.blue;
    } else if (status == 'En attente' || status == 'status_pending'.tr()) {
      return Colors.orange;
    } else if (status == 'Annulé' || status == 'status_cancelled'.tr()) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Center(
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
    );
  }
}
