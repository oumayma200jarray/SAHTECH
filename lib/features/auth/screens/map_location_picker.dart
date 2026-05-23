import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;

  const MapLocationPicker({super.key, this.initialLocation});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  static const _tunisDefault = LatLng(36.8065, 10.1815);

  final MapController _mapController = MapController();
  LatLng? _selected;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selected = widget.initialLocation;
    } else {
      _fetchCurrentLocation();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _selected = loc);
      _mapController.move(loc, 15);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Color(0xFF0A0F1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'pick_location_title'.tr(),
          style: const TextStyle(
            color: Color(0xFF0A0F1E),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation ?? _tunisDefault,
              initialZoom: 13,
              onTap: (_, point) => setState(() => _selected = point),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sahtek',
              ),
              if (_selected != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected!,
                      width: 40,
                      height: 52,
                      child: _PinMarker(),
                    ),
                  ],
                ),
            ],
          ),

          // Top hint / coordinates bar
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: _InfoBar(selected: _selected),
          ),

          // GPS / my-location button
          Positioned(
            bottom: _selected != null ? 96 : 24,
            right: 16,
            child: _MyLocationButton(
              loading: _locating,
              onPressed: _fetchCurrentLocation,
            ),
          ),

          // Confirm button
          if (_selected != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _ConfirmButton(
                onPressed: () => Navigator.pop(context, _selected),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinMarker extends StatelessWidget {
  static const blue = Color(0xFF0052FF);
  static const skyBlue = Color(0xFF00A3FF);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [blue, skyBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: blue.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Iconsax.location, color: Colors.white, size: 20),
        ),
        Container(
          width: 2,
          height: 12,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [blue, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBar extends StatelessWidget {
  final LatLng? selected;

  const _InfoBar({required this.selected});

  static const blue = Color(0xFF0052FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Iconsax.map_1, color: blue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: selected == null
                ? Text(
                    'tap_map_hint'.tr(),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  )
                : Text(
                    '${selected!.latitude.toStringAsFixed(6)},  ${selected!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: Color(0xFF0A0F1E),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MyLocationButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;

  static const blue = Color(0xFF0052FF);

  const _MyLocationButton({required this.loading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black12,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: loading ? null : onPressed,
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: blue,
                  ),
                )
              : const Icon(Iconsax.gps, color: blue, size: 22),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onPressed;

  static const blue = Color(0xFF0052FF);
  static const skyBlue = Color(0xFF00A3FF);

  const _ConfirmButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [blue, skyBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'confirm_location'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
