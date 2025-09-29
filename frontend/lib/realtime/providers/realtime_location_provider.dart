import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/realtime_location_data.dart';
import '../services/realtime_websocket_service.dart';
import '../services/realtime_api_service.dart';

class RealtimeLocationProvider with ChangeNotifier {
  final RealtimeWebSocketService _websocketService = RealtimeWebSocketService();
  final RealtimeApiService _apiService = RealtimeApiService();

  RealtimeLocationData? _currentLocation;
  List<RealtimeLocationData> _locationHistory = [];
  bool _isTracking = false;
  String? _currentOrderId;
  String? _currentShipperId;
  Stream<Position>? _positionStream;

  RealtimeLocationData? get currentLocation => _currentLocation;
  List<RealtimeLocationData> get locationHistory => _locationHistory;
  bool get isTracking => _isTracking;

  void initialize(String shipperId) {
    _currentShipperId = shipperId;

    // Setup WebSocket callbacks
    _websocketService.onLocationUpdate = _handleLocationUpdate;
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> startLocationTracking(String orderId) async {
    if (_currentShipperId == null) {
      throw Exception('Shipper not initialized');
    }

    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    _currentOrderId = orderId;
    _isTracking = true;
    notifyListeners();

    try {
      // Connect to WebSocket if not already connected
      if (!_websocketService.isConnected) {
        _websocketService.connect(
          'http://localhost:3000', // TODO: Make this configurable
          _currentShipperId!,
          'shipper',
        );
      }

      // Join order room
      _websocketService.joinOrder(orderId);

      // Start location stream
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      );

      _positionStream!.listen((Position position) {
        _updateLocation(position);
      });

      // Get initial location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocation(position);

    } catch (e) {
      _isTracking = false;
      notifyListeners();
      rethrow;
    }
  }

  void stopLocationTracking() {
    _positionStream = null;
    _isTracking = false;
    
    if (_currentOrderId != null) {
      _websocketService.leaveOrder();
      
      // Stop tracking via API
      _apiService.post('/location/stop-tracking/$_currentOrderId', {
        'shipperId': _currentShipperId,
      }).catchError((e) {
        print('Error stopping location tracking: $e');
      });
    }

    _currentOrderId = null;
    notifyListeners();
  }

  void _updateLocation(Position position) {
    if (_currentOrderId == null || _currentShipperId == null) return;

    final locationData = RealtimeLocationData(
      shipperId: _currentShipperId!,
      coordinates: [position.longitude, position.latitude],
      address: 'Current Location', // TODO: Get address from coordinates
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
      timestamp: DateTime.now(),
    );

    _currentLocation = locationData;
    _locationHistory.add(locationData);

    // Keep only last 100 location updates
    if (_locationHistory.length > 100) {
      _locationHistory.removeAt(0);
    }

    // Send location update via WebSocket
    _websocketService.updateLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      address: locationData.address,
      accuracy: position.accuracy,
      speed: position.speed,
      heading: position.heading,
    );

    notifyListeners();
  }

  void _handleLocationUpdate(Map<String, dynamic> data) {
    final locationData = RealtimeLocationData.fromJson(data);
    
    // Only update if this is not our own location update
    if (locationData.shipperId != _currentShipperId) {
      _currentLocation = locationData;
      notifyListeners();
    }
  }

  Future<List<RealtimeLocationData>> getLocationHistory(String orderId) async {
    try {
      final response = await _apiService.get('/location/order/$orderId/history');
      final historyData = response['locationHistory'] as List;
      
      return historyData.map((json) => RealtimeLocationData.fromJson(json)).toList();
    } catch (e) {
      print('Error getting location history: $e');
      return [];
    }
  }

  Future<RealtimeLocationData?> getCurrentLocationForOrder(String orderId) async {
    try {
      final response = await _apiService.get('/location/order/$orderId/current');
      
      if (response['coordinates'] != null) {
        return RealtimeLocationData.fromJson(response);
      }
      return null;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  @override
  void dispose() {
    stopLocationTracking();
    super.dispose();
  }
}
