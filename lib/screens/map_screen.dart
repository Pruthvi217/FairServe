import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<dynamic> _shops = [];
  LatLng _center = const LatLng(12.9716, 77.5946);

  LatLng? _userLocation;
  bool _loading = true;
  Map<String, dynamic>? _selectedShop;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _getLocation();
    await _loadShops();
  }

  Future<void> _getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      if (mounted) {
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
          _center = _userLocation!;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadShops() async {
    try {
      final res = await ApiService.getShops(
        lat: _userLocation?.latitude,
        lng: _userLocation?.longitude,
      );

      if (res['success'] == true && mounted) {
        setState(() {
          _shops = res['shops'];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  double _calcDistance(dynamic shop) {
    if (_userLocation == null) return 0;

    final coords = shop['location']?['coordinates'];

    if (coords == null) return 0;

    const d = Distance();

    return d.as(
      LengthUnit.Kilometer,
      _userLocation!,
      LatLng(
        coords[1].toDouble(),
        coords[0].toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Ration Shops'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_userLocation != null) {
                _mapController.move(_userLocation!, 14);
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: 13,
                    onTap: (_, __) {
                      setState(() {
                        _selectedShop = null;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.fairserve.app',
                    ),

                    MarkerLayer(
                      markers: [
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.blue,
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ..._shops.map((shop) {
                          final coords =
                              shop['location']?['coordinates'];

                          if (coords == null) {
                            return const Marker(
                              point: LatLng(0, 0),
                              child: SizedBox(),
                            );
                          }

                          return Marker(
                            point: LatLng(
                              coords[1].toDouble(),
                              coords[0].toDouble(),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedShop = shop;
                                });
                              },
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color:
                                          _selectedShop?['_id'] ==
                                                  shop['_id']
                                              ? const Color(0xFF1B5E20)
                                              : const Color(0xFF2E7D32),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.storefront,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),

                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.storefront,
                            color: Color(0xFF2E7D32),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_shops.length} shops nearby',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_selectedShop != null)
                  Positioned(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: _ShopCard(
                          shop: _selectedShop!,
                          distance:
                              _calcDistance(_selectedShop!),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Map<String, dynamic> shop;
  final double distance;

  const _ShopCard({
    required this.shop,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop['name'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    Text(
                      shop['address'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
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
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${distance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 60,
                child: _StockItem(
                  'Rice',
                  shop['stock']?['rice'] ?? 0,
                ),
              ),

              SizedBox(
                width: 60,
                child: _StockItem(
                  'Wheat',
                  shop['stock']?['wheat'] ?? 0,
                ),
              ),

              SizedBox(
                width: 60,
                child: _StockItem(
                  'Sugar',
                  shop['stock']?['sugar'] ?? 0,
                ),
              ),

              SizedBox(
                width: 60,
                child: _StockItem(
                  'Kero',
                  shop['stock']?['kerosene'] ?? 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockItem extends StatelessWidget {
  final String label;
  final int qty;

  const _StockItem(this.label, this.qty);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$qty',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}