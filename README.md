# SportSpace

Mobile sports facility booking app.

## Tech Stack

- Mobile: Flutter
- Backend: Node.js + Express
- Database: MongoDB
- Auth & Notifications: Firebase (Auth, FCM)

## Repository Structure

- `/mobile`: Flutter app
- `/backend`: Express API
- `/docs`: reports and diagrams

## Team

| Member | Module                                                          |
| ------ | --------------------------------------------------------------- |
| <name> | Login, Home/Search, Facility Profile & Reviews                  |
| <name> | Slot Selection, Conflict Resolution, Payment, Cancel/Reschedule |
| <name> | Manager Portal                                                  |
| <name> | Public Events, Contact Info, Notifications                      |

## Branching

- `main`: stable, demo-ready
- `develop`: integration branch
- Work on `feature/<name>`, `fix/<name>` or `docs/<name>` branches created from `develop`
- Merge only through pull requests with at least 1 review; delete the branch after merging

## Commit Messages

`feat:`, `fix:`, `docs:`, `chore:`

## Setup

### Prerequisites

- Node.js 20 or newer and npm
- Flutter SDK with a configured Android emulator or physical Android device
- MongoDB Atlas access, or a local MongoDB server

### Backend

1. Copy `.env.example` to `.env` in the repository root.
2. Set `MONGODB_URI` to your MongoDB connection string. For Atlas, the database user's IP address must be allowed in Atlas **Network Access**.
3. From the repository root, install dependencies and start the API:

   ```powershell
   cd backend
   npm install
   npm run dev
   ```

4. Confirm it is running by opening `http://localhost:5000/api/health`. The expected response contains `"status":"OK"`.

The backend loads the root `.env` file even when started from the `backend` directory. Do not commit `.env`; it is ignored by Git.

### Mobile

In a second terminal:

```powershell
cd mobile
flutter pub get
flutter devices
flutter run
```

The app currently uses `http://10.0.2.2:5000/api`, which is correct for an Android emulator. For a physical device, replace `10.0.2.2` in `mobile/lib/services/api_service.dart` with the computer's local network IP (for example, `192.168.1.10`) and ensure Windows Firewall allows port 5000.

For iOS, use `http://127.0.0.1:5000/api` in the iOS simulator, or the computer's local network IP on a physical iPhone.
