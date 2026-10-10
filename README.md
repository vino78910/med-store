# VitalMed

> **"Right Medicine, Right Time, Every Life."**

VitalMed is a modern, responsive mobile application built with **Flutter**, **Dart**, and **Firebase** that prevents medicine shortages, predicts stockouts before they happen, connects nearby pharmacies for compliant redistribution, and helps patients discover medicine availability at nearby certified pharmacies.

---

## 🌟 The Three Core Functions

1. **Automatic Medicine Stock Monitoring & Early Alerts**
   - Continuous real-time inventory tracking with Firebase Firestore listeners.
   - Deterministic inventory forecasting:
     $$\text{Estimated Days Remaining} = \frac{\text{Current Available Stock}}{\text{Average Daily Consumption}}$$
   - Safe zero-consumption handling & multi-tier AI demand velocity regression.
   - Configurable alert thresholds (`WARNING <= 3 days`, `CRITICAL <= 1 day`, `OUT OF STOCK = 0`).
   - Duplicate alert suppression and automated alert resolution upon restock.

2. **Pharmacy-to-Pharmacy Medicine Redistribution**
   - High-accuracy Haversine distance matching within configurable radii (default 5 km).
   - Safe surplus calculation:
     $$\text{Surplus Stock} = \text{Current Stock} - (\text{Minimum Reserve Threshold} + \text{2-Day Demand Buffer})$$
   - **Shortage Invariant**: Never recommends or allows transfers that would cause a shortage at the supplying pharmacy.
   - Full 7-stage transfer lifecycle (`PENDING` $\rightarrow$ `ACCEPTED` $\rightarrow$ `APPROVED` $\rightarrow$ `IN TRANSIT` $\rightarrow$ `COMPLETED`).
   - Regulatory compliance verification (batch number, expiry date, storage conditions).
   - Atomic dual-inventory transaction updating both parties and writing immutable audit logs.

3. **Patient-to-Nearby-Pharmacy Medicine Availability Search & Alerts**
   - "Find Medicine Nearby" search by brand or generic name, dosage form, and radius.
   - **Privacy Shield**: Never discloses private wholesale units or commercial inventory numbers to the public; exposes verified status categories:
     - `AVAILABLE`: In stock according to latest reported inventory.
     - `LOW STOCK`: Limited quantity remaining. Call to confirm before travel.
     - `UNAVAILABLE`: Currently reported out of stock.
     - `AVAILABILITY UNCONFIRMED`: Reported inventory is older than 48 hours.
   - Turn-by-turn directions & 1-tap phone dialing.
   - Restock alert subscriptions: patients receive automated push notifications the moment a scarce medicine is restocked nearby.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Mobile Frontend** | Flutter (Material Design 3) |
| **Language** | Dart 3.x |
| **Database** | Firebase Firestore (Real-Time Streams & Atomic Transactions) |
| **Authentication** | Firebase Authentication (Role-Based Access Control) |
| **Push Notifications** | Firebase Cloud Messaging (FCM Multicast) |
| **Secure Backend** | Firebase Cloud Functions (Node.js runtime in `functions/`) |
| **Location Services** | Geolocator & Haversine Great-Circle Algorithms |

---

## 👥 User Roles & Permissions

1. **Pharmacy Admin**
   - Full control over pharmacy profile, operating hours, license details, and GPS coordinates.
   - Configures alert thresholds (warning days and critical days).
   - Approves redistribution transfers after regulatory compliance checks.
   - Full access to inventory, movements, and metrics.
2. **Pharmacist**
   - Adds medicines, records restocks, and records dispenses (with non-negative stock validation).
   - Responds to incoming redistribution requests (Accept/Reject).
   - Dispatches outgoing transfers and confirms incoming deliveries.
3. **Patient**
   - Searches for medicines without needing to log into or access commercial pharmacy data.
   - Views distance, operating hours, and availability categories.
   - Subscribes to out-of-stock medicine availability alerts.

---

## 📂 Project Directory Structure

```text
Med store/
├── lib/
│   ├── main.dart                                # Application entry point & role routing
│   ├── theme/
│   │   └── app_theme.dart                       # VitalMed healthcare theme & palette
│   ├── models/
│   │   ├── user_model.dart                      # User & Role models
│   │   ├── pharmacy_model.dart                  # Registered Pharmacy model
│   │   ├── medicine_model.dart                  # Master Medicine Catalog model
│   │   ├── inventory_item_model.dart            # Inventory Item & Surplus calculation
│   │   ├── stock_movement_model.dart            # Immutable audit log
│   │   ├── stock_alert_model.dart               # Stockout alerts & risk levels
│   │   ├── redistribution_request_model.dart    # P2P requests & urgency
│   │   ├── redistribution_transfer_model.dart   # 7-stage compliance transfer
│   │   ├── patient_subscription_model.dart      # Patient restock subscriptions
│   │   └── notification_model.dart              # 6 notification categories
│   ├── services/
│   │   ├── auth_service.dart                    # Firebase Auth & role manager
│   │   ├── firestore_service.dart               # Firestore listeners & queries
│   │   ├── stock_monitor_service.dart           # Deterministic & AI demand engine
│   │   ├── redistribution_service.dart          # Surplus ranking & atomic transfers
│   │   ├── patient_service.dart                 # Patient search & privacy shield
│   │   ├── location_service.dart                # Haversine distance calculations
│   │   ├── fcm_service.dart                     # Cloud messaging push handler
│   │   └── sample_data_service.dart             # Preloaded hackathon scenario data
│   ├── providers/
│   │   └── app_state.dart                       # Centralized reactive ChangeNotifier
│   ├── widgets/
│   │   ├── stock_status_badge.dart              # Status pill badge (NORMAL, WARNING, etc.)
│   │   ├── metric_card.dart                     # Dashboard KPI metric cards
│   │   ├── medicine_card.dart                   # Medicine item with quick actions
│   │   ├── alert_card.dart                      # Early alert notification card
│   │   ├── transfer_card.dart                   # Transfer card with compliance actions
│   │   └── custom_app_bar.dart                  # App bar with 1-click role switcher
│   └── screens/
│       ├── splash_screen.dart                   # Animated splash screen
│       ├── auth/
│       │   ├── login_screen.dart                # Login with 1-tap demo credentials
│       │   └── register_screen.dart             # Register screen for all 3 roles
│       ├── pharmacy/
│       │   ├── pharmacy_main_nav.dart           # Pharmacy bottom navigation & drawer
│       │   ├── dashboard_screen.dart            # Dashboard metrics & live alerts
│       │   ├── inventory_screen.dart            # Inventory catalog, restock, dispense
│       │   ├── add_edit_medicine_screen.dart    # Add new medicine form
│       │   ├── stockout_predictions_screen.dart # Thresholds & AI velocity trends
│       │   ├── nearby_pharmacies_screen.dart    # Surplus candidate discovery & requests
│       │   ├── requests_screen.dart             # Incoming & outgoing requests
│       │   ├── transfer_history_screen.dart     # Transfer lifecycle & compliance check
│       │   ├── stock_movement_screen.dart       # Immutable audit logs
│       │   └── pharmacy_profile_screen.dart     # Pharmacy details & demo reset
│       ├── patient/
│       │   ├── patient_main_nav.dart            # Patient bottom navigation
│       │   ├── patient_home_screen.dart         # Patient home & quick search
│       │   ├── find_medicine_screen.dart        # Find Medicine Nearby with filters
│       │   ├── availability_alerts_screen.dart  # Active restock alert subscriptions
│       │   └── patient_profile_screen.dart      # Patient profile & privacy settings
│       └── common/
│           └── notification_center_screen.dart  # 6-category notification center
├── test/
│   ├── stockout_prediction_test.dart            # Forecast formulas & zero-burn tests
│   ├── redistribution_matching_test.dart        # Surplus matching & shortage invariant tests
│   ├── inventory_atomic_transfer_test.dart      # Dual-inventory sync & invariant tests
│   └── patient_search_test.dart                 # Patient search & privacy shield tests
├── firestore.rules                              # Role-based Firestore security rules
├── firestore.indexes.json                       # Composite query indexes
├── firebase.json                                # Firebase hosting & functions configuration
├── functions/
│   ├── package.json                             # Functions dependencies
│   ├── index.js                                 # Secure server functions (FCM, atomic transfers)
│   └── README.md                                # Backend deployment instructions
└── pubspec.yaml                                 # Flutter project dependencies
```

---

## ⚡ Hackathon 24-Hour Demonstration Scenario

All demo records are clearly tagged with `[SAMPLE DATA]`.

1. **Initial Shortage at Pharmacy A (Apex Care Pharmacy)**
   - Holds only **10 bottles** of *Paracetamol Pediatric Syrup*.
   - Average daily burn is **5.0 bottles/day**.
   - Formula yields:
     $$\frac{10}{5} = 2.0 \text{ days remaining} \le 3.0 \text{ days (WARNING threshold)}$$
   - Dashboard instantly displays a `WARNING` status alert and adds it to the Notification Centre.
2. **Surplus Matching at Nearby Pharmacies**
   - Pharmacy A navigates to **Find Surplus Pharmacies**.
   - **Pharmacy B (Metro Cure Pharmacy, 1.5 km away)**: Holds 120 bottles with 20 minimum reserve. Calculated surplus = **92 bottles** $\rightarrow$ **ELIGIBLE**.
   - **Pharmacy C (GreenCross Chemist, 2.8 km away)**: Holds 15 bottles with 20 minimum reserve. Calculated surplus = **0 bottles** $\rightarrow$ **INELIGIBLE** (system blocks requests that would cause a shortage at Pharmacy C).
3. **Redistribution Request & Acceptance**
   - Pharmacy A dispatches a request for **20 bottles** to Pharmacy B.
   - Using the **1-Click Role Switcher** at the top of the app, switch to **Pharmacist (Metro Cure Pharmacy)**.
   - The request appears under **Incoming Requests**. Tap **Accept & Transfer**.
4. **Compliance Check & Courier Dispatch**
   - Under **Transfers**, tap **Verify Compliance & Approve Transfer**.
   - Checks batch number (`PARA-2024-B9`), room temperature storage packaging, and active licenses.
   - Tap **Dispatch (Mark In Transit)**.
5. **Atomic Dual-Inventory Sync**
   - Switch back to Pharmacy A and tap **Confirm Receipt**.
   - Both inventories update atomically:
     - Pharmacy B stock decreases by 20 (from 120 to 100).
     - Pharmacy A stock increases by 20 (from 10 to 30).
     - Pharmacy A days remaining recalculates from 2.0 days to **6.0 days** ($\rightarrow$ returns to `NORMAL`!).
     - Stock alert resolves automatically.
6. **Patient Search Verification**
   - Switch role to **Patient (Jane Doe)**.
   - Open **Find Medicine Nearby** and search *Paracetamol Syrup*.
   - Both Pharmacy A and Pharmacy B now report **AVAILABLE**!

---

## 🚀 How to Run the Application

### 1. Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version $\ge$ 3.0.0)
- Any supported target (Chrome, Windows desktop, Android emulator, or iOS simulator).

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Unit & Integration Tests
```bash
flutter test
```
All four test suites will execute and validate:
- Stockout prediction formulas and safe zero-consumption handling.
- Nearby pharmacy distance calculation and surplus safety invariants.
- Atomic dual-inventory redistribution updates.
- Patient search filtering and privacy preservation.

### 4. Run the Mobile App
```bash
# Run in Chrome for instant interactive web execution
flutter run -d chrome

# Or run as a native Windows desktop app
flutter run -d windows
```

---

## 🔒 Firebase Backend Setup & Security Rules

### Deploy Security Rules & Indexes
```bash
firebase login
firebase use --add <your-firebase-project-id>
firebase deploy --only firestore:rules,firestore:indexes
```

### Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

---

## 📝 License
This project is developed for the VitalMed initiative. Sample data is fictional and designated for testing and demonstration purposes.
