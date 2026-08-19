import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/attendance/presentation/screens/attendance_detail_screen.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/check_in_out_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/unsupported_role_screen.dart';
import '../../features/collections/presentation/screens/collection_list_screen.dart';
import '../../features/collections/presentation/screens/new_collection_screen.dart';
import '../../features/commissions/presentation/screens/commission_screen.dart';
import '../../features/complaints/presentation/screens/complaint_list_screen.dart';
import '../../features/complaints/presentation/screens/new_complaint_screen.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../../features/leave/presentation/screens/leave_detail_screen.dart';
import '../../features/leave/presentation/screens/new_leave_request_screen.dart';
import '../../features/leads/presentation/screens/lead_list_screen.dart';
import '../../features/leads/presentation/screens/new_lead_screen.dart';
import '../../features/followups/presentation/screens/followup_list_screen.dart';
import '../../features/followups/presentation/screens/new_followup_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/order_list_screen.dart';
import '../../features/orders/presentation/screens/new_order_screen.dart';
import '../../features/payments/presentation/screens/payment_detail_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/promotions/presentation/screens/promotion_list_screen.dart';
import '../../features/promotions/presentation/screens/new_promotion_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/legal_screen.dart';
import '../../features/profile/presentation/screens/more_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/statement/presentation/screens/statement_screen.dart';
import '../../features/visits/presentation/screens/day_management_screen.dart';
import '../../features/visits/presentation/screens/visit_list_screen.dart';
import '../../features/visits/presentation/screens/new_visit_screen.dart';
import '../../features/visits/presentation/screens/visit_detail_screen.dart';
import '../../shared/providers/role_providers.dart';
import '../../shared/models/user_role.dart';
import '../shell/shell_screen.dart';

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
      final isLoading = authState.isLoading;

      // 1. Initial app load: stay on splash while checking token
      if (loc == '/splash' && isLoading) return null;

      // 2. If logged in, and on login/splash, go to dashboard
      if (authed && isAuthRoute) return '/dashboard';

      // 3. If NOT logged in, and NOT on login/splash, go to login
      // CRITICAL FIX: Added !isLoading so it doesn't redirect during login API call
      if (!authed && !isAuthRoute && !isLoading) return '/login';

      // 4. If logged in, check role restrictions
      if (authed) {
        final role = ref.read(currentUserRoleProvider);

        // Block web-only roles
        if (role == UserRole.unknown) return '/unsupported-role';

        // Block POS users from field features
        if (role == UserRole.posUser) {
          if (loc.startsWith('/visits') || loc.startsWith('/collections') ||
              loc.startsWith('/market-updates') || loc.startsWith('/leads') ||
              loc.startsWith('/followups') || loc.startsWith('/day-management')) {
            return '/dashboard';
          }
        }

        // Block Marketing Executives from supervisor-only features
        if (role == UserRole.marketingExecutive) {
          if (loc.startsWith('/team-overview') || loc.startsWith('/approvals')) {
            return '/dashboard';
          }
        }
      }

      return null;
    },
    routes: [
      // ---- Auth ----
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/unsupported-role', builder: (_, __) => const UnsupportedRoleScreen()),

      // ---- Main Shell (Bottom Navigation) ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (_, __) => const DashboardRouter()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tab-secondary', builder: (_, __) => const SecondaryTabRouter()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tab-tertiary', builder: (_, __) => const TertiaryTabRouter()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
          ]),
        ],
      ),

      // ---- Attendance (Office) ----
      GoRoute(path: '/attendance', builder: (_, __) => const AttendanceScreen()),
      GoRoute(path: '/attendance/checkin', builder: (_, __) => const CheckInOutScreen()),
      GoRoute(
        path: '/attendance/detail/:id',
        builder: (_, state) => AttendanceDetailScreen(recordId: state.pathParameters['id']!),
      ),

      // ---- Leave ----
      GoRoute(path: '/leave/new', builder: (_, __) => const NewLeaveRequestScreen()),
      GoRoute(
        path: '/leave/detail/:id',
        builder: (_, state) => LeaveDetailScreen(requestId: state.pathParameters['id']!),
      ),

      // ---- Payments ----
      GoRoute(path: '/payments', builder: (_, __) => const PaymentsScreen()),
      GoRoute(
        path: '/payments/detail/:id',
        builder: (_, state) => PaymentDetailScreen(billId: state.pathParameters['id']!),
      ),

      // ---- Statement ----
      GoRoute(path: '/statement', builder: (_, __) => const StatementScreen()),

      // ---- Notifications ----
     // GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),

      // ---- Profile & Settings ----
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/help', builder: (_, __) => const HelpSupportScreen()),
      GoRoute(
        path: '/legal/:kind',
        builder: (_, state) => LegalScreen(kind: state.pathParameters['kind'] ?? 'privacy'),
      ),

      // ---- Visits (Field Marketing) ----
      GoRoute(path: '/visits', builder: (_, __) => const VisitListScreen()),
      GoRoute(path: '/visits/new', builder: (_, __) => const NewVisitScreen()),
      GoRoute(path: '/visits/day-management', builder: (_, __) => const DayManagementScreen()),
      GoRoute(
        path: '/visits/detail/:id',
        builder: (_, state) => VisitDetailScreen(visitId: state.pathParameters['id']!),
      ),

      // ---- Orders ----
      GoRoute(path: '/orders', builder: (_, __) => const OrderListScreen()),
      GoRoute(path: '/orders/new', builder: (_, __) => const NewOrderScreen()),
      GoRoute(
        path: '/orders/detail/:id',
        builder: (_, state) => OrderDetailScreen(orderId: state.pathParameters['id']!),
      ),

      // ---- Collections ----
      GoRoute(path: '/collections', builder: (_, __) => const CollectionListScreen()),
      GoRoute(path: '/collections/new', builder: (_, __) => const NewCollectionScreen()),

      // ---- Complaints ----
      GoRoute(path: '/complaints', builder: (_, __) => const ComplaintListScreen()),
      GoRoute(path: '/complaints/new', builder: (_, __) => const NewComplaintScreen()),

      // ---- Market Updates (formerly Promotions) ----
      GoRoute(path: '/market-updates', builder: (_, __) => const PromotionListScreen()),
      GoRoute(path: '/market-updates/new', builder: (_, __) => const NewPromotionScreen()),
      // Keep old route for backward compatibility
      GoRoute(path: '/promotions', builder: (_, __) => const PromotionListScreen()),
      GoRoute(path: '/promotions/new', builder: (_, __) => const NewPromotionScreen()),

      // ---- Commissions ----
      GoRoute(path: '/commissions', builder: (_, __) => const CommissionScreen()),

      // ---- Leads ----
      GoRoute(path: '/leads', builder: (_, __) => const LeadListScreen()),
      GoRoute(path: '/leads/new', builder: (_, __) => const NewLeadScreen()),

      // ---- Follow-Ups ----
      GoRoute(path: '/followups', builder: (_, __) => const FollowUpListScreen()),
      GoRoute(path: '/followups/new', builder: (_, __) => const NewFollowUpScreen()),
    ],
  );
});

/// Dashboard router - returns the correct dashboard based on role
class DashboardRouter extends ConsumerWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(dashboardScreenProvider);
  }
}

/// Secondary tab - Visits for field roles, Orders for POS
class SecondaryTabRouter extends ConsumerWidget {
  const SecondaryTabRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    if (role.isFieldRole) {
      return const VisitListScreen();
    }
    return const OrderListScreen();
  }
}

/// Tertiary tab - Orders for field roles, Profile for POS
class TertiaryTabRouter extends ConsumerWidget {
  const TertiaryTabRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    if (role.isFieldRole) {
      return const OrderListScreen();
    }
    return const ProfileScreen();
  }
}

// ---- Stub screens that need to be built ----



