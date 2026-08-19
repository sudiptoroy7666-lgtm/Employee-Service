import 'package:flutter/material.dart';

/// Circle Seed ERP Mobile App Roles
///
/// Based on the PDF document Section 4.1 (RBAC):
/// - Marketing Executive: Field activity & lead tracking
/// - Supervisor (Sales Manager): Order & sales monitoring
/// - POS User: Sales transactions (separate module)
/// - Unknown: Web-only roles (Admin, HR, Factory Manager, etc.)
///
/// Dealers, Retailers, and Farmers are NOT app users.
/// They are Stakeholders (clients) managed via GET /api/stakeholders/
enum UserRole {
  marketingExecutive,
  supervisor,
  posUser,
  unknown;

  String get label {
    switch (this) {
      case UserRole.marketingExecutive:
        return 'Marketing Executive';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.posUser:
        return 'POS User';
      case UserRole.unknown:
        return 'Employee';
    }
  }

  String get description {
    switch (this) {
      case UserRole.marketingExecutive:
        return 'Field visits, order booking, collections, market updates';
      case UserRole.supervisor:
        return 'Team monitoring, approvals, regional KPIs, all field features';
      case UserRole.posUser:
        return 'Point of sale transactions';
      case UserRole.unknown:
        return 'Please use the Circle Seed ERP Web Panel';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.marketingExecutive:
        return Icons.directions_walk;
      case UserRole.supervisor:
        return Icons.leaderboard;
      case UserRole.posUser:
        return Icons.point_of_sale;
      case UserRole.unknown:
        return Icons.person_off;
    }
  }

  /// Whether this role can access the mobile field app
  bool get isFieldRole =>
      this == UserRole.marketingExecutive || this == UserRole.supervisor;

  /// Whether this role can access team management features
  bool get isManagementRole => this == UserRole.supervisor;
}
