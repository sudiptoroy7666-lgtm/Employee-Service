import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../shared/providers/role_providers.dart';
import '../../../../shared/models/user_role.dart';
import '../../../orders/presentation/providers/order_providers.dart';
import '../../../visits/presentation/providers/visit_providers.dart';
import '../../domain/models/dashboard_models.dart';
import '../screens/marketing_executive_dashboard_screen.dart';
import '../screens/supervisor_dashboard_screen.dart';
import '../../../../features/auth/presentation/screens/unsupported_role_screen.dart';

/// Returns the correct dashboard screen based on the user's role.
///
/// - Marketing Executive → Personal dashboard (My visits, my orders, start/end day)
/// - Supervisor → Team dashboard (Team overview, approvals, regional KPIs)
/// - Unknown/Web roles → Unsupported role screen
final dashboardScreenProvider = Provider<Widget>((ref) {
  final role = ref.watch(currentUserRoleProvider);

  switch (role) {
    case UserRole.marketingExecutive:
      return const MarketingExecutiveDashboardScreen();
    case UserRole.supervisor:
      return const SupervisorDashboardScreen();
    case UserRole.posUser:
      // TODO: Create PosDashboardScreen if POS is included in mobile
      return const MarketingExecutiveDashboardScreen();
    case UserRole.unknown:
      return const UnsupportedRoleScreen();
  }
});

/// Dashboard stats fetched from GET /api/dashboard/employee
///
/// Response structure (from live API):
/// {
///   "attendance": { "today": null },
///   "leave": { "quota": 0, "used": 0, "remaining": 0, "pendingRequests": 0 },
///   "payslip": null,
///   "pendingApprovals": { "leaveApprovals": 0, "payrollApprovals": 0 },
///   "kpi": { "sales": null, "marketing": null }
/// }
final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  try {
    final res = await ref.read(apiClientProvider).dio.get(ApiEndpoints.dashboardEmployee);
    final j = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : {};

    final leave = j['leave'] is Map ? j['leave'] as Map<String, dynamic> : {};
    final approvals = j['pendingApprovals'] is Map ? j['pendingApprovals'] as Map<String, dynamic> : {};

    // CALCULATE STATS LOCALLY FROM REAL DATA
    int visitsToday = 0;
    int leadsToday = 0;
    int collectionsToday = 0;
    int totalOrders = 0;
    double totalCollection = 0.0;

    // Count today's visits
    try {
      final visits = await ref.read(visitsProvider.future);
      final today = DateTime.now();
      visitsToday = visits.where((v) =>
      v.scheduledTime.year == today.year &&
          v.scheduledTime.month == today.month &&
          v.scheduledTime.day == today.day
      ).length;
    } catch (_) {}

    // Count today's orders and collections
    try {
      final orders = await ref.read(ordersProvider.future);
      final today = DateTime.now();
      totalOrders = orders.length;
      final todayOrders = orders.where((o) =>
      o.orderDate.year == today.year &&
          o.orderDate.month == today.month &&
          o.orderDate.day == today.day
      ).toList();

      // If you have a collections provider, you can add it here too
      // For now, we'll use the API fallback for collection amount
      totalCollection = double.tryParse(j['totalCollection']?.toString() ?? '0') ?? 0.0;
    } catch (_) {}

    return DashboardStats(
      totalPurchases: 0,
      totalOrders: totalOrders > 0 ? totalOrders : (int.tryParse(j['totalOrders']?.toString() ?? '0') ?? 0),
      pendingOrders: int.tryParse(j['pendingOrders']?.toString() ?? '0') ?? 0,
      completedOrders: int.tryParse(j['completedOrders']?.toString() ?? '0') ?? 0,
      totalCollection: totalCollection,
      outstandingAmount: double.tryParse(j['outstandingAmount']?.toString() ?? '0') ?? 0,
      monthlySales: [],
      visitsToday: visitsToday,
      leadsToday: leadsToday,
      followUpsToday: 0,
      collectionsToday: collectionsToday,
      leaveQuota: int.tryParse(leave['quota']?.toString() ?? '0') ?? 0,
      leaveUsed: int.tryParse(leave['used']?.toString() ?? '0') ?? 0,
      leaveRemaining: int.tryParse(leave['remaining']?.toString() ?? '0') ?? 0,
      pendingLeaveApprovals: int.tryParse(approvals['leaveApprovals']?.toString() ?? '0') ?? 0,
      isDayStarted: false,
    );
  } catch (e) {
    debugPrint('⚠️ API dashboardStats failed: $e');
    return DashboardStats(
      totalPurchases: 0, totalOrders: 0, pendingOrders: 0, completedOrders: 0,
      totalCollection: 0, outstandingAmount: 0, monthlySales: const [],
      visitsToday: 0, leadsToday: 0, followUpsToday: 0, collectionsToday: 0,
      leaveQuota: 0, leaveUsed: 0, leaveRemaining: 0, pendingLeaveApprovals: 0,
      isDayStarted: false,
    );
  }
}, name: 'dashboardStats');

/// Team stats for Supervisor dashboard
/// Fetches from GET /api/dashboard/admin
final teamStatsProvider = FutureProvider.autoDispose<TeamStats>((ref) async {
  try {
    final res = await ref.read(apiClientProvider).dio.get(ApiEndpoints.dashboardAdmin);
    final j = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : {};

    return TeamStats(
      totalTeamMembers: int.tryParse(j['totalEmployees']?.toString() ?? '0') ?? 0,
      activeInField: int.tryParse(j['activeInField']?.toString() ?? '0') ?? 0,
      totalVisitsToday: int.tryParse(j['totalVisitsToday']?.toString() ?? '0') ?? 0,
      totalOrdersToday: int.tryParse(j['totalOrdersToday']?.toString() ?? '0') ?? 0,
      totalRevenueToday: double.tryParse(j['totalRevenueToday']?.toString() ?? '0') ?? 0,
      pendingVisitApprovals: int.tryParse(j['pendingVisitApprovals']?.toString() ?? '0') ?? 0,
      pendingLeaveApprovals: int.tryParse(j['pendingLeaveApprovals']?.toString() ?? '0') ?? 0,
    );
  } catch (e) {
    debugPrint('⚠️ API teamStats failed: $e');
    return TeamStats(
      totalTeamMembers: 0,
      activeInField: 0,
      totalVisitsToday: 0,
      totalOrdersToday: 0,
      totalRevenueToday: 0,
      pendingVisitApprovals: 0,
      pendingLeaveApprovals: 0,
    );
  }
}, name: 'teamStats');
