// lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  // Branding / app metadata
  static const String appName = 'WorkPulse';
  static const String appSubtitle = 'Employee Self-Service';
  static const String companyName = 'SoftZen IT';
  static const String version = 'v1.0.0';
  static const String supportEmail = 'peopleops@softzentech.co.uk';
  static const String supportPhone = '+44 7700 900123';

  // These are DEFAULTS — overridden by employee.shiftStart/shiftEnd when available
  static const int defaultWorkStartMinutes = 9 * 60;  // 09:00
  static const int defaultGraceMinutes = 15;
  static const int defaultShiftMinutes = 9 * 60;      // 9 hours

  // Convenience aliases used across the codebase
  static const int workStartMinutes = defaultWorkStartMinutes;
  static const int graceMinutes = defaultGraceMinutes;
  static const int standardShiftMinutes = defaultShiftMinutes;

  // Parse "09:00" string to minutes
  static int parseTimeToMinutes(String time) {
    final parts = time.split(':');
    return (int.tryParse(parts[0]) ?? 9) * 60 + (int.tryParse(parts[1]) ?? 0);
  }
}