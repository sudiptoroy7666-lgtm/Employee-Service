/// Central map of every backend API path used by the app.
///
/// Feature repositories must reference these constants instead of hardcoding
/// path strings, so a single change keeps every caller in sync.
///
/// All endpoints verified against Circle Seed ERP Swagger API.
class ApiEndpoints {
  ApiEndpoints._();

  // ---- Auth ----
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String refresh = '/api/auth/refresh';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String changePassword = '/api/auth/change-password';

  // ---- Employee / Profile ----
  static const String me = '/api/employees/me';
  static const String employees = '/api/employees/';

  // ---- Attendance (Office) ----
  static const String attendanceReport = '/api/attendance/report';
  static const String attendanceToday = '/api/attendance/attendance/today';
  static const String checkIn = '/api/attendance/check-in';
  static const String checkOut = '/api/attendance/check-out';
  static const String attendanceStatement = '/api/attendance/statement';
  static const String attendanceTeamOverview = '/api/attendance/team-overview';

  // ---- Leave ----
  static const String leaveRequests = '/api/leave-requests/';
  static const String leaveBalance = '/api/leave-requests/leave-balance';
  static const String leavePendingApprovals = '/api/leave-requests/pending-approvals';
  static const String leaveDecision = '/api/leave-requests'; // + /{id}/decision

  // ---- Payments / Payroll ----
  static const String payments = '/api/payments';
  static const String payroll = '/api/payroll/';

  // ---- Statements ----
  static const String statements = '/api/statements';

  // ---- Notifications ----
  static const String notifications = '/api/notifications';
  static const String notificationsRead = '/api/notifications/read';

  // ---- Stakeholders (Dealers, Retailers, Farmers) ----
  /// GET /api/stakeholders/ - List all stakeholders
  /// GET /api/stakeholders/type/{typeId} - Filter by type
  static const String stakeholders = '/api/stakeholders/';
  static const String stakeholderByType = '/api/stakeholders/type';

  // ---- Visits (Field Marketing) ----
  /// POST /api/visit/ - Create visit
  /// GET /api/visit/ - List visits (filter by userId, typeId, statusId, dates)
  /// PATCH /api/visit/{id}/check-in - Check in at dealer location
  /// PATCH /api/visit/{id}/check-out - Check out from dealer location
  /// PATCH /api/visit/{id}/cancel - Cancel visit
  /// PUT /api/visit/{id} - Update visit
  static const String visits = '/api/visit/';
  static const String visitCheckIn = '/api/visit'; // + /{id}/check-in
  static const String visitCheckOut = '/api/visit'; // + /{id}/check-out
  static const String visitCancel = '/api/visit'; // + /{id}/cancel

  // ---- Leads ----
  /// POST /api/leads/ - Create lead
  /// GET /api/leads/ - List leads (filter by statusId, sourceId, userId)
  /// PUT /api/leads/{id} - Update lead
  /// DELETE /api/leads/{id} - Delete lead
  static const String leads = '/api/leads/';

  // ---- Follow-Ups ----
  /// POST /api/followup/follow-ups - Create follow-up
  /// GET /api/followup/follow-ups - List follow-ups (filter by leadId, userId)
  static const String followUps = '/api/followup/follow-ups';

  // ---- Market Updates (Product Promotion & Demand) ----
  /// POST /api/market-update/ - Create market update
  /// GET /api/market-update/ - List market updates
  /// GET /api/market-update/trend-graph - Price trend data
  static const String marketUpdates = '/api/market-update/';
  static const String marketUpdateTrend = '/api/market-update/trend-graph';

  // ---- Orders / Sales ----
  /// POST /api/sales/create-bulk-order - Book bulk order for dealer
  /// GET /api/sales/get-bulk-order - List bulk orders
  /// POST /api/sales/create-packaged-order - Book packaged order
  /// GET /api/sales/get-packaged-order - List packaged orders
  static const String createBulkOrder = '/api/sales/create-bulk-order';
  static const String getBulkOrders = '/api/sales/get-bulk-order';
  static const String createPackagedOrder = '/api/sales/create-packaged-order';
  static const String getPackagedOrders = '/api/sales/get-packaged-order';

  // ---- Invoices & Collections ----
  /// GET /api/sales/invoices - All invoices
  /// GET /api/sales/invoices/partial - Unpaid/partially paid invoices
  /// PATCH /api/sales/invoices/{invoiceId}/record-payment - Record collection
  static const String invoices = '/api/sales/invoices';
  static const String partialInvoices = '/api/sales/invoices/partial';
  static const String recordPayment = '/api/sales/invoices'; // + /{id}/record-payment

  // ---- Inventory / Products ----
  /// GET /api/inventory/bulk - Bulk seed inventory
  /// GET /api/inventory/packaged - Packaged seed inventory
  /// GET /api/inventory/overall - Combined inventory summary
  static const String inventoryBulk = '/api/inventory/bulk';
  static const String inventoryPackaged = '/api/inventory/packaged';
  static const String inventoryOverall = '/api/inventory/overall';
  static const String inventoryReadyToSellBulk = '/api/inventory/bulk/by-seed-type/ready-to-sell-list';
  static const String inventoryReadyToSellPackaged = '/api/inventory/packaged/by-seed-type/ready-to-sell-list';

  // ---- Commissions ----
  /// GET /api/accounts/commissions - Commission records
  /// PATCH /api/accounts/commissions/adjust - Adjust commissions
  static const String commissions = '/api/accounts/commissions';
  static const String commissionsAdjust = '/api/accounts/commissions/adjust';

  // ---- Dashboard ----
  /// GET /api/dashboard/employee - Personal dashboard
  /// GET /api/dashboard/admin - Admin/Team dashboard
  static const String dashboardEmployee = '/api/dashboard/employee';
  static const String dashboardAdmin = '/api/dashboard/admin';
  static const String dashboardActiveLocations = '/api/dashboard/active-locations';

  // ---- Reports ----
  /// GET /api/report/sales - Sales report
  /// GET /api/report/kpi/sales - Sales KPI (requires userId, month, year)
  /// GET /api/report/kpi/marketing - Marketing KPI (requires userId, month, year)
  static const String reportSales = '/api/report/sales';
  static const String reportKpiSales = '/api/report/kpi/sales';
  static const String reportKpiMarketing = '/api/report/kpi/marketing';

  // ---- Targets ----
  /// GET /api/targets/sales - Sales targets (READ ONLY on mobile)
  /// GET /api/targets/marketing - Marketing targets (READ ONLY on mobile)
  static const String targetsSales = '/api/targets/sales';
  static const String targetsMarketing = '/api/targets/marketing';

  // ---- Office Locations ----
  /// GET /api/office-locations/ - Office locations for attendance
  static const String officeLocations = '/api/office-locations/';

  // ---- Lookups ----
  /// GET /api/lookup/list - All lookup values
  /// GET /api/lookup/values/{name} - Lookup by name
  static const String lookupList = '/api/lookup/list';
  static const String lookupValues = '/api/lookup/values';
}
