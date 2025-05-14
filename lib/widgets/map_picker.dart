import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../core/config/app_config.dart';

class MapPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final Function(LatLng) onLocationSelected;

  const MapPicker({
    Key? key,
    this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      if (widget.initialLocation != null) {
        _selectedLocation = widget.initialLocation;
      } else {
        final position = await Geolocator.getCurrentPosition();
        _selectedLocation = LatLng(position.latitude, position.longitude);
      }
      setState(() => _isLoading = false);
    } catch (e) {
      // If location permission is denied or error occurs, use default location
      _selectedLocation = LatLng(
        AppConfig.defaultLatitude,
        AppConfig.defaultLongitude,
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation!,
              initialZoom: AppConfig.defaultZoom,
              onTap: (_, point) {
                setState(() {
                  _selectedLocation = point;
                });
                widget.onLocationSelected(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.reservationterrain',
              ),
              MarkerLayer(
                markers: [
                  if (_selectedLocation != null)
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Appuyez sur la carte pour sélectionner l\'emplacement',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
} 