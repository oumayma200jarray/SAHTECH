import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:sahtek/core/utils/navigation_utils.dart';
import 'package:sahtek/features/profile/controller/profile_controller.dart';
import 'package:sahtek/models/patient_model.dart';
import 'package:sahtek/features/specialists/services/specialist_service.dart';
import 'package:sahtek/features/specialists/widgets/patient_card.dart';
import 'package:sahtek/core/widgets/specialist_bottom_nav_bar.dart';

class ListePatientsPage extends StatefulWidget {
  const ListePatientsPage({Key? key}) : super(key: key);

  @override
  State<ListePatientsPage> createState() => _ListePatientsPageState();
}

class _ListePatientsPageState extends State<ListePatientsPage> {
  final TextEditingController _searchController = TextEditingController();

  List<PatientModel> _allPatients = [];
  List<PatientModel> _filteredPatients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadPatients() async {
    final patients = await SpecialistService.fetchMyPatients();
    if (mounted) {
      setState(() {
        _allPatients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _filteredPatients = SpecialistService.searchPatients(
        _allPatients,
        _searchController.text,
      );
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
              onPressed: () {
                final role = context.read<ProfileController>().role;
                NavigationUtils.navigateToDashboard(context, role);
              },
            ),
          ),
        ),
        title: Text(
          'patient_list_title'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0D54F2)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPatients,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ──────────────────────────────────────────
              Text(
                'management_portal'.tr(),
                style: TextStyle(
                  color: Colors.blue[400],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'patients_heading'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Search Bar ──────────────────────────────────────
              _buildSearchBar(),
              const SizedBox(height: 24),

              // ─── Patient List ────────────────────────────────────
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0D54F2),
                    ),
                  ),
                )
              else if (_filteredPatients.isEmpty)
                _buildEmptyState()
              else
                ..._filteredPatients.map(
                  (patient) => PatientCard(
                    patient: patient,
                    onAddMedicalFolder: () {
                      Navigator.pushNamed(
                        context,
                        '/specialist_medical_folder',
                        arguments: patient,
                      );
                    },
                    onAddExercise: () {
                      Navigator.pushNamed(
                        context,
                        '/publier_exercice',
                        arguments: patient,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SpecialistBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'search_patient_hint'.tr(),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, color: Colors.grey[300], size: 48),
          const SizedBox(height: 16),
          Text(
            'no_patients_found'.tr(),
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
