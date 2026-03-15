import 'package:flutter/material.dart';
import 'package:sahtek/models/specialist_model.dart';
import 'package:sahtek/widgets/buttons.dart';
import 'package:easy_localization/easy_localization.dart';

class SpecialisteDetailsPage extends StatelessWidget {
  const SpecialisteDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final specialist = ModalRoute.of(context)!.settings.arguments as SpecialistModel;

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
          'specialist_details_title'.tr(),
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image & Info
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFFE3EAFF),
                    child: Text(
                      specialist.name.isNotEmpty ? specialist.name[0].toUpperCase() : 'S',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D54F2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    specialist.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0D54F2)),
                  ),
                  Text(
                    specialist.specialty,
                    style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(Icons.star, Colors.amber, '${specialist.rating}'),
                      const SizedBox(width: 24),
                      _buildStatItem(Icons.people, Colors.blue, '${specialist.reviewsCount} reviews'),
                      const SizedBox(width: 24),
                      _buildStatItem(Icons.location_on, Colors.red, specialist.location),
                    ],
                  ),
                ],
              ),
            ),
            
            // About Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'about_specialist'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'specialist_bio_placeholder'.tr(namedArgs: {'name': specialist.name}),
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Location & Clinic
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        specialist.clinic,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: buttonC('book_now'.tr(), () {
          Navigator.pushNamed(context, '/reserver_rdv', arguments: specialist);
        }),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String text) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
