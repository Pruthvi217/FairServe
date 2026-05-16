# FairServe – Smart Ration Management System

## Overview

FairServe is a Flutter-based Smart Ration Management System developed to improve transparency, accessibility, and efficiency in the Public Distribution System (PDS). The application enables users to locate nearby ration shops, check stock availability, authenticate securely using OTP verification, and access ration-related services digitally.

The system integrates Flutter frontend, Firebase Authentication, MongoDB backend, geolocation services, and OpenStreetMap for smart ration shop management.

---

# Features

## User Features

- Mobile number login using Firebase OTP Authentication
- Secure user registration system
- Real-time location access
- Nearby ration shop locator
- Interactive map interface using OpenStreetMap
- Live distance calculation to ration shops
- View ration shop details
- Check available stock:
  - Rice
  - Wheat
  - Sugar
  - Kerosene
- User-friendly responsive UI
- Automatic location permission handling
- Firebase-based secure authentication
- GPS-based nearest shop identification

---

## Admin Features

- Admin login system
- Manage ration shop details
- Update stock availability
- Add or remove ration shops
- Monitor shop information
- Manage users and shop records

---

# Technologies Used

## Frontend

- Flutter
- Dart

## Backend

- Node.js
- Express.js

## Database

- MongoDB

## Authentication

- Firebase Authentication

## Maps & Location

- flutter_map
- OpenStreetMap
- Geolocator

## Tools & Platforms

- Android Studio
- VS Code
- GitHub
- Firebase Console

---

# Project Structure

```bash
FairServe/
│
├── flutter_app/
│   ├── lib/
│   ├── android/
│   ├── ios/
│   ├── pubspec.yaml
│
├── backend/
│   ├── server.js
│   ├── routes/
│   ├── models/
│   ├── package.json
│
└── README.md
```

---

# Prerequisites

Before running the project, install the following:

- Flutter SDK
- Android Studio
- VS Code
- Node.js
- MongoDB
- Git
- Firebase Account

---

# Flutter Setup

## Clone Repository

```bash
git clone https://github.com/Pruthvi217/FairServe.git
```

## Open Flutter Project

```bash
cd FairServe/flutter_app
```

## Install Dependencies

```bash
flutter pub get
```

## Run Flutter App

```bash
flutter run
```

---

# Backend Setup

## Open Backend Folder

```bash
cd FairServe/backend
```

## Install Backend Dependencies

```bash
npm install
```

## Start Backend Server

```bash
npm run dev
```

OR

```bash
node server.js
```

---

# MongoDB Setup

## Install MongoDB Community Edition

Download and install MongoDB Community Server.

## Start MongoDB

```bash
mongod
```

## MongoDB Connection URL

```bash
mongodb://127.0.0.1:27017/fairserve
```

---

# Firebase Setup

## Step 1: Create Firebase Project

1. Open Firebase Console
2. Create a new project
3. Add Android application

---

## Step 2: Enable Phone Authentication

Go to:

```bash
Firebase Console → Authentication → Sign-in Method
```

Enable:

- Phone Authentication

---

## Step 3: Generate SHA-1 Key

Run:

```bash
cd android
./gradlew signingReport
```

Copy the SHA-1 key.

---

## Step 4: Add SHA-1 in Firebase

Go to:

```bash
Firebase Console → Project Settings → Android App
```

Add SHA-1 key and save.

---

## Step 5: Download google-services.json

Place the downloaded file inside:

```bash
android/app/
```

---

# Emulator Location Setup

## Set Emulator GPS Location

1. Open Android Emulator
2. Click Extended Controls
3. Open Location section
4. Enter Latitude & Longitude
5. Click Send

---

# GitHub Commands

## Push Project to GitHub

```bash
git add .
git commit -m "updated project"
git push
```

---

# Build APK

## Debug APK

```bash
flutter build apk --debug
```

## Release APK

```bash
flutter build apk --release
```

APK Output Location:

```bash
build/app/outputs/flutter-apk/
```

---

# Important Flutter Packages Used

```yaml
firebase_auth
firebase_core
flutter_map
latlong2
geolocator
http
provider
```

---

# Common Errors & Fixes

## Firebase Duplicate App Error

Use this inside main.dart:

```dart
WidgetsFlutterBinding.ensureInitialized();

if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp();
}
```

---

## Bottom Overflow Pixel Error

Fixes used:

- SafeArea
- SingleChildScrollView
- Wrap instead of Row

---

## Firebase OTP Billing Error

Ensure:

- SHA-1 key added
- Firebase Authentication enabled
- Test phone number configured

---

# Screens Included

- Splash Screen
- Login Screen
- OTP Verification Screen
- Registration Screen
- Nearby Shops Map Screen
- Shop Details Card
- Admin Login Screen
- Dashboard Screen

---

# Future Enhancements

- QR Code Authentication
- Aadhaar Integration
- AI-Based Stock Prediction
- Complaint Management System
- Cloud Deployment
- Push Notifications
- Multi-language Support
- Online Ration Booking
- Smart Analytics Dashboard
- Real-time Stock Synchronization

---

# Advantages

- Transparent ration distribution
- Easy access to nearby shops
- Reduces manual work
- Prevents stock misinformation
- Improves user convenience
- Secure authentication system
- Real-time location support

---

# Author

## Pruthvi C

Smart Ration Management System using Flutter, Firebase, MongoDB, and Geolocation.

---

# License

This project is developed for educational and academic purposes.
