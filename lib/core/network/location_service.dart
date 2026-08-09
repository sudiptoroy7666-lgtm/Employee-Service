import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../errors/failures.dart';

class LocationService {
  Future<Map<String, double>> getCheckInLocation() async {
    debugPrint('🚀 [LOCATION] Starting getCheckInLocation...');

    try {
      // STEP 1: Check location services
      debugPrint('📍 [STEP 1] Checking if location services are enabled...');
      final enabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('📍 [STEP 1] Location services enabled: $enabled');

      if (!enabled) {
        throw const AppFailure(
          'Location services are DISABLED. Please enable GPS in Settings.',
        );
      }

      // STEP 2: Check permissions
      debugPrint('📍 [STEP 2] Checking current permission status...');
      var permission = await Geolocator.checkPermission();
      debugPrint('📍 [STEP 2] Current permission: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('📍 [STEP 2] Permission DENIED - requesting...');
        permission = await Geolocator.requestPermission();
        debugPrint('📍 [STEP 2] Permission after request: $permission');
      }

      if (permission == LocationPermission.deniedForever) {
        throw const AppFailure(
          'Location permission PERMANENTLY DENIED. '
              'Go to Settings → Apps → WorkPulse → Permissions → Location → Allow',
        );
      }

      if (permission == LocationPermission.denied) {
        throw const AppFailure(
          'Location permission DENIED. Please allow location access and try again.',
        );
      }

      // STEP 3: Try last known position (instant)
      // STEP 3: Try last known position (instant)
      debugPrint('📍 [STEP 3] Trying last known position...');
      Position? lastKnown;
      try {
        lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          debugPrint('✅ [STEP 3] Last known: ${lastKnown.latitude}, ${lastKnown.longitude} (±${lastKnown.accuracy}m)');
        } else {
          debugPrint('⚠️ [STEP 3] No last known position');
        }
      } catch (e) {
        debugPrint('⚠️ [STEP 3] Last known failed: $e');
      }

      // STEP 4: Get fresh position with progressive accuracy + manual timeout
      Position? freshPosition;

      // Attempt A: Low accuracy (fastest)
      debugPrint('📍 [STEP 4A] Trying LOW accuracy...');
      try {
        freshPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 8));
        debugPrint('✅ [STEP 4A] Low: ${freshPosition.latitude}, ${freshPosition.longitude} (±${freshPosition.accuracy}m)');
      } catch (e) {
        debugPrint('❌ [STEP 4A] Low failed: $e');
      }

      // Attempt B: Medium accuracy
      if (freshPosition == null || freshPosition.accuracy > 150) {
        debugPrint('📍 [STEP 4B] Trying MEDIUM accuracy...');
        try {
          freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
          ).timeout(const Duration(seconds: 12));
          debugPrint('✅ [STEP 4B] Medium: ${freshPosition.latitude}, ${freshPosition.longitude} (±${freshPosition.accuracy}m)');
        } catch (e) {
          debugPrint('❌ [STEP 4B] Medium failed: $e');
        }
      }

      // Attempt C: High accuracy (GPS)
      if (freshPosition == null || freshPosition.accuracy > 100) {
        debugPrint('📍 [STEP 4C] Trying HIGH accuracy (GPS)...');
        try {
          freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(const Duration(seconds: 25));
          debugPrint('✅ [STEP 4C] High: ${freshPosition.latitude}, ${freshPosition.longitude} (±${freshPosition.accuracy}m)');
        } catch (e) {
          debugPrint('❌ [STEP 4C] High failed: $e');
        }
      }

      // Attempt D: Best accuracy (last resort)
      if (freshPosition == null || freshPosition.accuracy > 100) {
        debugPrint('📍 [STEP 4D] Trying BEST accuracy...');
        try {
          freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
          ).timeout(const Duration(seconds: 30));
          debugPrint('✅ [STEP 4D] Best: ${freshPosition.latitude}, ${freshPosition.longitude} (±${freshPosition.accuracy}m)');
        } catch (e) {
          debugPrint('❌ [STEP 4D] Best failed: $e');
        }
      }

      // STEP 5: Choose best position
      debugPrint('📍 [STEP 5] Choosing best position...');
      final bestPosition = _chooseBest(freshPosition, lastKnown);

      if (bestPosition == null) {
        throw const AppFailure(
          'Could not get ANY location. Go near a window or outdoors, '
              'wait 30 seconds, then try again.',
        );
      }

      debugPrint('✅ [STEP 5] Best: ${bestPosition.latitude}, ${bestPosition.longitude} '
          '(±${bestPosition.accuracy}m, mocked: ${bestPosition.isMocked})');

      // STEP 6: Anti-spoofing
      if (bestPosition.isMocked) {
        throw const AppFailure(
          'Fake GPS detected. Mock locations are not allowed.',
        );
      }

      // STEP 7: Validate accuracy
      if (bestPosition.accuracy > 500) {
        throw AppFailure(
          'GPS accuracy too poor (${bestPosition.accuracy.toStringAsFixed(0)}m). '
              'Move near a window or go outdoors.',
        );
      }

      debugPrint('🎉 [LOCATION] SUCCESS');
      return {
        'latitude': bestPosition.latitude,
        'longitude': bestPosition.longitude,
      };
    } catch (e) {
      debugPrint('❌ [LOCATION] FINAL ERROR: $e');
      if (e is AppFailure) rethrow;
      throw AppFailure('Location error: $e');
    }
  }

  Position? _chooseBest(Position? fresh, Position? lastKnown) {
    if (fresh == null && lastKnown == null) return null;
    if (fresh == null) return lastKnown;
    if (lastKnown == null) return fresh;
    if (fresh.accuracy <= 200) return fresh;
    if (lastKnown.accuracy < fresh.accuracy) return lastKnown;
    return fresh;
  }
}