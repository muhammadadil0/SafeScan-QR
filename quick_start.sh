#!/bin/bash

# SafeScan QR - Quick Start Script
# Simple script to run the app quickly

echo "🚀 SafeScan QR - Quick Start"
echo "============================"
echo ""

# Start backend in background
echo "Starting backend..."
cd backend && python3 app.py &
BACKEND_PID=$!
cd ..

# Wait a bit for backend to start
sleep 3

# Start Flutter app
echo "Starting Flutter app..."
flutter run -d emulator-5554

# Cleanup when Flutter exits
kill $BACKEND_PID 2>/dev/null
