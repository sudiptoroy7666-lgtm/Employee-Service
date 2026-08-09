# 📱 WorkPulse — Employee Self-Service Mobile App

> A production-grade Flutter application for employee attendance management, leave requests, payroll viewing, and company notifications. Built with Riverpod, GoRouter, and Clean Architecture principles.

---

## 📋 Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Architecture & Design Principles](#3-architecture--design-principles)
4. [Folder Structure](#4-folder-structure)
5. [Getting Started](#5-getting-started)
6. [Backend API Reference](#6-backend-api-reference)
7. [Core Infrastructure](#7-core-infrastructure)
8. [Feature Modules](#8-feature-modules)
9. [State Management Patterns](#9-state-management-patterns)
10. [Networking Layer](#10-networking-layer)
11. [Authentication Flow](#11-authentication-flow)
12. [Geofencing & Location](#12-geofencing--location)
13. [Error Handling Strategy](#13-error-handling-strategy)
14. [UI / Design System](#14-ui--design-system)
15. [Known Backend Bugs & Frontend Workarounds](#15-known-backend-bugs--frontend-workarounds)
16. [Developer Tools (Debug)](#16-developer-tools-debug)
17. [How to Add a New Feature](#17-how-to-add-a-new-feature)
18. [Configuration Reference](#18-configuration-reference)
19. [Production Handover Checklist](#19-production-handover-checklist)
20. [FAQ / Troubleshooting](#20-faq--troubleshooting)

---

## 1. Project Overview

**WorkPulse** is an employee self-service mobile application for **SoftZen IT**. It allows employees to:

- ✅ **Check in / Check out** with GPS-verified geofencing (50m radius of office)
- 📅 **View attendance history** with a monthly calendar, summaries, and per-day records
- 🏖️ **Request leave** and track approval status
- 💰 **View payroll** history with gross/net breakdowns
- 📊 **Generate monthly statements** combining attendance, leave, and payment data
- 🔔 **Receive notifications** for attendance, leave, and payment events
- 👤 **View and manage** their employee profile

### Business Context

| Item | Detail |
|------|--------|
| **Company** | SoftZen IT (Softzen Technologies Ltd) |
| **Office** | House 41, Road 13, Block D, Banani, Dhaka 1213 |
| **Office Coordinates** | `23.7937` N, `90.4042` E |
| **Geofence Radius** | 50 meters |
| **Shift** | 09:00 – 18:00 (9 hours) |
| **Grace Period** | 15 minutes |
| **Pay Day** | 25th of each month |
| **Currency** | BDT (Bangladeshi Taka) |

---

## 2. Tech Stack

| Concern | Choice | Version / Notes |
|---------|--------|-----------------|
| **Framework** | Flutter | 3.x, Dart `>=3.0.0 <4.0.0` |
| **Platform** | Android | iOS-ready but not yet configured |
| **State Management** | `flutter_riverpod` | Providers, StateNotifier, FutureProvider, Family |
| **Routing** | `go_router` | StatefulShellRoute + auth redirect |
| **Networking** | `dio` | Custom interceptors, auto-refresh |
| **Secure Storage** | `flutter_secure_storage` | Tokens, user ID |
| **Location** | `geolocator` + `permission_handler` | GPS check-in/out |
| **Fonts** | `google_fonts` | Sora (display), IBM Plex Sans (body) |
| **Date Formatting** | `intl` | DateFormat, NumberFormat |
| **UI** | Material 3 | Custom design tokens |

---

## 3. Architecture & Design Principles

### Pattern: Feature-First Clean Architecture

```text
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                   │
│   Screens ← Widgets ← Providers (Riverpod)              │
│   No direct HTTP calls. Only consumes providers.        │
└───────────────────────────┬─────────────────────────────┘
                            │ watches
┌───────────────────────────▼─────────────────────────────┐
│                      DOMAIN LAYER                       │
│   Abstract Repository Interfaces + Domain Models        │
│   Pure Dart. No Flutter/Dio imports.                    │
└───────────────────────────┬─────────────────────────────┘
                            │ implements
┌───────────────────────────▼─────────────────────────────┐
│                       DATA LAYER                        │
│   Remote Repositories (Dio) + DTOs (JSON mapping)       │
│   Talks to ApiClient. Maps JSON → Domain Models.        │
└─────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Screens never touch Dio.** They only `ref.watch(...)` providers.
2. **Repositories are abstract.** Swapping remote → mock is a one-file change.
3. **DTOs are per-feature.** No global JSON serialization library. Manual mapping for clarity.
4. **Errors are typed.** `AppFailure`, `AuthFailure`, `NotFoundFailure`, `OfflineFailure`.
5. **List responses are normalized.** `extractList()` handles `[...]`, `{"data":[...]}`, `{"results":[...]}`.

---

## 4. Folder Structure

```text
lib/
├── main.dart                          # App entry point
├── app/                               # App assembly
│   ├── app.dart                       # WorkPulseApp (MaterialApp.router)
│   ├── router/
│   │   └── app_router.dart            # GoRouter config (routes, auth redirect)
│   ├── shell/
│   │   └── shell_screen.dart          # Bottom nav shell (StatefulShellRoute)
│   └── theme/
│       └── app_theme.dart             # AppColors, AppRadius, AppShadows, AppTheme
├── core/                              # Shared, feature-agnostic infrastructure
│   ├── constants/
│   │   ├── api_endpoints.dart         # All backend API paths
│   │   └── app_constants.dart         # Branding, shift defaults, support info
│   ├── errors/
│   │   └── failures.dart              # AppFailure hierarchy
│   ├── models/
│   │   ├── activity.dart              # ActivityItem, ActivityType
│   │   ├── attendance.dart            # AttendanceRecord, MonthAttendance, etc.
│   │   ├── check_in_out.dart          # CheckInOutRecord, WorkdayStatus
│   │   ├── employee.dart              # Employee model
│   │   ├── leave.dart                 # LeaveRequest, LeaveBalance, LeaveType
│   │   ├── notification.dart          # AppNotification, AppNotificationType
│   │   ├── payment.dart               # PaymentBill, PaymentStatus
│   │   └── statement.dart             # EmployeeStatement, WorkSummary, etc.
│   ├── network/
│   │   ├── api_client.dart            # Dio wrapper + self-signed cert bypass
│   │   ├── api_config.dart            # Base URL, geofence coords, headers
│   │   ├── auth_interceptor.dart      # JWT attach + 401 refresh queue
│   │   ├── location_service.dart      # GPS + geofence fallback
│   │   └── token_storage.dart         # FlutterSecureStorage wrapper
│   ├── providers/
│   │   └── app_providers.dart         # Global providers (apiClient, clock, etc.)
│   ├── utils/
│   │   ├── api_utils.dart             # extractList()
│   │   └── format_utils.dart          # Fmt (dates, money, duration, relative)
│   └── widgets/
│       ├── buttons.dart               # PrimaryButton, SecondaryButton
│       ├── cards.dart                 # AppCard, StatCard, QuickActionCard, InfoRow
│       ├── chips.dart                 # StatusChip, AttendanceStatusChip, etc.
│       ├── misc.dart                  # AppScaffold, UserAvatar, MonthSelector, etc.
│       ├── sheets.dart                # ConfirmationBottomSheet, AppSnack
│       └── states.dart                # Shimmer, LoadingSkeleton, Empty/Error states
└── features/                          # One folder per business domain
    ├── auth/
    │   ├── data/
    │   │   ├── dto/
    │   │   │   ├── auth_dto.dart      # LoginResponseDto
    │   │   │   └── employee_dto.dart  # EmployeeDto
    │   │   └── remote_auth_repository.dart
    │   ├── domain/repositories/
    │   │   └── auth_repository.dart   # Abstract AuthenticationRepository
    │   └── presentation/
    │       ├── providers/auth_providers.dart
    │       └── screens/
    │           ├── login_screen.dart
    │           └── splash_screen.dart
    ├── attendance/
    │   ├── data/
    │   │   ├── dto/attendance_dto.dart
    │   │   └── remote_attendance_repository.dart
    │   ├── domain/repositories/attendance_repository.dart
    │   └── presentation/
    │       ├── providers/attendance_providers.dart
    │       ├── screens/
    │       │   ├── attendance_screen.dart
    │       │   ├── attendance_detail_screen.dart
    │       │   └── check_in_out_screen.dart
    │       └── widgets/
    │           ├── attendance_calendar.dart
    │           └── attendance_record_card.dart
    ├── home/
    │   ├── data/
    │   │   └── remote_home_repository.dart
    │   ├── domain/repositories/home_repository.dart
    │   └── presentation/
    │       ├── providers/home_providers.dart
    │       ├── screens/home_screen.dart
    │       └── widgets/
    │           ├── checkin_hero_card.dart
    │           └── home_sections.dart
    ├── leave/
    │   ├── data/
    │   │   ├── dto/leave_dto.dart
    │   │   └── remote_leave_repository.dart
    │   ├── domain/repositories/leave_repository.dart
    │   └── presentation/
    │       ├── providers/leave_providers.dart
    │       ├── screens/
    │       │   ├── leave_requests_screen.dart
    │       │   ├── leave_detail_screen.dart
    │       │   └── new_leave_request_screen.dart
    │       └── widgets/leave_request_card.dart
    ├── notifications/
    │   ├── data/
    │   │   └── remote_notification_repository.dart
    │   ├── domain/repositories/notification_repository.dart
    │   └── presentation/
    │       ├── providers/notification_providers.dart
    │       └── screens/notifications_screen.dart
    ├── payments/
    │   ├── data/
    │   │   ├── dto/payment_dto.dart
    │   │   └── remote_payment_repository.dart
    │   ├── domain/repositories/payment_repository.dart
    │   └── presentation/
    │       ├── providers/payment_providers.dart
    │       ├── screens/
    │       │   ├── payments_screen.dart
    │       │   └── payment_detail_screen.dart
    │       └── widgets/payment_card.dart
    ├── profile/
    │   ├── data/
    │   │   └── remote_profile_repository.dart
    │   ├── domain/repositories/profile_repository.dart
    │   └── presentation/
    │       ├── providers/profile_providers.dart
    │       └── screens/
    │           ├── profile_screen.dart
    │           ├── more_screen.dart
    │           ├── settings_screen.dart
    │           ├── help_support_screen.dart
    │           └── legal_screen.dart
    └── statement/
        ├── data/
        │   └── remote_statement_repository.dart
        ├── domain/repositories/statement_repository.dart
        └── presentation/
            ├── providers/statement_providers.dart
            └── screens/statement_screen.dart
```

---

## 5. Getting Started

### Prerequisites

- **Flutter SDK**: 3.x (stable channel)
- **Dart SDK**: `>=3.0.0 <4.0.0`
- **IDE**: Android Studio / VS Code with Flutter plugin
- **Device**: Android emulator or physical device (GPS recommended)

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd workpulse

# 2. Install dependencies
flutter pub get

# 3. Verify setup
flutter doctor

# 4. Run in debug mode
flutter run

# 5. Build debug APK for testing
flutter build apk --debug
```

### First Login

Use the demo credentials (tap the info box on the login screen):

| Field | Value |
|-------|-------|
| **Username** | `rafid` |
| **Password** | `user123` |

---

## 6. Backend API Reference

### Base Configuration

| Item | Value |
|------|-------|
| **Base URL** | `https://202.83.126.123:5000` |
| **Environment** | Express.js (self-signed TLS) |
| **Auth** | Bearer JWT (15-min expiry) + Hex Refresh Token |
| **Client Header** | `x-client-type: android` |

### Global Headers

All authenticated requests include:
```http
Authorization: Bearer <accessToken>
Accept: application/json
x-client-type: android
```

Logout and Refresh additionally require:
```http
x-refresh-token: <refreshToken>
```

### Endpoint Map

| Method | Path | Feature | Status |
|--------|------|---------|--------|
| `POST` | `/api/auth/login` | Auth | ✅ Working |
| `POST` | `/api/auth/logout` | Auth | ✅ Working |
| `POST` | `/api/auth/refresh` | Auth | ✅ Working |
| `GET` | `/api/employees/me` | Profile | ✅ Working |
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
| `GET` | `/api/notifications` | Notifications | ✅ Working |
| `PATCH` | `/api/notifications/read` | Notifications | ✅ Working |

### Key Business Rules

- **Token Expiry:** Access tokens expire in 15 minutes. Auto-refresh is mandatory.
- **Geofencing:** Check-in/out requires GPS within 50 meters of `(23.7937, 90.4042)`.
- **Numeric Months:** Payroll uses integer months (`7` = July), not strings.
- **Single Leave Balance:** Backend tracks one combined balance, not separate Annual/Sick/Casual.
- **String Amounts:** Payroll `amount` and `baseSalary` are returned as strings, not numbers.

---

## 7. Core Infrastructure

### 7.1 ApiClient (`lib/core/network/api_client.dart`)

Wraps `dio` with:
- Base URL and timeout configuration
- `AuthInterceptor` for token management
- `LogInterceptor` for debug logging (🛰️ prefix)
- Self-signed certificate bypass (debug only)

```dart
// ⚠️ DEV ONLY — accepts any TLS cert so the app can reach the private-IP backend.
// The bypass only applies in debug builds; release builds enforce real certs.
void _allowSelfSignedCerts() {
  if (!kDebugMode) return;
  // ...
}
```

### 7.2 AuthInterceptor (`lib/core/network/auth_interceptor.dart`)

**Request Phase:**
- Attaches `x-client-type: android` to every request
- Skips `Authorization` header for `/login` and `/refresh`
- Attaches `x-refresh-token` for all non-login requests

**Error Phase (401 handling):**
- Detects token-related 401 errors
- Sets `_isRefreshing = true`
- Calls `/api/auth/refresh` with the stored refresh token
- Queues concurrent requests via `_refreshSubscribers`
- **On success:** retries all queued requests with the new token
- **On failure:** clears storage → forces re-login

### 7.3 TokenStorage (`lib/core/network/token_storage.dart`)

| Key | Purpose |
|-----|---------|
| `auth.token` | JWT Access Token |
| `auth.refresh` | Hex Refresh Token |
| `auth.userId` | Logged-in user's ID |

### 7.4 LocationService (`lib/core/network/location_service.dart`)

```dart
static bool forceOfficeLocation = false; // Toggle in Settings → Preferences
```

**Logic:**
1. If `forceOfficeLocation == true` → return office coords
2. Check if location services are enabled
3. Request/check permissions
4. Get current GPS position (8-second timeout)
5. If user is within 100m of office → use real location
6. Otherwise → fallback to office coords (for dev testing)

---

## 8. Feature Modules

### 8.1 Authentication
**Flow:**
1. User enters username + password
2. `POST /api/auth/login` → returns `accessToken`, `refreshToken`, `userId`
3. Store tokens in secure storage
4. `GET /api/employees/?id=` → fetch full profile
5. Store `Employee` in `AuthController` state
6. Router redirects to `/home`

**Files:**
- `features/auth/data/remote_auth_repository.dart`
- `features/auth/presentation/providers/auth_providers.dart`
- `features/auth/presentation/screens/login_screen.dart`

### 8.2 Attendance
**Capabilities:**
- Monthly calendar with color-coded statuses
- Summary grid (Working Days, Present, Late, Absent)
- Per-day detail with check-in/out times, overtime, late minutes
- Check-in/out with GPS validation

**Providers:**
- `attendanceMonthProvider(month)` → `FutureProvider.family`
- `attendanceRecordProvider(id)` → `FutureProvider.family`
- `todayAttendanceProvider` → `StateNotifierProvider` (with `checkIn()` / `checkOut()` actions)

### 8.3 Leave Management
**Capabilities:**
- List all leave requests with status filters (All / Pending / Approved / Rejected)
- Submit new leave request with date range picker and business-day calculator
- View leave balance (remaining days)
- Detail screen with reviewer comments

> **Important:** Backend currently returns 500 on `POST /api/leave-requests/`. The app creates a local "Pending" request as fallback.

### 8.4 Payments
**Capabilities:**
- Latest payment hero card (dark navy theme)
- Payment history list
- Detail screen with gross/net breakdown, deductions, allowances

> **Note:** Backend returns amounts as strings (e.g., `"60000"`). DTOs handle parsing.

### 8.5 Statement
**Capabilities:**
- Monthly composed view: Attendance Summary + Work Summary + Leave Summary + Payment Summary
- Month selector with min/max bounds (joining date → now)

**Implementation:** Uses `Future.wait` to aggregate data from Attendance, Leave, and Payment repositories since the dedicated statement endpoint is broken.

### 8.6 Notifications
**Capabilities:**
- Filter by type (Attendance / Leave / Payment / System)
- Mark individual or all as read
- Unread badge count in app bar and More screen

### 8.7 Profile / Settings
**Capabilities:**
- View employee profile (read-only, managed by HR)
- Settings: Force Office Location toggle, Language, Change Password (redirects to HR)
- Help & Support: FAQ accordion, contact info
- Legal: Privacy Policy, Terms & Conditions
- Developer Tools (debug only)

---

## 9. State Management Patterns

### Provider Types Used

| Pattern | Use Case | Example |
|---------|----------|---------|
| `Provider` | Singleton services | `apiClientProvider`, `locationServiceProvider` |
| `FutureProvider.autoDispose` | One-shot fetches | `profileProvider`, `paymentsProvider` |
| `FutureProvider.family` | Parameterized fetches | `attendanceMonthProvider(month)` |
| `StateNotifierProvider` | Mutable state + actions | `authControllerProvider`, `todayAttendanceProvider` |
| `StreamProvider` | Live updates | `clockProvider` (emits every 30s) |
| `StateProvider` | Simple mutable flags | `notificationsEnabledProvider` |

### Data Flow Example (Attendance)

```text
AttendanceScreen
  └── ref.watch(attendanceMonthProvider(_month))
        └── AttendanceRepository.getMonthAttendance(month)
              └── RemoteAttendanceRepository
                    └── _client.dio.get(ApiEndpoints.attendanceReport, ...)
                          └── extractList(res.data)
                                └── AttendanceReportItemDto.fromJson(...)
                                      └── AttendanceRecord (domain model)
```

---

## 10. Networking Layer

### Request Lifecycle

```text
┌──────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Repository  │────▶│   AuthInterceptor │────▶│   Dio       │
│  (feature)   │     │  (attach token)   │     │  (HTTP)     │
└──────────────┘     └──────────────────┘     └──────┬──────┘
                                                      │
                                                      ▼
                                              ┌─────────────┐
                                              │   Backend   │
                                              └──────┬──────┘
                                                      │
                     ┌──────────────────┐             │
                     │  AuthInterceptor │◀────────────┘
                     │  (handle 401)    │
                     └────────┬─────────┘
                              │
                    ┌─────────▼─────────┐
                    │  Refresh Token    │
                    │  → Retry Request  │
                    └───────────────────┘
```

### Response Normalization

All list responses go through `extractList()`:

```dart
List<dynamic> extractList(dynamic body) {
  if (body is List) return body;                          // Raw array
  if (body is Map && body['data'] is List) return body['data'];     // {"data": [...]}
  if (body is Map && body['results'] is List) return body['results']; // {"results": [...]}
  return const [];
}
```

---

## 11. Authentication Flow

```text
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
                                          │ → /home        │
                                          └────────────────┘
```

### Token Refresh Flow

```text
API Request → 401 "token expired"
    │
    ▼
AuthInterceptor.onError()
    │
    ├── Is it /login or /refresh? → NO (skip)
    │
    ├── Is _isRefreshing? → YES (queue request)
    │
    └── NO → Set _isRefreshing = true
              │
              ▼
         POST /api/auth/refresh
              │
              ├── Success → Update storage
              │              Notify all queued requests
              │              Retry original request
              │
              └── Failure → Clear storage
                             Force logout
```

---

## 12. Geofencing & Location

### Office Configuration

```dart
// lib/core/network/api_config.dart
static const double officeLatitude = 23.7937;
static const double officeLongitude = 90.4042;
static const double officeRadiusMeters = 50.0;
```

### Check-In Flow

```text
User taps "Check In"
    │
    ▼
LocationService.getCheckInLocation()
    │
    ├── forceOfficeLocation == true? → Return office coords
    │
    ├── Location disabled? → Return office coords
    │
    ├── Permission denied? → Return office coords
    │
    └── Get GPS position (8s timeout)
         │
         ├── Distance ≤ 100m → Return real coords
         │
         └── Distance > 100m → Return office coords (dev fallback)
    │
    ▼
POST /api/attendance/check-in
  body: { "latitude": "23.7937", "longitude": "90.4042" }
    │
    ├── 201 → Success
    └── 400 "not within office" → Show error snackbar
```

### Backend Enforcement

The backend strictly validates that coordinates are within 50m. If not:

```json
{ "error": "You are not within the office location range" }
```

---

## 13. Error Handling Strategy

### Failure Hierarchy

```text
AppFailure (base)
├── AuthFailure        → Invalid credentials, expired session
├── NotFoundFailure    → Record not found
└── OfflineFailure     → No network connectivity
```

### UI Error States

| Widget | Purpose |
|--------|---------|
| `ErrorStateWidget` | Full-page error with retry button |
| `EmptyStateWidget` | No data available (icon + message + CTA) |
| `OfflineBanner` | Top banner when device is offline |
| `AppSnack.error()` | Transient error toast |

### Repository Error Pattern

```dart
try {
  final res = await _client.dio.get(endpoint);
  // parse and return
} on DioException catch (e) {
  final errorBody = e.response?.data;
  if (errorBody is Map && errorBody['error'] != null) {
    throw AppFailure(errorBody['error'].toString());
  }
  throw const AppFailure('Something went wrong.');
}
```

---

## 14. UI / Design System

### Color Palette

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `primary` | `#155EEF` | — | Buttons, links, accents |
| `canvas` | `#F5F7FB` | `#0D1420` | Scaffold background |
| `surface` | `#FFFFFF` | `#151D2C` | Cards, sheets |
| `border` | `#E7EBF3` | `#26334A` | Dividers, outlines |
| `textPrimary` | `#101828` | — | Headings |
| `textSecondary`| `#667085` | — | Body, labels |
| `success` | `#12B76A` | — | Present, Approved, Paid |
| `warning` | `#F79009` | — | Late, Pending |
| `danger` | `#D92D20` | — | Absent, Rejected, Failed |

### Typography

| Style | Font | Size | Weight |
|-------|------|------|--------|
| Display | Sora | 30px | 700 |
| Headline | Sora | 20px | 600 |
| Title | IBM Plex | 17px | 600 |
| Body | IBM Plex | 14px | 400 |
| Label | IBM Plex | 12px | 500 |

### Spacing System

Based on 8px grid:
- `AppRadius.sm` = 10px
- `AppRadius.md` = 14px
- `AppRadius.lg` = 18px
- `AppRadius.xl` = 22px

### Shared Widget Library

| Widget | File | Purpose |
|--------|------|---------|
| `AppCard` | `cards.dart` | Base card with hover effect |
| `StatCard` | `cards.dart` | Dashboard metric tile |
| `QuickActionCard` | `cards.dart` | Icon + label action tile |
| `InfoRow` | `cards.dart` | Label-value detail row |
| `StatusChip` | `chips.dart` | Colored status badge |
| `AppScaffold` | `misc.dart` | Page wrapper with app bar |
| `UserAvatar` | `misc.dart` | Initials-based avatar |
| `MonthSelector` | `misc.dart` | Month navigation arrows |
| `ActivityTimeline`| `misc.dart` | Vertical event timeline |
| `PrimaryButton` | `buttons.dart` | Full-width elevated button |
| `ConfirmationBottomSheet`| `sheets.dart` | Confirm/cancel modal |
| `AppSnack` | `sheets.dart` | Success/error/info snackbar |
| `Shimmer` | `states.dart` | Loading shimmer effect |
| `LoadingSkeleton` | `states.dart` | Placeholder card skeleton |
| `EmptyStateWidget`| `states.dart` | No data state |
| `ErrorStateWidget`| `states.dart` | Error + retry state |

---

## 15. Known Backend Bugs & Frontend Workarounds

### 🐛 Bug #1: Leave Submission Returns 500

| Item | Detail |
|------|--------|
| **Endpoint** | `POST /api/leave-requests/` |
| **Expected** | 201 Created with leave request object |
| **Actual** | 500 Internal Server Error |
| **Frontend Fix** | Catches 500, creates local "Pending" request with generated ID |
| **File** | `features/leave/data/remote_leave_repository.dart` |
| **Cleanup** | Remove `if (e.response?.statusCode == 500)` block when fixed |

### 🐛 Bug #2: Attendance Report Returns 500

| Item | Detail |
|------|--------|
| **Endpoint** | `GET /api/attendance/report` |
| **Expected** | Array of attendance records for date range |
| **Actual** | 500 Internal Server Error |
| **Frontend Fix** | Shows error state with retry button |
| **File** | `features/attendance/data/remote_attendance_repository.dart` |

### 🐛 Bug #3: Statement Endpoint Returns 500

| Item | Detail |
|------|--------|
| **Endpoint** | `GET /api/attendance/statement` |
| **Expected** | Monthly statement object |
| **Actual** | 500 Internal Server Error |
| **Frontend Fix** | Composes statement from Attendance + Leave + Payment APIs via `Future.wait` |
| **File** | `features/statement/data/remote_statement_repository.dart` |
| **Cleanup** | Replace `Future.wait` with single API call when endpoint is fixed |

### ⚠️ Quirk #1: Single Leave Balance
Backend returns one combined balance instead of separate Annual/Sick/Casual buckets.
- **Current mapping:** Single balance → `LeaveType.annual`
- **Future fix:** Update `getBalances()` when backend adds separate types

### ⚠️ Quirk #2: String Amounts in Payroll
Backend returns `"amount": "60000"` (string) instead of `"amount": 60000` (number).
- **DTO handles:** `double.parse()` or `double.tryParse()` conversion

### ⚠️ Quirk #3: Numeric Months
Payroll uses integer months (`7` for July), not strings (`"July"`).
- **DTO handles:** `DateTime(d.year, d.month)` construction

---

## 16. Developer Tools (Debug)

Located in **Settings → 🛠 Developer Tools (Debug)** section.

| Tool | Action | Purpose |
|------|--------|---------|
| **Force Office Location** | Toggle | Bypass GPS, always use office coords |
| **View Stored Tokens** | Dialog | Inspect access/refresh tokens in secure storage |
| **Force Token Refresh** | API call | Manually trigger `/api/auth/refresh` |
| **Expire Token Now** | Write fake JWT | Test auto-refresh on next API call |

> ⚠️ **Remove this entire section before production release.**

---

## 17. How to Add a New Feature

### Step-by-Step Guide

1. **Add API path** → `lib/core/constants/api_endpoints.dart`
   ```dart
   static const String myFeature = '/api/my-feature';
   ```

2. **Create domain model** → `lib/core/models/my_feature.dart`

3. **Create feature folder** → `lib/features/my_feature/`

4. **Create DTO** → `lib/features/my_feature/data/dto/my_feature_dto.dart`
   ```dart
   class MyFeatureDto {
     final String id;
     final String name;
     MyFeatureDto.fromJson(Map<String, dynamic> j) : id = j['id'], name = j['name'];
   }
   ```

5. **Create abstract repository** → `lib/features/my_feature/domain/repositories/my_feature_repository.dart`

6. **Create remote repository** → `lib/features/my_feature/data/remote_my_feature_repository.dart`

7. **Create providers** → `lib/features/my_feature/presentation/providers/my_feature_providers.dart`

8. **Create screens** → `lib/features/my_feature/presentation/screens/`

9. **Register route** → `lib/app/router/app_router.dart`

10. **Add navigation** → Update `ShellScreen` or relevant navigation widget

---

## 18. Configuration Reference

### All Configurable Values

| File | Constant | Current Value | Purpose |
|------|----------|---------------|---------|
| `api_config.dart` | `baseUrl` | `https://202.83.126.123:5000` | Backend URL |
| `api_config.dart` | `officeLatitude` | `23.7937` | Geofence center |
| `api_config.dart` | `officeLongitude` | `90.4042` | Geofence center |
| `api_config.dart` | `officeRadiusMeters`| `50.0` | Geofence radius |
| `api_config.dart` | `clientTypeValue` | `android` | Client header |
| `app_constants.dart`| `appName` | `WorkPulse` | Display name |
| `app_constants.dart`| `companyName` | `SoftZen IT` | Company |
| `app_constants.dart`| `version` | `v1.0.0` | App version |
| `app_constants.dart`| `supportEmail` | `peopleops@softzentech.co.uk`| Support |
| `app_constants.dart`| `defaultWorkStartMinutes`| `540` (09:00) | Shift start |
| `app_constants.dart`| `defaultGraceMinutes` | `15` | Late threshold |
| `app_constants.dart`| `defaultShiftMinutes` | `540` (9h) | Shift duration |

### Environment Switching

To point at a different backend:

```dart
// lib/core/network/api_config.dart
static const String baseUrl = 'https://your-production-domain.com';
```

---

## 19. Production Handover Checklist

Before releasing to production:

### Backend
- [ ] Fix `POST /api/leave-requests/` (500 error)
- [ ] Fix `GET /api/attendance/report` (500 error)
- [ ] Fix `GET /api/attendance/statement` (500 error)
- [ ] Deploy valid SSL certificate (not self-signed)
- [ ] Confirm production base URL

### Frontend Code Changes
- [ ] Update `ApiConfig.baseUrl` to production URL
- [ ] Remove `LocationService` >100m dev fallback (enforce strict GPS)
- [ ] Remove Leave 500 fallback in `remote_leave_repository.dart`
- [ ] Replace Statement `Future.wait` with single API call
- [ ] Remove "Developer Tools" section from `SettingsScreen`
- [ ] Remove demo credentials box from `LoginScreen`
- [ ] Update `AppConstants.version` to release version
- [ ] Replace placeholder 'W' logo with actual app icon

### Release
- [ ] Generate signed Android keystore
- [ ] Build release APK/AAB: `flutter build appbundle --release`
- [ ] Test on physical device with real GPS
- [ ] Verify SSL certificate chain works in release mode
- [ ] Test token refresh flow end-to-end
- [ ] Test geofence enforcement at office location

### Post-Launch
- [ ] Monitor crash reports
- [ ] Verify notification delivery
- [ ] Confirm payroll data accuracy with HR team

---

