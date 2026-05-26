import 'package:flutter/material.dart';
import 'package:sahtek/models/specialist_model.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:sahtek/core/utils/url_helper.dart';
import 'package:sahtek/features/specialists/services/specialist_service.dart';
import 'package:easy_localization/easy_localization.dart';

class SpecialisteDetailsPage extends StatefulWidget {
  const SpecialisteDetailsPage({Key? key}) : super(key: key);

  @override
  State<SpecialisteDetailsPage> createState() => _SpecialisteDetailsPageState();
}

class _SpecialisteDetailsPageState extends State<SpecialisteDetailsPage> {
  late Future<SpecialistModel?> _specialistFuture;
  String _userId = '';
  bool _didInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didInit) return;
    _didInit = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is String) {
      _userId = args;
    } else if (args is SpecialistModel) {
      _userId = args.userId;
    } else {
      _userId = '';
    }

    _specialistFuture = _userId.isEmpty
        ? Future.value(null)
        : SpecialistService.fetchSpecialistById(_userId);
  }

  Future<void> _refreshSpecialist() async {
    if (_userId.isEmpty) return;

    setState(() {
      _specialistFuture = SpecialistService.fetchSpecialistById(_userId);
    });

    await _specialistFuture;
  }

  @override
  Widget build(BuildContext context) {
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
          'specialist_details_title'.tr(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<SpecialistModel?>(
        future: _specialistFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final specialist = snapshot.data;
          if (specialist == null) {
            return RefreshIndicator(
              onRefresh: _refreshSpecialist,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Text(
                        'no_specialist_found'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshSpecialist,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFE3EAFF),
                          backgroundImage:
                              (specialist.user?.imageUrl ?? specialist.imageUrl)
                                  .isNotEmpty
                              ? NetworkImage(
                                  UrlHelper.fixImageUrl(
                                    specialist.user?.imageUrl ??
                                        specialist.imageUrl,
                                  ),
                                )
                              : null,
                          child:
                              (specialist.user?.imageUrl ?? specialist.imageUrl)
                                  .isEmpty
                              ? Text(
                                  (specialist.user?.fullName ??
                                              specialist.fullName ??
                                              'S')
                                          .isNotEmpty
                                      ? (specialist.user?.fullName ??
                                                specialist.fullName!)[0]
                                            .toUpperCase()
                                      : 'S',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D54F2),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          specialist.user?.fullName ??
                              specialist.fullName ??
                              '',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D54F2),
                          ),
                        ),
                        Text(
                          specialist.specialty,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // show gender, phone and location (if available)
                            _buildStatItem(
                              Icons.person,
                              Colors.blue,
                              specialist.user?.gender ?? '-',
                            ),
                            const SizedBox(width: 24),
                            _buildStatItem(
                              Icons.phone,
                              Colors.green,
                              specialist.user?.phone ?? '-',
                            ),
                            const SizedBox(width: 24),
                            _buildStatItem(
                              Icons.location_on,
                              Colors.red,
                              specialist.location ??
                                  '${specialist.latitude ?? '-'}, ${specialist.longitude ?? '-'}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'about_specialist'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (specialist.bio.trim().isNotEmpty)
                          Text(
                            specialist.bio,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        const SizedBox(height: 24),
                        // Clinics (API returns clinics list)
                        if (specialist.clinics != null &&
                            specialist.clinics!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'clinics'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final clinic in specialist.clinics!)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.local_hospital,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          clinic.name ??
                                              'no_primary_clinic'.tr(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          clinic.address ?? '',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ] else ...[
                          Row(
                            children: [
                              Icon(
                                Icons.business,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'no_primary_clinic'.tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Contact info
                        Text(
                          'contact_info'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                specialist.user?.email ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                specialist.user?.phone ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                specialist.user?.gender ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Coordinates
                        Text(
                          'coordinates'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.map, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lat: ${specialist.latitude ?? '-'}, Lng: ${specialist.longitude ?? '-'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
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
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<SpecialistModel?>(
        future: _specialistFuture,
        builder: (context, snapshot) {
          final specialist = snapshot.data;
          if (specialist == null) return const SizedBox.shrink();

          return Container(
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
              Navigator.pushNamed(
                context,
                '/reserver_rdv',
                arguments: specialist,
              );
            }),
          );
        },
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
