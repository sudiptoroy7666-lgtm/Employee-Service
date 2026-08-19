import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

/// Maps the API-returned role/designation to the app's UserRole enum.
///
/// API roles from Circle Seed ERP (from live API responses):
/// - "Super Admin" → unknown (web only)
/// - "Admin" → unknown (web only)
/// - "Sales Manager" → supervisor
/// - "Sales Executive" → marketingExecutive
/// - "Marketing Executive" → marketingExecutive
/// - "POS User" → posUser
/// - "Inventory Manager" → unknown (web only)
/// - "Inventory Executive" → unknown (web only)
/// - "Purchase Manager" → unknown (web only)
/// - "Purchase Executive" → unknown (web only)
final currentUserRoleProvider = Provider<UserRole>((ref) {
  final employee = ref.watch(authControllerProvider).valueOrNull;

  if (employee == null) {
    debugPrint('👤 RoleProvider: No employee logged in -> unknown');
    return UserRole.unknown;
  }

  // FIX: Null-safe parsing to prevent crashes if API returns null
  final role = (employee.role ?? '').toLowerCase();
  final designation = (employee.designation ?? '').toLowerCase();

  debugPrint('👤 RoleProvider: Evaluating role="$role", designation="$designation" for ${employee.name}');

  // Sales Executive / Marketing Executive → Field Worker
  if (role.contains('sales executive') ||
      role.contains('marketing executive') ||
      designation.contains('sales executive') ||
      designation.contains('marketing executive') ||
      designation.contains('marketing')) {
    debugPrint('👤 RoleProvider: -> marketingExecutive');
    return UserRole.marketingExecutive;
  }

  // Sales Manager / Supervisor → Team Lead
  if (role.contains('sales manager') ||
      role.contains('supervisor') ||
      designation.contains('sales manager') ||
      designation.contains('supervisor') ||
      designation.contains('manager')) {
    debugPrint('👤 RoleProvider: -> supervisor');
    return UserRole.supervisor;
  }

  // POS User → POS module
  if (role.contains('pos') || designation.contains('pos')) {
    debugPrint('👤 RoleProvider: -> posUser');
    return UserRole.posUser;
  }

  // Everything else (Admin, HR, Inventory, Purchase, Factory, Accounts) is web-only
  debugPrint('👤 RoleProvider: -> unknown (Web only)');
  return UserRole.unknown;
});
/// Checks if the current user has a specific role
final hasRoleProvider = Provider.family<bool, UserRole>((ref, requiredRole) {
  final currentRole = ref.watch(currentUserRoleProvider);
  return currentRole == requiredRole;
});

/// Feature-based access control
///
/// Usage: ref.watch(canAccessFeatureProvider('visits'))
final canAccessFeatureProvider = Provider.family<bool, String>((ref, feature) {
  final role = ref.watch(currentUserRoleProvider);

  // Only field roles can access the mobile app features
  if (!role.isFieldRole) return false;

  switch (feature) {
    // Core features available to both field roles
    case 'dashboard':
    case 'visits':
    case 'visit_create':
    case 'visit_checkin':
    case 'visit_checkout':
    case 'orders':
    case 'order_create':
    case 'collections':
    case 'collection_create':
    case 'market_updates':
    case 'market_update_create':
    case 'leads':
    case 'lead_create':
    case 'followups':
    case 'followup_create':
    case 'commissions':
    case 'attendance':
    case 'leave':
    case 'payments':
    case 'statement':
    case 'profile':
    case 'notifications':
      return true;

    // Marketing Executive only
    case 'day_management':
      return role == UserRole.marketingExecutive;

    // Supervisor only
    case 'team_overview':
    case 'team_visits':
    case 'team_kpi':
    case 'approvals':
    case 'visit_approval':
    case 'leave_approval':
      return role == UserRole.supervisor;

    default:
      return false;
  }
});

/// Navigation tabs based on role
final roleNavTabsProvider = Provider<List<NavTab>>((ref) {
  final role = ref.watch(currentUserRoleProvider);

  switch (role) {
    case UserRole.marketingExecutive:
      return [
        NavTab(icon: Icons.dashboard, label: 'Home', route: '/dashboard'),
        NavTab(icon: Icons.add_location, label: 'Visits', route: '/visits'),
        NavTab(icon: Icons.receipt_long, label: 'Orders', route: '/orders'),
        NavTab(icon: Icons.more_horiz, label: 'More', route: '/more'),
      ];
    case UserRole.supervisor:
      return [
        NavTab(icon: Icons.dashboard, label: 'Team', route: '/dashboard'),
        NavTab(icon: Icons.add_location, label: 'Visits', route: '/visits'),
        NavTab(icon: Icons.receipt_long, label: 'Orders', route: '/orders'),
        NavTab(icon: Icons.more_horiz, label: 'More', route: '/more'),
      ];
    case UserRole.posUser:
      return [
        NavTab(icon: Icons.point_of_sale, label: 'POS', route: '/dashboard'),
        NavTab(icon: Icons.receipt_long, label: 'Orders', route: '/orders'),
        NavTab(icon: Icons.more_horiz, label: 'More', route: '/more'),
      ];
    case UserRole.unknown:
      return []; // No tabs for web-only roles
  }
});

class NavTab {
  final IconData icon;
  final String label;
  final String route;

  NavTab({required this.icon, required this.label, required this.route});
}
