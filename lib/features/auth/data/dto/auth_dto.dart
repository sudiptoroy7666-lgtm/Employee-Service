import 'dart:convert';
class LoginResponseDto {
  LoginResponseDto.fromJson(Map<String, dynamic> j)
      : id = j['id']?.toString() ?? '',
        employeeId = j['employeeId']?.toString() ?? '',
        username = j['username']?.toString() ?? '',
        fullName = j['fullName']?.toString() ??
            _decodeNameFromJwt(j['accessToken']) ??
            j['username']?.toString() ?? '',
        roleId = j['roleId'],
        role = j['role']?.toString() ?? '',
        accessToken = j['accessToken'] as String? ?? '',
        refreshToken = j['refreshToken'] as String?,
        permissions = (j['permissions'] as List<dynamic>?)?.cast<String>() ?? [];

  final String id;
  final String employeeId;
  final String username;
  final String fullName;
  final int? roleId;
  final String role;
  final String accessToken;
  final String? refreshToken;
  final List<String> permissions;

  /// Helper to extract name from JWT payload if not provided at root
  static String? _decodeNameFromJwt(String? token) {
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      // Base64Url decode the payload (2nd part)
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(decoded) as Map<String, dynamic>;
      return payload['fullName']?.toString();
    } catch (_) {
      return null;
    }
  }
}