import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../services/api_service.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends State<LocationPickerScreen> {
  LatLng? selectedLocation;
  String? address;

  final ApiService _apiService = ApiService();

  Future<void> reverseGeocode(
    double lat,
    double lng,
  ) async {
    try {
      final data = await _apiService.get(
        '/locations/reverse',
        queryParameters: {
          'lat': lat.toString(),
          'lng': lng.toString(),
        },
      );

      if (!mounted) return;

      setState(() {
        address = data['formattedAddress'] as String?;
      });
    } on ApiException catch (e) {
      debugPrint('Erro da API: ${e.message}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar localização'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(
                  -24.0463,
                  -52.378,
                ),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onTap: (tapPosition, point) async {
                  setState(() {
                    selectedLocation = point;
                    address = null;
                  });

                  await reverseGeocode(
                    point.latitude,
                    point.longitude,
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),

                if (selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: selectedLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    address ?? 'Toque em algum local do mapa',
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        selectedLocation == null || address == null
                            ? null
                            : () {
                                Navigator.pop(
                                  context,
                                  {
                                    'latitude':
                                        selectedLocation!.latitude,
                                    'longitude':
                                        selectedLocation!.longitude,
                                    'formattedAddress': address!,
                                  },
                                );
                              },
                    child: const Text(
                      'Confirmar localização',
                    ),
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