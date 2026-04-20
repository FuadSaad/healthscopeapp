<div align="center">

# 🏥 HealthScope BD

### AI-Powered Epidemic Tracker & Health Companion

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)]()

*A comprehensive mobile health platform that empowers Bangladeshi citizens with real-time epidemic intelligence, AI-driven symptom analysis, and instant access to emergency healthcare resources.*

---

</div>

## ✨ Features at a Glance

| Feature | Description |
|---------|-------------|
| 🤖 **AI Symptom Checker** | Weighted ML algorithm predicting 13 diseases from 30+ symptoms with confidence scores |
| 🗺️ **Epidemic Heatmap** | Interactive OpenStreetMap with real-time disease hotspot visualization |
| 📊 **Statistics Dashboard** | Custom-built charts displaying live outbreak analytics from Firebase |
| 📝 **Disease Reporting** | Structured report submission with division/district-level geographic tagging |
| 📋 **Report History** | Personal timeline of all submitted disease reports |
| 🏥 **Nearby Hospitals** | Division-filtered hospital directory with one-tap call & directions |
| 🆘 **Emergency Contacts** | National emergency numbers with direct-call integration |
| 💡 **Health Insights** | Actionable health tips with detailed prevention guides |
| 🌗 **Dark/Light Mode** | Premium dual-theme with 40+ semantic color tokens |
| 🔐 **Secure Auth** | Firebase Authentication with email/password & session persistence |

---

## 🎨 Design Philosophy

HealthScope BD follows a **Premium Glassmorphism** aesthetic with:

- 🌑 **Dark Mode** — Deep slate (`#0F172A`) with vibrant emerald/purple accents  
- ☀️ **Light Mode** — Soft mint (`#F0FDF4`) with subtle glass effects  
- ✨ **Micro-animations** — Pulse, slide, and fade transitions  
- 🔤 **Typography** — Google Fonts "Outfit" for modern readability  

---

## 🏗️ Architecture

```
lib/
├── main.dart                          # App entry, AuthGate, MainNavigator
├── screens/
│   ├── login_screen.dart              # Firebase Auth (Login/Signup)
│   ├── home_screen.dart               # Dashboard, Stats, Insights, Quick Actions
│   ├── symptom_checker_screen.dart    # AI Symptom Selection & Prediction
│   ├── trends_screen.dart             # OpenStreetMap Epidemic Heatmap
│   ├── report_screen.dart             # Disease Report Submission Form
│   ├── report_history_screen.dart     # User's Past Report Timeline
│   ├── statistics_screen.dart         # Custom Bar Charts & Progress Rings
│   ├── insight_details_screen.dart    # Expandable Health Tip Details
│   ├── nearby_hospitals_screen.dart   # Hospital Directory (by Division)
│   ├── emergency_contacts_screen.dart # National Emergency Numbers
│   └── about_screen.dart              # Team Info, Theme Toggle, Logout
└── services/
    ├── api_service.dart               # Firebase Auth & Firestore CRUD
    ├── app_theme.dart                 # Theme Engine (ValueNotifier + 40+ colors)
    ├── symptom_predictor.dart         # ML Prediction Engine (30 symptoms → 13 diseases)
    └── seed_data.dart                 # Demo Data Generator (100 reports)
```

---

## 🧠 AI Symptom Prediction Engine

The built-in ML engine uses a **weighted scoring algorithm** — no TFLite or external ML dependencies required.

### How It Works

```
For each disease:
  score = prior_probability
  For each selected symptom:
    score += symptom_weight    // e.g., fever → 1.8 for Dengue
  confidence = score / (total_symptoms + 1) × 100
```

### Supported Diseases

| Disease | Triage | Top Weighted Symptoms |
|---------|--------|-----------------------|
| Dengue Fever | 🔴 High | fever (2.0), joint_pain (1.8), rash (1.6) |
| COVID-19 | 🔴 High | loss_of_taste (1.8), loss_of_smell (1.8), fever (1.6) |
| Pneumonia | 🔴 High | shortness_of_breath (2.0), chest_pain (1.8) |
| Malaria | 🔴 High | fever (1.8), high_fever (1.6), chills (1.6) |
| Typhoid | 🔴 High | fever (1.8), headache (1.0), loss_of_appetite (1.0) |
| Appendicitis | 🚨 Emergency | abdominal_pain (2.0), nausea (1.2) |
| Gastroenteritis | 🟡 Medium | diarrhea (2.0), vomiting (1.8), nausea (1.5) |
| Seasonal Flu | 🟢 Low | fever (1.5), body_ache (1.2), cough (1.2) |
| Common Cold | 🟢 Low | runny_nose (1.4), nasal_congestion (1.3) |
| *+ 4 more...* | | |

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x (Dart 3.11) |
| **Authentication** | Firebase Auth |
| **Database** | Cloud Firestore (NoSQL) |
| **Maps** | OpenStreetMap via `flutter_map` + `latlong2` |
| **Typography** | Google Fonts (`Outfit`) |
| **State Management** | `ValueNotifier` + `ValueListenableBuilder` |
| **Local Storage** | `SharedPreferences` |
| **External Links** | `url_launcher` (calls, directions) |
| **IDE** | Android Studio |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.x+ installed ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android Studio or VS Code
- A Firebase project with Android app configured

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/YOUR_USERNAME/healthscopeapp.git
cd healthscopeapp

# 2. Install dependencies
flutter pub get

# 3. Add your Firebase config
# Place google-services.json in android/app/

# 4. Run the app
flutter run
```

### Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project → Add Android app
3. Download `google-services.json` → place in `android/app/`
4. Enable **Authentication** (Email/Password)
5. Enable **Cloud Firestore** database

---

## 📱 Screens Overview

| # | Screen | Description |
|---|--------|-------------|
| 1 | **Login/Signup** | Glassmorphic auth with tab-based toggle, Firebase Auth |
| 2 | **Home Dashboard** | Live stats grid, health insights, quick action buttons |
| 3 | **Symptom Checker** | Categorized symptom chips with search, AI results with triage |
| 4 | **Trends Map** | Interactive heatmap with disease filters & Firebase markers |
| 5 | **Disease Report** | Multi-step form: disease → severity → location → symptoms |
| 6 | **Statistics** | Custom bar charts & circular progress (no chart libraries) |
| 7 | **Insight Details** | Expandable actionable health prevention steps |
| 8 | **Nearby Hospitals** | Division-filtered directory with call/directions buttons |
| 9 | **Emergency Contacts** | National numbers (999, 16789, etc.) with one-tap calling |
| 10 | **Report History** | User's personal submitted reports timeline |
| 11 | **About** | Team cards, dark/light toggle, seed data, logout |

---

## 🎯 Firestore Data Model

```
📁 users/
  └── {uid}
      ├── name: "Fuad Saad"
      ├── email: "fuad@example.com"
      ├── phone: "+880XXXXXXXXXX"
      └── created_at: Timestamp

📁 disease_reports/
  └── {auto_id}
      ├── user_id: "firebase_uid"
      ├── disease_type: "dengue"
      ├── severity: "severe"
      ├── division: "dhaka"
      ├── district: "Gazipur"
      ├── location: "Gazipur area"
      ├── symptoms: "High fever, rash, joint pain"
      ├── additional_info: "..."
      ├── timestamp: Timestamp
      └── is_demo: false

📁 symptom_checks/
  └── {auto_id}
      ├── user_id: "firebase_uid"
      ├── symptoms: ["fever", "cough", "headache"]
      ├── predicted_disease: "Seasonal Flu"
      ├── severity: "low"
      ├── recommendations: "..."
      └── timestamp: Timestamp
```

---

## 🤝 Team

Built with ❤️ by the HealthScope BD team.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**⭐ If you found this project helpful, please give it a star! ⭐**

</div>
