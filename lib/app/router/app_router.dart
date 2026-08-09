import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/screens/attendance_detail_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/check_in_out_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/leave/presentation/screens/leave_detail_screen.dart';
import '../../features/leave/presentation/screens/leave_requests_screen.dart';
import '../../features/leave/presentation/screens/new_leave_request_screen.dart';
import '../../features/payments/presentation/screens/payment_detail_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/legal_screen.dart';
import '../../features/profile/presentation/screens/more_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/statement/presentation/screens/statement_screen.dart';
import '../shell/shell_screen.dart';

/// Notifies GoRouter whenever auth state changes.
class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/splash';
      final authed = authState.valueOrNull != null;

      // 1. ONLY hold on splash if it's the initial app startup loading.
      // If the user is on the login screen and clicking the button,
      // isLoading becomes true, but we should NOT send them back to splash.
      if (authState.isLoading && loc == '/splash') {
        return '/splash';
      }

      // 2. If logged in and trying to access login/splash, send to home
      if (authed && isAuthRoute) return '/home';

      // 3. If NOT logged in and trying to access protected routes, send to login
      if (!authed && !isAuthRoute) return '/login';

      // 4. Otherwise, allow the navigation
      // (e.g., staying on the login screen while the login button spins)
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/attendance', builder: (_, __) => const AttendanceScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/leave', builder: (_, __) => const LeaveRequestsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/payments', builder: (_, __) => const PaymentsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
          ]),
        ],
      ),

      GoRoute(path: '/attendance/checkin', builder: (_, __) => const CheckInOutScreen()),
      GoRoute(
        path: '/attendance/detail/:id',
        builder: (_, state) => AttendanceDetailScreen(recordId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/leave/new', builder: (_, __) => const NewLeaveRequestScreen()),
      GoRoute(
        path: '/leave/detail/:id',
        builder: (_, state) => LeaveDetailScreen(requestId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/payments/detail/:id',
        builder: (_, state) => PaymentDetailScreen(billId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/statement', builder: (_, __) => const StatementScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpSupportScreen()),
      GoRoute(
        path: '/legal/:kind',
        builder: (_, state) => LegalScreen(kind: state.pathParameters['kind'] ?? 'privacy'),
      ),
    ],
  );
});