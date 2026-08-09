/// Base failure type returned by repositories (mirrors future API errors).
class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'The requested record was not found.']);
}

class OfflineFailure extends AppFailure {
  const OfflineFailure([super.message = 'You are offline. Some information may be unavailable.']);
}