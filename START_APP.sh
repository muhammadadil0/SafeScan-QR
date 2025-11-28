#!/bin/bash

# SafeScan QR - Complete Startup Script
# Starts emulator, backend, and Flutter app

echo "🚀 SafeScan QR - Complete Startup"
echo "=================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Start Android Emulator
echo -e "${BLUE}📱 Starting Android Emulator...${NC}"
flutter emulators --launch Pixel_3a_API_34 &
EMULATOR_PID=$!

echo "Waiting for emulator to boot (30 seconds)..."
sleep 30

# 2. Start Backend Server
echo ""
echo -e "${BLUE}🤖 Starting AI Backend Server...${NC}"
cd backend
python3 app.py > ../backend.log 2>&1 &
BACKEND_PID=$!
cd ..

echo "Waiting for backend to start (5 seconds)..."
sleep 5

if ps -p $BACKEND_PID > /dev/null; then
    echo -e "${GREEN}✅ Backend running on http://127.0.0.1:5001${NC}"
else
    echo -e "${RED}❌ Backend failed to start${NC}"
    exit 1
fi

# 3. Start Flutter App
echo ""
echo -e "${BLUE}📱 Starting Flutter App...${NC}"
flutter run

# Cleanup
echo ""
echo "Cleaning up..."
kill $BACKEND_PID 2>/dev/null
