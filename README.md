# 🏟️ SportSpace

![SportSpace Banner](https://img.shields.io/badge/Status-Active-brightgreen)
![Flutter](https://img.shields.io/badge/Mobile-Flutter-blue)
![Node.js](https://img.shields.io/badge/Backend-Node.js-green)
![Next.js](https://img.shields.io/badge/Admin-Next.js-black)
![MongoDB](https://img.shields.io/badge/Database-MongoDB-success)

**SportSpace** is a comprehensive, end-to-end sports facility management and booking system. It seamlessly connects players looking to book courts (badminton, tennis, futsal, etc.) with facility managers who need an efficient way to manage their schedules, payments, and maintenance operations.

---

## 🎯 Key Features

### 👤 For Players
* **Discover & Explore:** Search for facilities by location, sport type, and availability.
* **Real-Time Booking:** View live slot availability and reserve courts instantly.
* **Smart Conflict Resolution:** Handles race conditions gracefully if two users try to book the same slot simultaneously.
* **Flexible Payments:** Pay securely via Stripe (Credit/Debit Card) or upload a Bank Transfer slip.
* **Manage Bookings:** Reschedule, cancel, and view past booking history.

### 👔 For Facility Managers
* **Live Dashboard:** Monitor daily revenue, upcoming bookings, and pending tasks.
* **Payment Verification:** Review and manually verify uploaded bank transfer slips.
* **Schedule Management:** Block out time slots or mark courts as "Under Maintenance".
* **Facility Profiles:** Update facility details, amenities, and photos.

### 🌐 For Admin / Web
* **Global Oversight:** Centralized Next.js dashboard to oversee all platform operations.
* **Master Payment Audit:** Aggregate view of all transactions and manager actions.

---

## 🛠️ Technology Stack

The system follows a modern **3-Tier Architecture**:

1. **Frontend (Mobile App)**: Flutter (Dart), Firebase Auth (Google Sign-In), Stripe SDK.
2. **Backend (API Layer)**: Node.js, Express.js, Mongoose, Nodemailer, Multer.
3. **Frontend (Admin Web)**: Next.js (React), Tailwind CSS, shadcn/ui.
4. **Database & External Services**: MongoDB Atlas (NoSQL), Stripe Payment Gateway, Cloudinary (Image Hosting).

---

## 📂 Project Structure

This repository is organized into a monorepo structure containing three main components:

```
SportSpace/
│
├── mobile/          # The Flutter mobile application (Players, Managers, Tertiary users)
│
├── backend/         # The Node.js/Express REST API server
│
└── admin-web/       # The Next.js web dashboard for platform administrators
```

---

## 🚀 Getting Started

Follow these instructions to set up the project locally on your machine.

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19+)
* [Node.js](https://nodejs.org/) (v18+)
* [MongoDB](https://www.mongodb.com/) (Local or Atlas instance)
* Android Studio / Xcode (for mobile emulation)

### 1. Backend Setup
1. Navigate to the backend directory: `cd backend`
2. Install dependencies: `npm install`
3. Create a `.env` file based on the environment variables needed (MongoDB URI, Firebase Admin credentials, Stripe keys, Cloudinary config).
4. Start the development server: `npm run dev`
*(The backend runs on `http://localhost:5000`)*

### 2. Admin Web Setup
1. Navigate to the admin web directory: `cd admin-web`
2. Install dependencies: `npm install`
3. Start the Next.js development server: `npm run dev`
*(The admin dashboard runs on `http://localhost:3000`)*

### 3. Mobile App Setup
1. Navigate to the mobile directory: `cd mobile`
2. Fetch Flutter packages: `flutter pub get`
3. Run the app on a connected device or emulator: `flutter run`

---

## 📖 Architecture & Database Schema

* **3-Tier Architecture Diagram:** Shows the flow between the Flutter Client, Node.js API, and MongoDB/Stripe services.
* **MongoDB ER Diagram:** Details the 7 core collections (`Users`, `Facilities`, `Slots`, `Bookings`, `PaymentVerifications`, `Maintenance`, `Reviews`).

*(Diagrams are available in the project documentation/artifacts).*

---

## 👥 Contributors

* **Gamlath G.R.I.U** (Booking Flow, Payments, Conflict Resolution)
* **Ubeysinghe U.A.D** (Onboarding, Home, Facility Profiles, Auth)
* **Ranaweera S.M.M.H** (Manager Flow, Admin Web Dashboard, Maintenance)
* **Bimsara P** (Tertiary Users, Events, Notifications, Testing)

*Developed for SLIIT Y3S2 HCI Module.*
