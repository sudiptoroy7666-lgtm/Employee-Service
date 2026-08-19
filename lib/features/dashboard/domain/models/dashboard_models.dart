class MonthlySales {
  final String month;
  final double amount;

  const MonthlySales({required this.month, required this.amount});
}

class DashboardStats {
  // Sales metrics
  final double totalPurchases;
  final int totalOrders;
  final int pendingOrders;
  final int completedOrders;
  final double totalCollection;
  final double outstandingAmount;
  final List<MonthlySales> monthlySales;

  // Field metrics (NEW)
  final int visitsToday;
  final int leadsToday;
  final int followUpsToday;
  final int collectionsToday;

  // Leave metrics (NEW)
  final int leaveQuota;
  final int leaveUsed;
  final int leaveRemaining;
  final int pendingLeaveApprovals;

  // Day status (NEW)
  final bool isDayStarted;

  const DashboardStats({
    required this.totalPurchases,
    required this.totalOrders,
    required this.pendingOrders,
    required this.completedOrders,
    required this.totalCollection,
    required this.outstandingAmount,
    required this.monthlySales,
    this.visitsToday = 0,
    this.leadsToday = 0,
    this.followUpsToday = 0,
    this.collectionsToday = 0,
    this.leaveQuota = 0,
    this.leaveUsed = 0,
    this.leaveRemaining = 0,
    this.pendingLeaveApprovals = 0,
    this.isDayStarted = false,
  });
}

/// Team-level stats for Supervisor dashboard
class TeamStats {
  final int totalTeamMembers;
  final int activeInField;
  final int totalVisitsToday;
  final int totalOrdersToday;
  final double totalRevenueToday;
  final int pendingVisitApprovals;
  final int pendingLeaveApprovals;

  const TeamStats({
    required this.totalTeamMembers,
    required this.activeInField,
    required this.totalVisitsToday,
    required this.totalOrdersToday,
    required this.totalRevenueToday,
    required this.pendingVisitApprovals,
    required this.pendingLeaveApprovals,
  });
}
