# 🚀 SafeScan QR - Run Instructions

## Quick Start Scripts

I've created several scripts to make running the app easier:

### 1. **START_APP.sh** (Recommended - Complete Setup)
Starts everything: Emulator + Backend + Flutter App

```bash
./START_APP.sh
```

**What it does:**
- ✅ Launches Android emulator (Pixel 3a)
- ✅ Starts AI backend server on port 5001
- ✅ Runs Flutter app
- ✅ Cleans up when you exit

---

### 2. **quick_start.sh** (If emulator is already running)
Quick start for backend + Flutter app

```bash
./quick_start.sh
```

**What it does:**
- ✅ Starts backend server
- ✅ Runs Flutter app on emulator-5554
- ✅ Cleans up on exit

---

### 3. **run_app.sh** (Advanced - Auto-detect device)
Full-featured script with monitoring

```bash
./run_app.sh
```

**What it does:**
- ✅ Checks for Flutter and Python
- ✅ Auto-detects connected devices
- ✅ Starts backend with logging
- ✅ Starts Flutter with logging
- ✅ Monitors both processes
- ✅ Creates log files (backend.log, flutter.log)

---

## Manual Commands

### Start Backend Only:
```bash
cd backend
python3 app.py
```

### Start Flutter App Only:
```bash
# Check available devices
flutter devices

# Run on specific device
flutter run -d emulator-5554

# Or let Flutter choose
flutter run
```

### Start Emulator:
```bash
flutter emulators --launch Pixel_3a_API_34
```

---

## Troubleshooting

### Emulator not found?
```bash
# List available emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator-id>
```

### Port 5001 already in use?
```bash
# Find and kill process on port 5001
lsof -ti:5001 | xargs kill -9
```

### Backend not starting?
```bash
# Check Python version
python3 --version

# Install dependencies
cd backend
pip3 install flask flask-cors transformers torch
```

### Flutter build errors?
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## Process Management

### View Logs:
```bash
# Backend logs
tail -f backend.log

# Flutter logs
tail -f flutter.log
```

### Stop All Services:
Press `Ctrl+C` in the terminal running the script

### Kill Processes Manually:
```bash
# Kill backend
pkill -f "python3 app.py"

# Kill Flutter
pkill -f "flutter run"
```

---

## What's Running?

When you start the app, you'll have:

1. **Backend Server**
   - URL: http://127.0.0.1:5001
   - Android Emulator: http://10.0.2.2:5001
   - Real Device: http://192.168.1.85:5001

2. **Flutter App**
   - Running on your selected device
   - Hot reload enabled (press 'r')
   - Hot restart enabled (press 'R')

3. **Android Emulator** (if using START_APP.sh)
   - Pixel 3a API 34
   - Device ID: emulator-5554

---

## Recommended Workflow

### First Time:
```bash
./START_APP.sh
```

### Subsequent Runs (if emulator is running):
```bash
./quick_start.sh
```

### Development (with logs):
```bash
./run_app.sh
```

---

## Firebase Setup Required

Before running, make sure you've:
1. ✅ Enabled Email/Password authentication in Firebase Console
2. ✅ Created Firestore database
3. ✅ Set up security rules

See `FIREBASE_SETUP.md` for details.

---

**Happy Coding! 🎉**
