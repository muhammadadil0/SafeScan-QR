# 🚀 Quick Start Guide - SafeScan QR

## Running the Project on Physical Device

### Prerequisites
1. **Phone Setup:**
   - Enable USB Debugging on your Android phone
   - Connect phone to PC via USB cable
   - Connect phone to the SAME WiFi network as your PC

2. **PC Setup:**
   - Python 3 installed
   - Flutter installed
   - ADB (Android Debug Bridge) installed

### Run Everything with ONE Command

```bash
./run_project.sh
```

That's it! This single script will:
- ✅ Auto-detect your PC's IP address (192.168.1.116)
- ✅ Install Python dependencies if needed
- ✅ Start the AI backend server on port 5001
- ✅ Run Flutter app on your connected phone
- ✅ Monitor both services

### What You'll See

```
🚀 SafeScan QR - Complete Project Launcher
===========================================

✅ PC IP Address: 192.168.1.116
📱 Make sure your phone is connected to the SAME WiFi network!

🔍 Checking Python dependencies...
✅ Python dependencies ready

🤖 Starting AI Backend Server on 192.168.1.116:5001...
✅ Backend server started (PID: 12345)
   Local: http://127.0.0.1:5001
   Network: http://192.168.1.116:5001

📱 Checking for connected devices...
✅ Device connected!

📱 Starting Flutter App on physical device...
✅ Flutter app starting (PID: 12346)

🎉 Everything is running!
```

### Stopping the App

Press **Ctrl+C** in the terminal - it will automatically stop both backend and Flutter app.

### Troubleshooting

#### Phone not detected?
```bash
# Check if phone is visible
adb devices

# If not, try:
adb kill-server
adb start-server
adb devices
```

#### Backend not starting?
```bash
# Check the logs
tail -f backend.log
```

#### Flutter errors?
```bash
# Check the logs
tail -f flutter.log

# Or clean and rebuild
flutter clean
flutter pub get
./run_project.sh
```

#### Different WiFi network?
Make sure your phone and PC are on the **SAME WiFi network**. The app needs to connect to your PC at `192.168.1.116:5001`.

### Manual Commands (if needed)

#### Start Backend Only:
```bash
cd backend
python3 app.py
```

#### Start Flutter Only:
```bash
flutter run
```

### Network Information

- **Your PC IP:** 192.168.1.116
- **Backend Port:** 5001
- **Backend URL:** http://192.168.1.116:5001

The Flutter app is already configured to use this IP address!

---

**Happy Testing! 🎉**
