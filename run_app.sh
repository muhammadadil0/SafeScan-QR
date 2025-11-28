#!/bin/bash

# SafeScan QR - Complete App Launcher
# This script runs both the Flutter app and AI backend server

echo "🚀 SafeScan QR - Starting Application"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Python3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    echo "Please install Python 3"
    exit 1
fi

echo -e "${GREEN}✅ Flutter found: $(flutter --version | head -n 1)${NC}"
echo -e "${GREEN}✅ Python found: $(python3 --version)${NC}"
echo ""

# Check for connected devices
echo -e "${BLUE}📱 Checking for devices...${NC}"
flutter devices

# Get device ID
DEVICE_ID=$(flutter devices | grep "emulator" | awk '{print $5}' | head -n 1)

if [ -z "$DEVICE_ID" ]; then
    echo -e "${YELLOW}⚠️  No emulator found. Checking for physical devices...${NC}"
    DEVICE_ID=$(flutter devices | grep -v "Chrome" | grep -v "macOS" | awk '{print $5}' | head -n 1)
fi

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}❌ No devices found!${NC}"
    echo "Please start an emulator or connect a device"
    exit 1
fi

echo -e "${GREEN}✅ Using device: $DEVICE_ID${NC}"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Stopping services...${NC}"
    kill $BACKEND_PID 2>/dev/null
    kill $FLUTTER_PID 2>/dev/null
    echo -e "${GREEN}✅ Services stopped${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start Backend Server
echo -e "${BLUE}🤖 Starting AI Backend Server...${NC}"
cd backend
python3 app.py > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Wait for backend to start
sleep 3

# Check if backend is running
if ps -p $BACKEND_PID > /dev/null; then
    echo -e "${GREEN}✅ Backend server started (PID: $BACKEND_PID)${NC}"
    echo -e "${GREEN}   Running on: http://127.0.0.1:5001${NC}"
    echo -e "${GREEN}   Android Emulator: http://10.0.2.2:5001${NC}"
else
    echo -e "${RED}❌ Failed to start backend server${NC}"
    echo "Check backend.log for errors"
    exit 1
fi

echo ""

# Start Flutter App
echo -e "${BLUE}📱 Starting Flutter App...${NC}"
flutter run -d $DEVICE_ID > flutter.log 2>&1 &
FLUTTER_PID=$!

echo -e "${GREEN}✅ Flutter app starting (PID: $FLUTTER_PID)${NC}"
echo ""
echo -e "${YELLOW}📋 Logs:${NC}"
echo "   Backend: tail -f backend.log"
echo "   Flutter: tail -f flutter.log"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all services${NC}"
echo ""

# Monitor both processes
while true; do
    if ! ps -p $BACKEND_PID > /dev/null; then
        echo -e "${RED}❌ Backend server stopped unexpectedly${NC}"
        cleanup
    fi
    
    if ! ps -p $FLUTTER_PID > /dev/null; then
        echo -e "${RED}❌ Flutter app stopped unexpectedly${NC}"
        cleanup
    fi
    
    sleep 5
done
