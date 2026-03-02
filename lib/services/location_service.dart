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
      throw Exception('Dịch vụ vị trí chưa bật. Hay bật GPS trên thiết bi.');
    }

    var perm = await permission;
    if (perm == LocationPermission.denied) {
      perm = await requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      throw Exception(
        'Quyền vị trí bị từ chối vĩnh viễn. Hay bật lại trong Cài đặt ứng dụng.',
      );
    }
    if (perm == LocationPermission.denied) {
      throw Exception('Cần quyền truy cập vị trí chính xác.');
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
