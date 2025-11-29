#!/bin/bash

# SafeScan QR - Unified Project Launcher
# This script runs everything you need for physical device testing

echo "🚀 SafeScan QR - Complete Project Launcher"
echo "==========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get PC IP address automatically
PC_IP=$(ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -n 1)

if [ -z "$PC_IP" ]; then
    echo -e "${RED}❌ Could not detect PC IP address${NC}"
    echo "Please check your network connection"
    exit 1
fi

echo -e "${GREEN}✅ PC IP Address: $PC_IP${NC}"
echo -e "${YELLOW}📱 Make sure your phone is connected to the SAME WiFi network!${NC}"
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

# 1. Setup Python Virtual Environment
echo -e "${BLUE}🔍 Setting up Python environment...${NC}"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}📦 Creating Python virtual environment...${NC}"
    python3 -m venv venv
    echo -e "${GREEN}✅ Virtual environment created${NC}"
fi

# Activate virtual environment
source venv/bin/activate

# Check and install dependencies
cd backend

if ! python3 -c "import flask" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Installing Flask...${NC}"
    pip install flask flask-cors
fi

if ! python3 -c "import transformers" 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Installing Transformers (this may take a few minutes)...${NC}"
    pip install transformers torch
fi

echo -e "${GREEN}✅ Python dependencies ready${NC}"
cd ..
echo ""

# 2. Start Backend Server
echo -e "${BLUE}🤖 Starting AI Backend Server on $PC_IP:5001...${NC}"
cd backend
../venv/bin/python app.py > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

# Wait for backend to start
sleep 5

# Check if backend is running
if ps -p $BACKEND_PID > /dev/null; then
    echo -e "${GREEN}✅ Backend server started (PID: $BACKEND_PID)${NC}"
    echo -e "${GREEN}   Local: http://127.0.0.1:5001${NC}"
    echo -e "${GREEN}   Network: http://$PC_IP:5001${NC}"
else
    echo -e "${RED}❌ Failed to start backend server${NC}"
    echo "Check backend.log for errors"
    exit 1
fi

echo ""

# 3. Check for connected devices
echo -e "${BLUE}📱 Checking for connected devices...${NC}"

# Check if adb is available
if command -v adb &> /dev/null; then
    adb devices -l
    echo ""
    
    # Wait for device if not connected
    DEVICE_COUNT=$(adb devices | grep -v "List" | grep "device" | wc -l)
    if [ "$DEVICE_COUNT" -eq 0 ]; then
        echo -e "${YELLOW}⚠️  No device detected!${NC}"
        echo -e "${YELLOW}Please connect your phone via USB and enable USB debugging${NC}"
        echo -e "${YELLOW}Waiting for device...${NC}"
        adb wait-for-device
        echo -e "${GREEN}✅ Device connected!${NC}"
        echo ""
    fi
else
    echo -e "${YELLOW}⚠️  ADB not found, continuing anyway...${NC}"
fi

# 4. Flutter setup
echo -e "${BLUE}📦 Running Flutter pub get...${NC}"
flutter pub get

echo ""

# 5. Start Flutter App
echo -e "${BLUE}📱 Starting Flutter App on physical device...${NC}"
echo -e "${YELLOW}Note: The app will use $PC_IP:5001 for AI backend${NC}"
echo ""

flutter run > flutter.log 2>&1 &
FLUTTER_PID=$!

echo -e "${GREEN}✅ Flutter app starting (PID: $FLUTTER_PID)${NC}"
echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 Everything is running!${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Service Information:${NC}"
echo -e "   Backend API: http://$PC_IP:5001"
echo -e "   Backend Logs: tail -f backend.log"
echo -e "   Flutter Logs: tail -f flutter.log"
echo ""
echo -e "${BLUE}📱 Device Setup:${NC}"
echo -e "   1. Make sure phone is on WiFi: Same network as PC"
echo -e "   2. USB Debugging: Enabled"
echo -e "   3. USB Connection: Connected to PC"
echo ""
echo -e "${YELLOW}⌨️  Press Ctrl+C to stop all services${NC}"
echo ""

# Monitor both processes
while true; do
    if ! ps -p $BACKEND_PID > /dev/null; then
        echo -e "${RED}❌ Backend server stopped unexpectedly${NC}"
        echo "Check backend.log for errors"
        cleanup
    fi
    
    if ! ps -p $FLUTTER_PID > /dev/null; then
        echo -e "${YELLOW}⚠️  Flutter app stopped${NC}"
        cleanup
    fi
    
    sleep 5
done
