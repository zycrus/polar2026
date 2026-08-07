# INSTAROSA: Santa Rosa Community Services App — Documentation

A Flutter mobile app that gives residents of Santa Rosa, Laguna a single place
to report emergencies and community concerns, find healthcare and government
services, and manage their profile — with real-time data backed by Firebase.

> Tagline shown in-app: *"Sa Santa Rosa, Instant Ang Serbisyo Sa Masa."*

---

## 1. Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Backend | Firebase (Firestore, Firebase Auth) |
| Auth method | Phone number + OTP (SMS) via `firebase_auth` |
| Maps / location | `flutter_map`, `latlong2`, `geolocator` |
| Other packages | `flutter_svg`, `slide_to_act`, `url_launcher`, `cloud_firestore` |

## 2. Project structure

```
lib/
├── main.dart                  # App entry point, bottom-nav shell (MainScreen)
├── firebase_options.dart      # Auto-generated Firebase config (FlutterFire CLI)
├── services/
│   └── firestore.dart         # FirestoreService — user profile read/write helpers
├── pages/
│   ├── emergency.dart         # Home tab 1 — Emergency
│   ├── community.dart         # Home tab 2 — Community
│   ├── profile.dart           # Home tab 3 — Profile (center/default tab)
│   ├── healthcare.dart        # Home tab 4 — Healthcare
│   ├── services.dart          # Home tab 5 — Services
│   ├── distress_report.dart   # Emergency report submission form
│   ├── concern_report.dart    # Community concern report submission form
│   ├── make_appointment.dart  # Healthcare checkup appointment booking flow
│   ├── edit_profile.dart      # Edit personal/emergency-contact info
│   ├── signin.dart            # Phone number sign-in (sends OTP)
│   ├── signup.dart            # New account registration form
│   └── otp.dart                # 6-digit OTP verification screen
├── widgets/
│   ├── navbar.dart             # CustomBottomNavBar — 5-tab bottom navigation
│   ├── notification.dart       # NotificationsDialog — recent reports popup
│   ├── hotlines.dart           # EmergencyHotlinesDialog — hotline directory
│   ├── card.dart                # CustomCard — generic tappable list card
│   └── report_card.dart         # ReportCard — expandable report status card
└── _unused_legacy/             # Earlier/duplicate page versions, kept for reference
    # not imported anywhere; safe to delete once confirmed unneeded
```

`_unused_legacy/` holds older duplicate versions of Emergency, Community,
Healthcare, and Profile (and a couple of widgets only they used) that predate
the current design and are no longer wired into the app. See
`CLEANUP_NOTES.md` for details.

## 3. App shell & navigation

`main.dart` defines:

- **`MyApp`** — root `MaterialApp`.
- **`MainScreen`** — a `StatefulWidget` that owns the currently selected tab
  (`_selectedIndex`, defaulting to **2 = Profile**) and renders:
  - A header with the app logo/tagline and a notification bell
    (opens `NotificationsDialog`).
  - The active page for the selected tab.
  - A `CustomBottomNavBar` with 5 icons: Emergency, Community, Profile,
    Healthcare, Services.
  - A background gradient that changes color per tab.

Tab order and matching pages:

| Index | Tab | Page |
|---|---|---|
| 0 | Emergency | `EmergencyPage` |
| 1 | Community | `CommunityPage` |
| 2 | Profile | `ProfilePage` |
| 3 | Healthcare | `HealthcarePage` |
| 4 | Services | `ServicesPage` |

## 4. Authentication flow

Phone-number based sign-in using Firebase Auth's SMS OTP flow.

1. **`SignInPage`** — user enters a phone number → app sends a verification
   code via `FirebaseAuth.verifyPhoneNumber`.
2. If the number is not yet registered, the user is routed to
   **`SignUpPage`** to provide: full name, phone number, street address,
   barangay, emergency contact name, and emergency contact number.
3. **`OtpPage`** — user enters the 6-digit SMS code to confirm their identity.
   On success:
   - The Firebase Auth display name is set.
   - The full profile is saved to Firestore via `FirestoreService.saveUserData`.
   - The user is returned to the app's home screen.
4. A resend-code countdown (60s) is used on both the sign-in and OTP screens
   to throttle repeat SMS requests.

## 5. Feature walkthrough

### Emergency tab (`emergency.dart`)
- "Slide to call" button for immediate emergency contact.
- 2×2 grid of response teams (police, fire, medical, disaster response, etc.).
- "Need Immediate Help" hotline shortcut.
- Live-updating list of the current user's recent emergency reports, pulled
  from Firestore and sorted by most recent.
- Tapping "Report" opens **`DistressReportPage`**.

### Community tab (`community.dart`)
- "File a Concern" button opens **`ConcernReportPage`**.
- 2×2 grid of concern categories (e.g. sanitation, noise, safety).
- Live-updating list of the current user's community report history.

### Report forms (`distress_report.dart`, `concern_report.dart`)
Both forms collect: category, barangay, and location — captured one of three
ways (`LocationMode`):
- **GPS** — current device position via `geolocator`.
- **PIN** — manually dropped pin on a `flutter_map` map.
- **LANDMARK** — free-text description of a nearby landmark.

Plus a free-text description of the issue (`natureOfDistress` /
`natureOfConcern`). On submit, a document is written to the Firestore
`reports` collection (see [Data model](#6-data-model) below), and a
confirmation snackbar is shown before the user is returned to the previous
screen.

### Healthcare tab (`healthcare.dart`)
- **Medical Services**: e-Konsulta (external telehealth link), Barangay
  Health Center and Santa Rosa City Hospital — both open
  **`CheckupAppointmentPage`** to book a checkup.
- **Mental Health**: link out to an external mental-health support platform.

### Appointment booking (`make_appointment.dart`)
A 3-step stepper flow for booking a checkup at a chosen facility:
1. **Schedule** — pick a date and time slot.
2. **Details** — enter visit details/reason.
3. **Confirm** — review and submit the booking.

### Services tab (`services.dart`)
A categorized directory of city services, grouped under section headers:
- **Education & Training** — e-TESDA Portal, CEAP Scholarship, TESDA Laguna
  Centers, Santa Rosa TESDA Courses (all open external links).
- **Legal Assistance** — City Legal Office.
- **Permits & Regulation** — Business Permits & Licensing, Building &
  Construction Permits, Sanitation & Health Permits.

Entries without a live backend/URL yet show a "Coming soon" snackbar instead
of navigating anywhere.

### Profile tab (`profile.dart`)
- Header card with the signed-in user's name and saved address.
- Quick-access shortcuts.
- Personal information: saved address, emergency contact.
- Recent activity: the user's 3 most recent reports (from the `reports`
  collection), rendered with `ReportCard`.
- Edit Profile → opens **`EditProfilePage`** to update name, address,
  barangay, and emergency contact, saved via `FirestoreService.updateUserProfile`.
- Sign out.

### Report cards (`widgets/report_card.dart`)
An expandable card used on the Emergency, Community, and Profile tabs to show
a report's status. When expanded, it reveals barangay, location summary,
description, and submission date, plus contextual actions:
- **Withdraw Report** — available while status is pending/in progress.
- **Close Report** — available once status is `resolved`.

### Notifications (`widgets/notification.dart`)
A popup dialog (opened from the bell icon in the app header) listing the
user's recent reports across both emergency and community categories,
sorted by most recent.

### Emergency hotlines (`widgets/hotlines.dart`)
A popup dialog listing local emergency hotline numbers for quick reference/calling.