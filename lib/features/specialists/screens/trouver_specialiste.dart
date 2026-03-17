import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sahtek/models/specialist_model.dart';
import 'package:sahtek/features/specialists/services/specialist_service.dart';
import 'package:sahtek/core/widgets/buttons.dart';
import 'package:sahtek/core/widgets/custom_bottom_nav_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';

class TrouverSpecialistePage extends StatefulWidget {
  const TrouverSpecialistePage({Key? key}) : super(key: key);

  @override
  State<TrouverSpecialistePage> createState() => _TrouverSpecialistePageState();
}

class _TrouverSpecialistePageState extends State<TrouverSpecialistePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(
    text: 'Tunisie',
  );

  bool _isMapFull = false;

  List<SpecialistModel> _allSpecialists = [];
  List<SpecialistModel> _filteredSpecialists = [];
  LatLng? _userLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    SpecialistService.fetchSpecialists().then((list) {
      if (mounted) {
        setState(() {
          _allSpecialists = list;
          _filteredSpecialists = list;
        });
      }
    });

    _searchController.addListener(_onSearchChanged);
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_userLocation!, 13.0);
      }
    } catch (e) {
      print("Erreur de localisation: $e");
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSpecialists = _allSpecialists.where((spec) {
        final nameMatches = spec.name.toLowerCase().contains(query);
        final specialtyMatches = spec.specialty.toLowerCase().contains(query);
        final clinicMatches = spec.clinic.toLowerCase().contains(query);
        return nameMatches || specialtyMatches || clinicMatches;
      }).toList();

      // Si un seul résultat est trouvé ou si la liste change, on peut centrer la carte sur le premier résultat
      if (_filteredSpecialists.isNotEmpty && query.isNotEmpty) {
        _mapController.move(
          LatLng(
            _filteredSpecialists.first.latitude,
            _filteredSpecialists.first.longitude,
          ),
          13.0,
        );
      }
    });
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
                color: Color.fromARGB(255, 13, 84, 242),
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'find_specialist_title'.tr(),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.tune,
              color: Color.fromARGB(255, 13, 84, 242),
            ),
            onPressed: () {
              print('Filtre des spécialistes cliqué');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Section Recherche (masquée en mode plein écran)
          if (!_isMapFull)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchInput(
                    controller: _searchController,
                    hint: 'search_specialist_hint'.tr(),
                    icon: Icons.search,
                  ),
                  const SizedBox(height: 12),
                  _buildSearchInput(
                    controller: _locationController,
                    hint: 'location_hint'.tr(),
                    icon: Icons.location_on_outlined,
                    suffix: TextButton(
                      onPressed: () {
                        print('Localisation / Autour de moi cliqué');
                        _determinePosition();
                      },
                      child: Text(
                        'around_me'.tr(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Section Carte (FlutterMap)
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        _userLocation ??
                        const LatLng(36.8065, 10.1815), // Tunis par défaut
                    initialZoom: 13.0,
                  ),
                  mapController: _mapController,
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.sahtek',
                    ),
                    MarkerLayer(
                      markers: _filteredSpecialists.map((spec) {
                        return Marker(
                          point: LatLng(spec.latitude, spec.longitude),
                          width: 80,
                          height: 80,
                          child: GestureDetector(
                            onTap: () {
                              // Action au clic sur un marqueur
                              print("Clic sur : ${spec.name}");
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      13,
                                      84,
                                      242,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    spec.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const Icon(
                                  Icons.location_on,
                                  color: Color.fromARGB(255, 13, 84, 242),
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _userLocation!,
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.redAccent,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // Overlay de la liste (bas de page)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildSpecialistListOverlay(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 1,
      ), // Index Specialists
    );
  }

  Widget _buildSearchInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          prefixIcon: Icon(
            icon,
            color: const Color.fromARGB(255, 13, 84, 242),
            size: 20,
          ),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSpecialistListOverlay() {
    final specialistsForList = _filteredSpecialists;

    if (_isMapFull) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
        ),
        child: Center(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isMapFull = false),
              icon: const Icon(Icons.list, size: 18),
              label: Text(
                'reduce_map_view_list'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 13, 84, 242),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 320,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${specialistsForList.length} ${'specialists_found'.tr()}\n${'kinesitherapists_in_tunisia'.tr()}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _isMapFull = true),
                  child: Text(
                    'view_on_map'.tr(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: specialistsForList.isEmpty
                ? Center(child: Text('no_specialist_found'.tr()))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: specialistsForList.length,
                    itemBuilder: (context, index) {
                      final spec = specialistsForList[index];
                      return _buildSpecialistCard(spec);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialistCard(SpecialistModel spec) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  spec.imageUrl, // Corrected to use spec.imageUrl directly
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
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
                        Expanded(
                          child: Text(
                            spec.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                spec.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      spec.specialty,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${spec.distance} km • ${spec.availability}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: buttonC('details_upper'.tr(), () {
              Navigator.pushNamed(
                context,
                '/specialiste_details',
                arguments: spec,
              );
            }),
          ),
        ],
      ),
    );
  }
}
