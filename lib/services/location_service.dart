import 'dart:math';

class LocationService {
  // Default coordinates (Central Medical District / City Center)
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;

  /// Haversine formula to calculate great-circle distance between two GPS coordinates in kilometers
  static double calculateDistanceKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _degToRad(endLatitude - startLatitude);
    final double dLon = _degToRad(endLongitude - startLongitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(startLatitude)) *
            cos(_degToRad(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadiusKm * c;

    return double.parse(distance.toStringAsFixed(2));
  }

  static double _degToRad(double deg) {
    return deg * (pi / 180.0);
  }

  /// Format distance into friendly string (e.g., '850 m' or '3.4 km')
  static String formatDistance(double km) {
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return '$meters m away';
    }
    return '${km.toStringAsFixed(1)} km away';
  }
}
