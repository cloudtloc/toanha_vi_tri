import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double accuracyMeters;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });
}

class LocationService {
  static Future<bool> get serviceEnabled => Geolocator.isLocationServiceEnabled();

  static Future<LocationPermission> get permission => Geolocator.checkPermission();

  static Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  static Future<LocationResult> getViTriChinhXac() async {
    final enabled = await serviceEnabled;
    if (!enabled) {
      throw Exception('Dich vu vi tri chua bat. Hay bat GPS tren thiet bi.');
    }

    var perm = await permission;
    if (perm == LocationPermission.denied) {
      perm = await requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception(
        'Quyen vi tri bi tu choi vinh vien. Hay bat lai trong Cai dat ung dung.',
      );
    }
    if (perm == LocationPermission.denied) {
      throw Exception('Can quyen truy cap vi tri chinh xac.');
    }

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    final position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  }
}
