# 📱 WorkPulse — Sales + Attendance Management System
## Complete Project Documentation & Handover Report

---

## 📋 Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Business Context & Requirements](#2-business-context--requirements)
3. [System Architecture](#3-system-architecture)
4. [Technology Stack](#4-technology-stack)
5. [Complete Folder Structure](#5-complete-folder-structure)
6. [Role-Based Access Control](#6-role-based-access-control)
7. [Feature Documentation](#7-feature-documentation)
8. [Backend API Integration](#8-backend-api-integration)
9. [Resilience & Offline Architecture](#9-resilience--offline-architecture)
10. [Security & Anti-Fraud Measures](#10-security--anti-fraud-measures)
11. [UI/UX Design System](#11-uiux-design-system)
12. [Build, Deployment & Release](#12-build-deployment--release)
13. [Backend Team Action Items](#13-backend-team-action-items)
14. [Production Handover Checklist](#14-production-handover-checklist)
15. [FAQ & Troubleshooting](#15-faq--troubleshooting)
16. [Appendix](#16-appendix)

---

## 1. Executive Summary

### Project Overview

**WorkPulse** is a comprehensive mobile application designed for SoftZen IT to manage field marketing activities, sales operations, and employee attendance. The system integrates a Sales + Attendance management platform with role-based access control, serving three distinct user types: Dealers, Supervisors, and Distributors.

### Key Capabilities

| Capability | Description |
|:---|:---|
| **Role-Based Access** | Three distinct roles with tailored features and permissions |
| **Sales Management** | Order booking, collection tracking, commission management |
| **Field Activity Tracking** | Daily visit management, GPS-based check-in/check-out |
| **Attendance System** | GPS-verified attendance with anti-spoofing measures |
| **Leave Management** | Leave requests with approval workflow |
| **Offline Support** | Data persistence with auto-sync when online |
| **Real-time Dashboards** | Role-specific dashboards with sales analytics |

### Project Status

| Component | Status |
|:---|:---|
| Frontend Architecture | ✅ Complete |
| Role-Based Access Control | ✅ Complete |
| Dashboard Screens (All Roles) | ✅ Complete |
| Order Management | ✅ Complete (Mock Data) |
| Visit Management | ✅ Complete (Mock Data) |
| Collections | ✅ Complete (Mock Data) |
| Complaints | ✅ Complete (Mock Data) |
| Promotions | ✅ Complete (Mock Data) |
| Commissions | ✅ Complete (Mock Data) |
| Offline Sync Service | ✅ Complete |
| Backend API Integration | 🟡 Partial (Backend has 500 errors) |
| Production Deployment | 🟡 Pending Backend SSL Fix |

### Client Information

| Field | Value |
|:---|:---|
| **Client** | SoftZen IT (Softzen Technologies Ltd) |
| **Office** | House 41, Road 13, Block D, Banani, Dhaka 1213 |
| **Office Coordinates** | 23.7937° N, 90.4042° E |
| **Geofence Radius** | 50 meters |
| **Standard Shift** | 09:00 – 18:00 (9 hours) |
| **Grace Period** | 15 minutes |
| **Pay Day** | 25th of each month |
| **Currency** | BDT (Bangladeshi Taka) |

---

## 2. Business Context & Requirements

### 2.1 Original Requirements (From Client)

The client requested a mobile application for monitoring and managing field marketing activities, fully integrated with their ERP system.

**Purpose:**
- Track field activities in real time
- Ensure transparency and accountability
- Measure marketing performance accurately
- Provide management with live insights

### 2.2 User Roles & Permissions

| Feature | Dealer | Supervisor | Distributor |
|:---|:---:|:---:|:---:|
| View Dashboard | ✅ | ✅ | ✅ (limited) |
| View Purchase History | ✅ | ✅ | ❌ |
| Search Distributors | ❌ | ✅ | ❌ |
| View Distributor Orders/Money/Sales | ❌ | ✅ | ❌ |
| Make Order | ❌ | ✅ | ✅ |
| Assign Supervisor (for orders) | N/A | N/A | ✅ (required) |
| Ask for Leave | ❌ | ✅ | ❌ |
| Give Attendance | ❌ | ✅ | ❌ |
| See Assigned Distributors | ❌ | ✅ | ❌ |
| Daily Visit Management | ❌ | ✅ | ❌ |
| Start/End Day | ❌ | ✅ | ❌ |
| Collection Entry | ❌ | ✅ | ❌ |
| Complaint Submission | ❌ | ✅ | ❌ |
| Product Promotion | ❌ | ✅ | ❌ |
| Commission Tracking | ❌ | ✅ | ❌ |
| GPS Tracking | ❌ | ✅ | ❌ |

### 2.3 Sales Team Capabilities

| Capability | Description | Status |
|:---|:---|:---|
| Dealer Visit Entry | Create visit records for dealers | ✅ Implemented |
| Order Booking | Create and manage orders | ✅ Implemented |
| Collection Entry | Record payment collections | ✅ Implemented |
| Complaint/Report Submission | Submit complaints and reports | ✅ Implemented |
| GPS Tracking | Mandatory location capture during visits | ✅ Implemented |
| Snooze | Snooze notifications | 🟡 Planned |
| Role-Based Access | Marketing Executive/Supervisor roles | ✅ Implemented |

### 2.4 Visit Management Requirements

| Requirement | Implementation |
|:---|:---|
| Start day/End day option | ✅ Day Management Screen |
| Create visit entry for dealers, retailers, farmers | ✅ Visit form with client type selection |
| Select visit type (New lead/Follow up/Promotion/Collection) | ✅ Visit type selector |
| Mandatory location capture during visit | ✅ GPS auto-capture |
| Automatic GPS coordinates stored with visit | ✅ VisitLocation model |
| Location cannot be submitted manually | ✅ Enforced in code |
| Visit allowed only when GPS enabled | ✅ Permission check |
| Check-in when reaching visit location | ✅ Visit check-in |
| Check-out after visit completion | ✅ Visit check-out |
| Timestamp and location recorded automatically | ✅ Automatic capture |

### 2.5 Dealer/Client Interaction Requirements

| Requirement | Implementation |
|:---|:---|
| Dealer/client selection from list | ✅ Client selector |
| Add visit notes | ✅ Notes field |
| Permission-wise product access | 🟡 Planned |
| Commission tracking | ✅ Commission module |
| Capture feedback/demand information | ✅ Visit notes |
| Upload visit images (optional) | 🟡 Planned |

### 2.6 Product Promotion Requirements

| Requirement | Implementation |
|:---|:---|
| Select promoted seed products | ✅ Product selection |
| Enter estimated demand | ✅ Demand capture |
| Competitor product info (optional) | 🟡 Planned |

### 2.7 Offline Support Requirements

| Requirement | Implementation |
|:---|:---|
| App works without internet | ✅ Offline detection + local cache |
| Data auto-syncs when connection available | ✅ OfflineSyncService |

---

## 3. System Architecture

### 3.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        MOBILE APPLICATION                        │
│                        (Flutter/Dart)                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                  PRESENTATION LAYER                      │    │
│  │  Screens ← Widgets ← Providers (Riverpod)               │    │
│  │  No direct HTTP calls. Only consumes providers.         │    │
│  └────────────────────────┬────────────────────────────────┘    │
│                           │ watches                              │
│  ┌────────────────────────▼────────────────────────────────┐    │
│  │                    DOMAIN LAYER                          │    │
│  │  Abstract Repository Interfaces + Domain Models         │    │
│  │  Pure Dart. No Flutter/Dio imports.                     │    │
│  └────────────────────────┬────────────────────────────────┘    │
│                           │ implements                           │
│  ┌────────────────────────▼────────────────────────────────┐    │
│  │                     DATA LAYER                           │    │
│  │  Remote Repositories (Dio) + Mock Repositories          │    │
│  │  DTOs (JSON mapping) + Local Cache                      │    │
│  └────────────────────────┬────────────────────────────────┘    │
│                           │                                      │
│  ┌────────────────────────▼────────────────────────────────┐    │
│  │                  CORE INFRASTRUCTURE                     │    │
│  │  ApiClient · AuthInterceptor · LocationService          │    │
│  │  TokenStorage · OfflineSyncService · ConnectivityService│    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└──────────────────────────────────┬──────────────────────────────┘
                                   │ HTTPS (Dio)
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│                      BACKEND API SERVER                          │
│                      (Express.js / Node.js)                      │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Auth Module  │  │ Attendance   │  │ Leave Module │          │
│  │ (JWT+Refresh)│  │ Module       │  │              │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Payroll      │  │ Orders       │  │ Visits       │          │
│  │ Module       │  │ Module       │  │ Module       │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Collections  │  │ Complaints   │  │ Promotions   │          │
│  │ Module       │  │ Module       │  │ Module       │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    DATABASE (ERP)                        │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### 3.2 Design Principles

| Principle | Implementation |
|:---|:---|
| **Separation of Concerns** | Screens never call Dio directly; they only consume Riverpod providers |
| **Repository Pattern** | Abstract interfaces in Domain layer, concrete implementations in Data layer |
| **Dependency Injection** | Riverpod providers handle all DI |
| **Defensive DTOs** | Manual JSON mapping with fallbacks for missing fields |
| **Typed Errors** | `AppFailure`, `AuthFailure`, `NotFoundFailure`, `OfflineFailure` |
| **Response Normalization** | `extractList()` handles `[...]`, `{"data":[...]}`, `{"results":[...]}` |
| **Feature-First Organization** | Each business domain has its own folder with data/domain/presentation |

### 3.3 Data Flow Diagram

```
User Action
    │
    ▼
Screen (Widget)
    │ ref.read(provider.notifier).method()
    ▼
Provider (StateNotifier/Controller)
    │ state = AsyncLoading()
    ▼
Repository (Abstract Interface)
    │
    ▼
Remote Repository (Dio) ──OR── Mock Repository (Local Data)
    │
    ▼
ApiClient (Dio + Interceptors)
    │
    ├── AuthInterceptor (JWT attach, 401 refresh)
    ├── RetryInterceptor (exponential backoff)
    └── LogInterceptor (debug logging)
    │
    ▼
Backend API Server
    │
    ▼
Response → DTO → Domain Model → Provider State → UI Update
```

---

## 4. Technology Stack

### 4.1 Core Technologies

| Category | Technology | Version | Purpose |
|:---|:---|:---|:---|
| **Framework** | Flutter | 3.x (Dart ≥3.0.0) | Cross-platform UI |
| **State Management** | flutter_riverpod | ^2.5.1 | Reactive state, DI |
| **Routing** | go_router | ^14.2.0 | Declarative routing, auth guards |
| **HTTP Client** | dio | ^5.4.3 | API communication |
| **Secure Storage** | flutter_secure_storage | ^9.2.2 | Encrypted token storage |
| **Local Cache** | shared_preferences | ^2.2.3 | Offline data persistence |
| **Location** | geolocator | ^12.0.0 | GPS positioning |
| **Permissions** | permission_handler | ^11.3.1 | Location permissions |
| **Maps** | flutter_map + latlong2 | ^7.0.2 / ^0.9.1 | Interactive maps |
| **Connectivity** | connectivity_plus | ^6.0.3 | Offline detection |
| **Charts** | fl_chart | ^0.68.0 | Sales analytics charts |
| **ID Generation** | uuid | ^4.3.3 | Idempotency keys |
| **Fonts** | google_fonts | ^6.2.1 | Sora + IBM Plex Sans |
| **Date Formatting** | intl | ^0.19.0 | Localization |
| **Image Picker** | image_picker | ^1.0.7 | Visit photo upload (planned) |
| **URL Launcher** | url_launcher | ^6.2.5 | External links |

### 4.2 Development Tools

| Tool | Purpose |
|:---|:---|
| Android Studio / VS Code | IDE |
| Flutter DevTools | Performance debugging |
| `flutter analyze` | Static code analysis |
| `flutter test` | Unit/widget testing |
| Git | Version control |

### 4.3 Backend Stack (Reference)

| Component | Technology |
|:---|:---|
| Runtime | Node.js |
| Framework | Express.js |
| Authentication | JWT + Refresh Tokens |
| Database | ERP System (integrated) |
| SSL | Currently self-signed (needs upgrade) |

---

## 5. Complete Folder Structure

```
workpulse/
├── android/                              # Android native configuration
├── ios/                                  # iOS native configuration (ready)
├── assets/                               # Static assets
│   ├── fonts/                            # Bundled fonts
│   └── images/                           # App images
├── lib/
│   ├── main.dart                         # Entry point, orientation lock
│   │
│   ├── app/                              # App assembly
│   │   ├── app.dart                      # WorkPulseApp (MaterialApp.router)
│   │   ├── router/
│   │   │   └── app_router.dart           # GoRouter config, auth guards, role guards
│   │   ├── shell/
│   │   │   └── shell_screen.dart         # Bottom nav shell (role-based tabs)
│   │   └── theme/
│   │       └── app_theme.dart            # AppColors, AppRadius, AppShadows, AppTheme
│   │
│   ├── core/                             # Shared infrastructure
│   │   ├── constants/
│   │   │   ├── api_endpoints.dart        # All backend API paths
│   │   │   └── app_constants.dart        # Branding, shift defaults
│   │   ├── errors/
│   │   │   └── failures.dart             # AppFailure hierarchy
│   │   ├── models/
│   │   │   ├── activity.dart             # ActivityItem, ActivityType
│   │   │   ├── attendance.dart           # AttendanceRecord, MonthAttendance
│   │   │   ├── check_in_out.dart         # CheckInOutRecord, WorkdayStatus
│   │   │   ├── employee.dart             # Employee model (with role)
│   │   │   ├── leave.dart                # LeaveRequest, LeaveBalance
│   │   │   ├── payment.dart              # PaymentBill, PaymentStatus
│   │   │   └── statement.dart            # EmployeeStatement
│   │   ├── network/
│   │   │   ├── api_client.dart           # Dio wrapper + SSL config
│   │   │   ├── api_config.dart           # Base URL, geofence coords
│   │   │   ├── auth_interceptor.dart     # JWT attach + 401 refresh queue
│   │   │   ├── location_service.dart     # GPS + anti-spoofing
│   │   │   └── token_storage.dart        # FlutterSecureStorage wrapper
│   │   ├── providers/
│   │   │   ├── app_providers.dart        # apiClient, clock, connectivity
│   │   │   ├── connectivity_providers.dart # Network state
│   │   │   └── sync_providers.dart       # Offline sync monitoring
│   │   ├── sync/
│   │   │   └── offline_sync_service.dart # Offline queue + auto-sync
│   │   ├── utils/
│   │   │   ├── api_utils.dart            # extractList()
│   │   │   └── format_utils.dart         # Fmt (dates, money, duration)
│   │   └── widgets/
│   │       ├── buttons.dart              # PrimaryButton, SecondaryButton
│   │       ├── cards.dart                # AppCard, StatCard, InfoRow
│   │       ├── chips.dart                # StatusChip variants
│   │       ├── misc.dart                 # AppScaffold, UserAvatar, MonthSelector
│   │       ├── offline_banner.dart       # Offline connectivity banner
│   │       ├── sheets.dart               # ConfirmationBottomSheet, AppSnack
│   │       └── states.dart               # Shimmer, Skeleton, Empty, Error
│   │
│   ├── shared/                           # Shared across features
│   │   ├── models/
│   │   │   └── user_role.dart            # UserRole enum
│   │   ├── providers/
│   │   │   └── role_providers.dart       # Current role, permissions, nav tabs
│   │   └── widgets/
│   │       ├── role_guard.dart           # Role-based access widget
│   │       └── offline_sync_indicator.dart
│   │
│   ├── mock/                             # Mock data for all roles
│   │   ├── mock_data_dealer.dart         # Dealer dashboard, orders, products
│   │   ├── mock_data_supervisor.dart     # Supervisor stats, distributors, visits
│   │   └── mock_data_distributor.dart    # Distributor stats, orders
│   │
│   └── features/                         # One folder per business domain
│       ├── auth/                         # Authentication
│       │   ├── data/
│       │   │   ├── dto/
│       │   │   │   ├── auth_dto.dart     # LoginResponseDto
│       │   │   │   └── employee_dto.dart # EmployeeDto
│       │   │   └── remote_auth_repository.dart
│       │   ├── domain/repositories/
│       │   │   └── auth_repository.dart
│       │   └── presentation/
│       │       ├── providers/auth_providers.dart
│       │       └── screens/
│       │           ├── login_screen.dart  # With role selection
│       │           └── splash_screen.dart
│       │
│       ├── dashboard/                    # Role-based dashboards
│       │   ├── presentation/
│       │   │   ├── providers/
│       │   │   │   └── dashboard_providers.dart
│       │   │   ├── screens/
│       │   │   │   ├── dealer_dashboard_screen.dart
│       │   │   │   ├── supervisor_dashboard_screen.dart
│       │   │   │   └── distributor_dashboard_screen.dart
│       │   │   └── widgets/
│       │   │       ├── stats_card.dart
│       │   │       ├── sales_chart.dart
│       │   │       ├── order_list_tile.dart
│       │   │       └── distributor_search_bar.dart
│       │
│       ├── orders/                       # Order management
│       │   ├── data/
│       │   │   └── mock_order_repository.dart
│       │   ├── domain/
│       │   │   ├── models/
│       │   │   │   ├── order.dart
│       │   │   │   ├── order_item.dart
│       │   │   │   ├── order_status.dart
│       │   │   │   └── product.dart
│       │   │   └── repositories/
│       │   │       └── order_repository.dart
│       │   └── presentation/
│       │       ├── providers/order_providers.dart
│       │       ├── screens/
│       │       │   ├── order_list_screen.dart
│       │       │   ├── order_detail_screen.dart
│       │       │   └── new_order_screen.dart
│       │       └── widgets/
│       │           └── order_card.dart
│       │
│       ├── visits/                       # Visit management
│       │   ├── data/
│       │   │   └── mock_visit_repository.dart
│       │   ├── domain/
│       │   │   ├── models/
│       │   │   │   ├── visit.dart
│       │   │   │   ├── visit_type.dart
│       │   │   │   ├── client.dart
│       │   │   │   └── visit_status.dart
│       │   │   └── repositories/
│       │   │       └── visit_repository.dart
│       │   └── presentation/
│       │       ├── providers/visit_providers.dart
│       │       ├── screens/
│       │       │   ├── visit_list_screen.dart
│       │       │   └── day_management_screen.dart
│       │       └── widgets/
│       │           └── visit_card.dart
│       │
│       ├── attendance/                   # Attendance tracking
│       │   ├── data/
│       │   │   ├── dto/attendance_dto.dart
│       │   │   └── remote_attendance_repository.dart
│       │   ├── domain/repositories/
│       │   │   └── attendance_repository.dart
│       │   └── presentation/
│       │       ├── providers/attendance_providers.dart
│       │       ├── screens/
│       │       │   ├── attendance_screen.dart
│       │       │   ├── attendance_detail_screen.dart
│       │       │   ├── check_in_out_screen.dart
│       │       │   └── location_rationale_screen.dart
│       │       └── widgets/
│       │           ├── attendance_calendar.dart
│       │           └── attendance_record_card.dart
│       │
│       ├── leave/                        # Leave management
│       │   ├── data/
│       │   │   ├── dto/leave_dto.dart
│       │   │   ├── leave_local_cache.dart
│       │   │   └── remote_leave_repository.dart
│       │   ├── domain/repositories/
│       │   │   └── leave_repository.dart
│       │   └── presentation/
│       │       ├── providers/leave_providers.dart
│       │       ├── screens/
│       │       │   ├── leave_requests_screen.dart
│       │       │   ├── leave_detail_screen.dart
│       │       │   └── new_leave_request_screen.dart
│       │       └── widgets/
│       │           └── leave_request_card.dart
│       │
│       ├── payments/                     # Payroll/Payments
│       │   ├── data/
│       │   │   ├── dto/payment_dto.dart
│       │   │   └── remote_payment_repository.dart
│       │   ├── domain/repositories/
│       │   │   └── payment_repository.dart
│       │   └── presentation/
│       │       ├── providers/payment_providers.dart
│       │       ├── screens/
│       │       │   ├── payments_screen.dart
│       │       │   └── payment_detail_screen.dart
│       │       └── widgets/
│       │           └── payment_card.dart
│       │
│       ├── collections/                  # Payment collections
│       │   ├── data/
│       │   │   └── mock_collection_repository.dart
│       │   ├── domain/
│       │   │   ├── models/collection.dart
│       │   │   └── repositories/collection_repository.dart
│       │   └── presentation/
│       │       ├── providers/collection_providers.dart
│       │       └── screens/collection_list_screen.dart
│       │
│       ├── complaints/                   # Complaints/Reports
│       │   ├── data/
│       │   │   └── mock_complaint_repository.dart
│       │   ├── domain/
│       │   │   ├── models/complaint.dart
│       │   │   └── repositories/complaint_repository.dart
│       │   └── presentation/
│       │       ├── providers/complaint_providers.dart
│       │       └── screens/complaint_list_screen.dart
│       │
│       ├── promotions/                   # Product promotions
│       │   ├── data/
│       │   │   └── mock_promotion_repository.dart
│       │   ├── domain/
│       │   │   ├── models/promotion.dart
│       │   │   └── repositories/promotion_repository.dart
│       │   └── presentation/
│       │       ├── providers/promotion_providers.dart
│       │       └── screens/promotion_list_screen.dart
│       │
│       ├── commissions/                  # Commission tracking
│       │   ├── data/
│       │   │   └── mock_commission_repository.dart
│       │   ├── domain/
│       │   │   ├── models/commission.dart
│       │   │   └── repositories/commission_repository.dart
│       │   └── presentation/
│       │       ├── providers/commission_providers.dart
│       │       └── screens/commission_screen.dart
│       │
│       ├── home/                         # Home/Dashboard (legacy)
│       │   └── presentation/
│       │       ├── screens/home_screen.dart
│       │       └── widgets/
│       │           ├── checkin_hero_card.dart
│       │           ├── home_sections.dart
│       │           └── office_map_card.dart
│       │
│       ├── profile/                      # User profile & settings
│       │   └── presentation/
│       │       ├── providers/profile_providers.dart
│       │       └── screens/
│       │           ├── profile_screen.dart
│       │           ├── more_screen.dart
│       │           ├── settings_screen.dart
│       │           ├── help_support_screen.dart
│       │           └── legal_screen.dart
│       │
│       └── statement/                    # Monthly statements
│           ├── data/
│           │   └── remote_statement_repository.dart
│           ├── domain/repositories/
│           │   └── statement_repository.dart
│           └── presentation/
│               ├── providers/statement_providers.dart
│               └── screens/statement_screen.dart
│
├── test/                                 # Test files
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml                          # Dependencies
├── analysis_options.yaml                 # Lint rules
├── README.md                             # This document
└── CHANGELOG.md                          # Version history
```

---

## 6. Role-Based Access Control

### 6.1 Role Definitions

| Role | Description | Access Level |
|:---|:---|:---|
| **Dealer** | Views purchase history and dashboard | Read-only |
| **Supervisor** | Full access to all features | Read + Write |
| **Distributor** | Makes orders, views limited dashboard | Limited Write |

### 6.2 Role Determination

The user's role is determined from their employee profile:

```dart
// In role_providers.dart
final currentUserRoleProvider = Provider<UserRole>((ref) {
  final employee = ref.watch(authControllerProvider).valueOrNull;
  if (employee == null) return UserRole.dealer;
  
  final designation = employee.designation.toLowerCase();
  if (designation.contains('supervisor')) return UserRole.supervisor;
  if (designation.contains('distributor')) return UserRole.distributor;
  return UserRole.dealer;
});
```

### 6.3 Navigation by Role

| Role | Bottom Navigation Tabs |
|:---|:---|
| **Dealer** | Dashboard · Orders · Profile |
| **Supervisor** | Dashboard · Visits · Orders · Attendance · More |
| **Distributor** | Dashboard · Orders · Profile |

### 6.4 Route Guards

The router enforces role-based access at the navigation level:

```dart
// In app_router.dart redirect logic
if (authed) {
  if (loc.startsWith('/visits') && role != UserRole.supervisor) return '/dashboard';
  if (loc.startsWith('/attendance') && role != UserRole.supervisor) return '/dashboard';
  if (loc.startsWith('/leave') && role != UserRole.supervisor) return '/dashboard';
  if (loc.startsWith('/collections') && role != UserRole.supervisor) return '/dashboard';
  if (loc.startsWith('/complaints') && role != UserRole.supervisor) return '/dashboard';
  if (loc.startsWith('/promotions') && role != UserRole.supervisor) return '/dashboard';
  if (loc.startsWith('/commissions') && role != UserRole.supervisor) return '/dashboard';
}
```

### 6.5 Widget-Level Guards

The `RoleGuard` widget provides declarative access control:

```dart
RoleGuard(
  feature: 'visits',
  child: VisitListScreen(),
  fallback: AccessDeniedWidget(feature: 'visits'),
)
```

---

## 7. Feature Documentation

### 7.1 Authentication

**Flow:**
1. User enters credentials + selects role
2. `POST /api/auth/login` returns JWT + Refresh Token
3. Tokens stored in `flutter_secure_storage`
4. Profile fetched from `GET /api/employees/?id=`
5. Router redirects to role-appropriate dashboard

**Auto-Login:** On app restart, `AuthController` checks stored tokens and silently fetches profile.

**Token Refresh:** `AuthInterceptor` handles 401 errors by queuing requests, refreshing the token, and retrying.

### 7.2 Dashboard (Role-Based)

**Dealer Dashboard:**
- Total purchases, orders, outstanding amount
- Monthly sales chart
- Recent orders list

**Supervisor Dashboard:**
- Total sales, orders, pending, outstanding
- Quick actions (Start Day, New Visit, New Order, Collection)
- Assigned distributors list with search
- Monthly sales chart

**Distributor Dashboard:**
- Total purchases, orders, outstanding
- My orders list
- New Order FAB

### 7.3 Order Management

**Features:**
- Order list with status filters
- Order detail with item breakdown
- New order form with product selection
- Distributor must assign supervisor
- Idempotency keys prevent duplicates

**Order Statuses:** Pending → Processing → Shipped → Delivered / Cancelled

### 7.4 Visit Management (Supervisor Only)

**Features:**
- Day management (Start/End day)
- Visit list with status
- Visit creation with client selection
- Visit types: New Lead, Follow Up, Promotion, Collection
- Client types: Dealer, Retailer, Farmer
- GPS-based check-in/check-out at visit location
- Mandatory location capture

### 7.5 Attendance (Supervisor Only)

**Features:**
- GPS-verified check-in/check-out
- 50-meter geofence enforcement
- Anti-spoofing (mock location detection)
- Monthly calendar with color-coded statuses
- Attendance summary (Present, Late, Absent)
- Server timestamp trust (prevents clock manipulation)

### 7.6 Leave Management (Supervisor Only)

**Features:**
- Leave request submission
- Leave balance tracking
- Approval status tracking
- Local caching for 500 error fallback
- "Awaiting server sync" indicator for local-only requests

### 7.7 Collections (Supervisor Only)

**Features:**
- Collection entry with client, amount, payment method
- Collection history
- Reference number tracking

### 7.8 Complaints (Supervisor Only)

**Features:**
- Complaint submission with priority levels
- Status tracking (Open, In Progress, Resolved, Closed)
- Priority levels (Low, Medium, High, Urgent)

### 7.9 Promotions (Supervisor Only)

**Features:**
- Active promotions list
- Product selection
- Discount percentage
- Target client specification
- Date range validation

### 7.10 Commissions (Supervisor Only)

**Features:**
- Monthly commission tracking
- Commission rate display
- Total sales vs commission amount
- Payment status (Pending/Paid)

### 7.11 Offline Support

**Features:**
- Offline detection with visual banner
- Operation queuing when offline
- Auto-sync when connection restored
- Pending operations counter
- Local data persistence

---

## 8. Backend API Integration

### 8.1 Base Configuration

| Parameter | Value |
|:---|:---|
| **Base URL (Dev)** | `https://202.83.126.123:5000` |
| **Base URL (Prod)** | TBD (awaiting SSL cert) |
| **Auth Method** | Bearer JWT (15-min expiry) + Hex Refresh Token |
| **Client Header** | `x-client-type: android` |

### 8.2 Endpoint Map

| Method | Path | Feature | Status |
|:---|:---|:---|:---|
| `POST` | `/api/auth/login` | Auth | ✅ Working |
| `POST` | `/api/auth/logout` | Auth | ✅ Working |
| `POST` | `/api/auth/refresh` | Auth | ✅ Working |
| `GET` | `/api/employees/?id=` | Profile | ✅ Working |
| `GET` | `/api/attendance/attendance/today` | Attendance | ✅ Working |
| `POST` | `/api/attendance/check-in` | Attendance | ✅ Working |
| `PATCH` | `/api/attendance/check-out` | Attendance | ✅ Working |
| `GET` | `/api/attendance/report` | Attendance | 🐛 500 Error |
| `GET` | `/api/attendance/statement` | Statement | 🐛 500 Error |
| `GET` | `/api/leave-requests/?userId=` | Leave | ✅ Working |
| `GET` | `/api/leave-requests/leave-balance` | Leave | ✅ Working |
| `POST` | `/api/leave-requests/` | Leave | 🐛 500 Error |
| `GET` | `/api/payroll/?userId=` | Payments | ✅ Working |

### 8.3 Authentication Flow

```
┌─────────┐          ┌──────────┐          ┌──────────────┐
│  Login  │──POST──▶│ /api/auth│──200──▶  │ Store tokens │
│  Screen │          │ /login   │          │ in SecureSt. │
└─────────┘          └──────────┘          └──────┬───────┘
                                                   │
                                                   ▼
                                          ┌────────────────┐
                                          │ Fetch profile  │
                                          │ GET /employees │
                                          └───────┬────────┘
                                                  │
                                                  ▼
                                          ┌────────────────┐
                                          │ AuthController │
                                          │ state = Emp    │
                                          └───────┬────────┘
                                                  │
                                                  ▼
                                          ┌────────────────┐
                                          │ Router redirect│
                                          │ → /dashboard   │
                                          └────────────────┘
```

### 8.4 Token Refresh Flow

```
API Request → 401 "token expired"
    │
    ▼
AuthInterceptor.onError()
    │
    ├── Is it /login or /refresh? → NO (skip)
    ├── Is _isRefreshing? → YES (queue request)
    └── NO → Set _isRefreshing = true
              │
              ▼
         POST /api/auth/refresh
              │
              ├── Success → Update storage, retry queued requests
              └── Failure → Clear storage, force logout
```

### 8.5 Global Headers

```http
Authorization: Bearer <accessToken>
Accept: application/json
Content-Type: application/json
x-client-type: android
x-refresh-token: <refreshToken>
```

---

## 9. Resilience & Offline Architecture

### 9.1 Leave Request Local Caching

**Problem:** `POST /api/leave-requests/` returns 500 Internal Server Error.

**Solution:**
- App catches 500 error and creates local request with `isLocalOnly: true`
- Request saved to `shared_preferences` via `LeaveLocalCache`
- On fetch, server data merged with local cache
- UI shows "Awaiting server sync" badge
- Cache cleared when backend is fixed

### 9.2 Statement Composition

**Problem:** `GET /api/attendance/statement` returns 500.

**Solution:** `RemoteStatementRepository` uses `Future.wait` with `safeFetch` wrapper to concurrently fetch Attendance, Leave, and Payment data, stitching them together client-side.

### 9.3 Offline Sync Service

**Architecture:**
```
User Action (offline)
    │
    ▼
OfflineSyncService.queueOperation()
    │
    ▼
SharedPreferences (persistent storage)
    │
    ▼
[Connection Restored]
    │
    ▼
OfflineSyncService.processPending()
    │
    ▼
API Calls → Success/Failure
    │
    ▼
Clear processed operations
```

### 9.4 Connectivity Monitoring

- `connectivity_plus` monitors network state
- `OfflineBanner` shows when offline
- `OfflineSyncIndicator` shows pending operations count
- Auto-sync triggers when connection restored

---

## 10. Security & Anti-Fraud Measures

### 10.1 GPS Spoofing Detection

| Measure | Implementation |
|:---|:---|
| Mock location check | `position.isMocked` flag checked on every sample |
| Multi-sample verification | 3 GPS samples taken and averaged |
| Drift detection | Identical coordinates with 0m drift flagged as suspicious |
| Accuracy validation | Samples with >100m accuracy rejected |

### 10.2 Clock Manipulation Prevention

| Measure | Implementation |
|:---|:---|
| Server timestamp trust | App uses server's `checkInTime`/`checkOutTime`, not device time |
| Device timestamp audit | Device time sent for audit purposes only |
| Backend enforcement | Backend MUST use server clock for actual timestamps |

### 10.3 Geofence Enforcement

| Parameter | Value |
|:---|:---|
| Office Coordinates | 23.7937° N, 90.4042° E |
| Geofence Radius | 50 meters |
| Enforcement | Backend validates coordinates |
| Error Response | `{"error":"You are not within the office location range"}` |

### 10.4 Secure Token Storage

- Tokens stored in `flutter_secure_storage` (Android Keystore / iOS Keychain)
- Never stored in plain text
- Cleared on logout and failed refresh

### 10.5 Location Permission Rationale

- Dedicated `LocationRationaleScreen` shown before first permission request
- Explains why location is needed
- Satisfies Google Play Store policies

### 10.6 Portrait Lock

- App locked to `DeviceOrientation.portraitUp`
- Prevents layout breakages

---

## 11. UI/UX Design System

### 11.1 Color Palette

| Token | Light | Dark | Usage |
|:---|:---|:---|:---|
| `primary` | `#155EEF` | — | Buttons, links, accents |
| `navy` | `#122A4C` | — | Headers, dark sections |
| `canvas` | `#F5F7FB` | `#0D1420` | Scaffold background |
| `surface` | `#FFFFFF` | `#151D2C` | Cards, sheets |
| `border` | `#E7EBF3` | `#26334A` | Dividers, outlines |
| `textPrimary` | `#101828` | — | Headings |
| `textSecondary` | `#667085` | — | Body, labels |
| `success` | `#12B76A` | — | Present, Approved, Paid |
| `warning` | `#F79009` | — | Late, Pending |
| `danger` | `#D92D20` | — | Absent, Rejected, Failed |
| `gray` | `#98A2B3` | — | Disabled, muted |

### 11.2 Typography

| Style | Font | Size | Weight |
|:---|:---|:---|:---|
| Display | Sora | 30px | 700 |
| Headline | Sora | 20px | 600 |
| Title | IBM Plex Sans | 17px | 600 |
| Body | IBM Plex Sans | 14px | 400 |
| Label | IBM Plex Sans | 12px | 500 |

### 11.3 Spacing System

Based on 8px grid:
- `AppRadius.sm` = 10px
- `AppRadius.md` = 14px
- `AppRadius.lg` = 18px
- `AppRadius.xl` = 22px

### 11.4 Shared Widget Library

| Widget | File | Purpose |
|:---|:---|:---|
| `AppCard` | cards.dart | Base card with border + shadow |
| `StatCard` | stats_card.dart | Dashboard metric tile |
| `QuickActionCard` | cards.dart | Icon + label action tile |
| `InfoRow` | cards.dart | Label-value detail row |
| `StatusChip` | chips.dart | Colored status badge |
| `AppScaffold` | misc.dart | Page wrapper with app bar |
| `UserAvatar` | misc.dart | Initials-based avatar |
| `MonthSelector` | misc.dart | Month navigation arrows |
| `PrimaryButton` | buttons.dart | Full-width elevated button |
| `SecondaryButton` | buttons.dart | Full-width outlined button |
| `ConfirmationBottomSheet` | sheets.dart | Confirm/cancel modal |
| `AppSnack` | sheets.dart | Success/error/info snackbar |
| `Shimmer` | states.dart | Loading shimmer effect |
| `LoadingSkeleton` | states.dart | Placeholder card skeleton |
| `EmptyStateWidget` | states.dart | No data state |
| `ErrorStateWidget` | states.dart | Error + retry state |
| `OfflineBanner` | offline_banner.dart | Offline indicator |
| `RoleGuard` | role_guard.dart | Role-based access control |
| `OfflineSyncIndicator` | offline_sync_indicator.dart | Pending sync count |

---

## 12. Build, Deployment & Release

### 12.1 SSL Certificate Issue (CRITICAL)

| Build Type | SSL Behavior | Login Status |
|:---|:---|:---|
| **Debug** (`flutter run`) | Self-signed cert bypass enabled | ✅ Works |
| **Release** (APK/AAB) | Android enforces valid SSL | ❌ Fails without fix |

**Temporary Fix (Internal Testing):**
Comment out `if (!kDebugMode) return;` in `api_client.dart`

**Permanent Fix (Production):**
Backend team must install valid SSL certificate (Let's Encrypt)

### 12.2 Build Commands

```bash
# Debug APK (for internal testing)
flutter build apk --debug

# Release APK (requires valid SSL)
flutter build apk --release

# Release AAB for Play Store
flutter build appbundle --release

# With obfuscation (recommended)
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

### 12.3 Native Splash Screen

```bash
# Regenerate after changing colors
dart run flutter_native_splash:create
```

### 12.4 Release Checklist

- [ ] Update `ApiConfig.baseUrl` to production domain
- [ ] Verify backend has valid SSL certificate
- [ ] Restore `if (!kDebugMode) return;` in `api_client.dart`
- [ ] Build and test release APK on physical device
- [ ] Test all features end-to-end
- [ ] Generate final AAB for Play Store
- [ ] Remove any temporary testing flags

---

## 13. Backend Team Action Items

### 🔴 Priority 1: Install Valid SSL Certificate

**Issue:** Release APKs cannot connect due to self-signed cert.
**Fix:** Install Let's Encrypt or similar valid SSL certificate.
**Impact:** Blocks all release APK functionality.

### 🔴 Priority 2: Fix 500 Internal Server Errors

| Endpoint | Impact | Current Workaround |
|:---|:---|:---|
| `POST /api/leave-requests/` | Blocks leave submission | Local cache |
| `GET /api/attendance/report` | Blocks attendance calendar | Error state |
| `GET /api/attendance/statement` | Blocks statement endpoint | Composite fetch |

### 🟠 Priority 3: Server-Side Timestamps

**Requirement:** Use server clock for `checkInTime`/`checkOutTime`, not client time.
**Reason:** Prevents clock manipulation fraud.

### 🟠 Priority 4: Idempotency Keys

**Requirement:** Honor `requestId` (UUID) in POST requests.
**Reason:** Prevents duplicate submissions.

### 🟡 Priority 5: New API Endpoints Needed

| Endpoint | Purpose |
|:---|:---|
| `GET /api/orders/` | Order list |
| `POST /api/orders/` | Create order |
| `GET /api/orders/:id` | Order detail |
| `GET /api/visits/` | Visit list |
| `POST /api/visits/` | Create visit |
| `PATCH /api/visits/:id/check-in` | Visit check-in |
| `PATCH /api/visits/:id/check-out` | Visit check-out |
| `GET /api/collections/` | Collection list |
| `POST /api/collections/` | Create collection |
| `GET /api/complaints/` | Complaint list |
| `POST /api/complaints/` | Create complaint |
| `GET /api/promotions/` | Promotion list |
| `GET /api/commissions/` | Commission list |
| `GET /api/distributors/` | Distributor list (for supervisor) |
| `GET /api/distributors/:id` | Distributor detail |

---

## 14. Production Handover Checklist

### Frontend Team

- [ ] All features implemented and tested
- [ ] Role-based access verified for all three roles
- [ ] Offline sync tested
- [ ] GPS anti-spoofing verified
- [ ] All mock data replaced with real API calls (when backend ready)
- [ ] Release APK builds successfully
- [ ] No `flutter analyze` errors
- [ ] Documentation complete

### Backend Team

- [ ] Valid SSL certificate installed
- [ ] All 500 errors fixed
- [ ] Server-side timestamps implemented
- [ ] Idempotency keys implemented
- [ ] New API endpoints created (orders, visits, collections, etc.)
- [ ] Role-based data filtering implemented
- [ ] API documentation updated (Swagger)

### QA Team

- [ ] Test on multiple Android versions (API 26, 29, 31, 33, 34)
- [ ] Test on multiple manufacturers (Samsung, Xiaomi, Huawei, Pixel)
- [ ] Test all three roles end-to-end
- [ ] Test offline scenarios
- [ ] Test GPS spoofing prevention
- [ ] Test clock manipulation prevention
- [ ] Test with poor network conditions
- [ ] Test with app killed during operations

### DevOps Team

- [ ] CI/CD pipeline configured
- [ ] Automated builds on PR
- [ ] Staged rollout configured (10% → 50% → 100%)
- [ ] Crash reporting configured
- [ ] Performance monitoring configured

### Play Store Submission

- [ ] App Bundle (.aab) generated
- [ ] Data Safety form completed
- [ ] Location permission rationale provided
- [ ] Privacy Policy URL provided
- [ ] App signing configured
- [ ] Screenshots prepared (phone + tablet)
- [ ] App description written

---

## 15. FAQ & Troubleshooting

### Q: Why does the Release APK fail to login?
**A:** The backend uses a self-signed SSL certificate. Android blocks this in release mode. Install a valid SSL certificate on the backend.

### Q: Why does check-in say "not within office location"?
**A:** You must be within 50 meters of the office coordinates (23.7937, 90.4042). The backend enforces this geofence.

### Q: Why does leave request show "Awaiting server sync"?
**A:** The backend's leave submission endpoint returns 500. The request is saved locally and will sync when the backend is fixed.

### Q: Can employees use fake GPS apps?
**A:** No. The app detects mock locations and blocks check-in.

### Q: What happens if the user's phone clock is wrong?
**A:** The app trusts the server's timestamp, not the device time. Clock manipulation is prevented.

### Q: How do I add a new feature?
**A:** Follow the Clean Architecture pattern:
1. Create folder in `lib/features/`
2. Create `data/`, `domain/`, `presentation/` subfolders
3. Create models, repository interface, repository implementation
4. Create providers, screens, widgets
5. Add route in `app_router.dart`

### Q: How do I switch from mock data to real API?
**A:** Replace `MockXxxRepository` with `RemoteXxxRepository` in the provider:
```dart
final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => RemoteOrderRepository(ref.read(apiClientProvider)), // Change this
);
```

### Q: How do I test offline mode?
**A:** Disable WiFi and mobile data on the device. The offline banner should appear and operations should be queued.

---

## 16. Appendix

### 16.1 Mock Data Files

| File | Role | Contents |
|:---|:---|:---|
| `mock_data_dealer.dart` | Dealer | Dashboard stats, orders, products |
| `mock_data_supervisor.dart` | Supervisor | Stats, distributors, visits, collections, complaints, promotions, commissions |
| `mock_data_distributor.dart` | Distributor | Stats, orders, supervisors, products |

### 16.2 Environment Configuration

| Environment | Base URL | SSL |
|:---|:---|:---|
| Development | `https://202.83.126.123:5000` | Self-signed (bypass in debug) |
| Staging | TBD | Valid cert required |
| Production | TBD | Valid cert required |

### 16.3 Key Constants

| Constant | Value | Location |
|:---|:---|:---|
| Office Latitude | 23.7937 | `api_config.dart` |
| Office Longitude | 90.4042 | `api_config.dart` |
| Geofence Radius | 50m | `api_config.dart` |
| Shift Start | 09:00 | `app_constants.dart` |
| Shift End | 18:00 | `app_constants.dart` |
| Grace Period | 15 min | `app_constants.dart` |
| Token Expiry | 15 min | Backend |

### 16.4 Version History

| Version | Date | Changes |
|:---|:---|:---|
| 1.0.0 | Aug 2026 | Initial release with attendance, leave, payments |
| 2.0.0 | Aug 2026 | Added role-based access, dashboards, orders, visits, collections, complaints, promotions, commissions, offline sync |

---

## 📞 Support & Contact

| Role | Contact |
|:---|:---|
| **Backend Team** | backend@softzen.com |
| **Frontend Team** | frontend@softzen.com |
| **HR / People Ops** | peopleops@softzentech.co.uk |
| **Security Issues** | security@softzen.com |
| **Project Manager** | pm@softzen.com |

---

## 📄 License

Proprietary — Softzen Technologies Ltd. All rights reserved.

---

## 👥 Credits

| Role | Name/Team |
|:---|:---|
| **Client** | SoftZen IT (Softzen Technologies Ltd) |
| **Backend** | SoftZen IT Backend Team |
| **Mobile** | WorkPulse Development Team |
| **Design** | In-house Material 3 design system |
| **QA** | SoftZen IT QA Team |

---

**Document Version:** 2.0.0  
**Last Updated:** August 2026  
**Maintained By:** WorkPulse Development Team  
**Next Review:** After backend SSL certificate installation and API endpoint completion

---

*End of Document*
