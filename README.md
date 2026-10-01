# SportSpace

Mobile sports facility booking app.

## Tech Stack

- Mobile: Flutter
- Backend: Node.js + Express
- Database: PostgreSQL
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

1. Copy `.env.example` to `.env` and fill in your values
2. Backend: `cd backend && npm install && npm run dev`
3. Mobile: `cd mobile && flutter pub get && flutter run`
