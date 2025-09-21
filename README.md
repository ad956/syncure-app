# Syncure App

## Overview
Syncure App is a modern healthcare platform designed to streamline patient management and monitoring.  
- **Flutter mobile app**: for patients to manage their health journey.  
- **NestJS backend**: serves all users including patients, hospital staff, and admins.

---

## [![My Skills](https://go-skill-icons.vercel.app/api/icons?i=flutter,dart,nestjs,ts,pnpm,mongodb,graphql&theme=dark)](https://skillicons.dev)

---

## Features

### Mobile App (Flutter - Patients)
- Secure registration and login.
- View and manage personal health records.
- Schedule and track appointments.
- Receive real-time notifications and health alerts.

### Backend (NestJS)
- User authentication & role management (patients, staff, admin).
- Centralized API for mobile app and future web clients.
- Patient and hospital management.
- Appointment scheduling and notifications.
- Supports both REST and GraphQL endpoints.

---

## Repository Structure

```

/syncure-app
/backend    -> NestJS backend project
/app     -> Flutter app for patients
README.md   -> This file
.gitignore  -> Root ignore rules for Node & Flutter

````

---

## Setup Instructions

### 1. Clone the repository
```bash
git clone https://github.com/ad956/syncure-app.git
cd syncure-app
````

### 2. Backend (NestJS) Setup

```bash
cd backend
pnpm install       # Install backend dependencies
pnpm run start:dev # Start NestJS in development mode
```

* Ensure `.env` file exists in `backend` folder with required environment variables.

### 3. Mobile App (Flutter) Setup

```bash
cd ../app
flutter pub get    # Install Flutter dependencies
flutter run        # Run the Flutter app on connected device/emulator
```

---

## Scripts (Root Convenience)

You can add optional root scripts to start both projects easily:

```bash
pnpm dev:backend   # Starts NestJS backend
pnpm dev:app    # Runs Flutter app
```