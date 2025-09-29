import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/location_provider.dart';
import '../models/location_data.dart';

class TrackingPage extends StatefulWidget {
  final String orderId;
  final String shipperId;

  const TrackingPage({
    Key? key,
    required this.orderId,
    required this.shipperId,
  }) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  Future<void> _initializeTracking() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.initialize(widget.shipperId);
      
      // Get initial location for the order
      final initialLocation = await locationProvider.getCurrentLocationForOrder(widget.orderId);
      if (initialLocation != null) {
        _updateMapLocation(initialLocation);
      }

      // Load location history
      final history = await locationProvider.getLocationHistory(widget.orderId);
      if (history.isNotEmpty) {
        _updateMapWithHistory(history);
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize tracking: $e')),
        );
      }
    }
  }

  void _updateMapLocation(LocationData locationData) {
    if (_mapController == null) return;

    final marker = Marker(
      markerId: MarkerId(locationData.shipperId),
      position: LatLng(locationData.latitude, locationData.longitude),
      infoWindow: InfoWindow(
        title: 'Shipper Location',
        snippet: locationData.address,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      _markers.clear();
      _markers.add(marker);
    });

    // Move camera to current location
    _mapController!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(locationData.latitude, locationData.longitude),
      ),
    );
  }

  void _updateMapWithHistory(List<LocationData> history) {
    if (history.isEmpty) return;

    // Create markers for start and end points
    final markers = <Marker>{};
    final polylinePoints = <LatLng>[];

    for (int i = 0; i < history.length; i++) {
      final location = history[i];
      polylinePoints.add(LatLng(location.latitude, location.longitude));

      if (i == 0) {
        // Start point
        markers.add(
          Marker(
            markerId: const MarkerId('start'),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: const InfoWindow(
              title: 'Start Point',
              snippet: 'Delivery started',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      } else if (i == history.length - 1) {
        // Current location
        markers.add(
          Marker(
            markerId: MarkerId(location.shipperId),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: 'Current Location',
              snippet: location.address,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }
    }

    // Create polyline for route
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: polylinePoints,
      color: Colors.blue,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );

    setState(() {
      _markers = markers;
      _polylines = {polyline};
    });

    // Fit camera to show entire route
    if (polylinePoints.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _boundsFromLatLngList(polylinePoints),
          100,
        ),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Delivery'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              return IconButton(
                icon: Icon(
                  locationProvider.isTracking ? Icons.stop : Icons.play_arrow,
                ),
                onPressed: () {
                  if (locationProvider.isTracking) {
                    locationProvider.stopLocationTracking();
                  } else {
                    locationProvider.startLocationTracking(widget.orderId);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                // Listen for location updates
                final currentLocation = locationProvider.currentLocation;
                if (currentLocation != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateMapLocation(currentLocation);
                  });
                }

                return Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(21.0285, 105.8542), // Hanoi coordinates
                          zoom: 15,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        mapType: MapType.normal,
                      ),
                    ),
                    if (currentLocation != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Location',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Address: ${currentLocation.address}'),
                            Text('Accuracy: ${currentLocation.accuracy.toStringAsFixed(1)}m'),
                            if (currentLocation.speed > 0)
                              Text('Speed: ${(currentLocation.speed * 3.6).toStringAsFixed(1)} km/h'),
                            Text('Updated: ${_formatTime(currentLocation.timestamp)}'),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
