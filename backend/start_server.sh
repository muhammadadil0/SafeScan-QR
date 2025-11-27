#!/bin/bash

# SafeScan-QR AI Model Server Startup Script

echo "🚀 SafeScan-QR AI Model Server"
echo "================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null
then
    echo "❌ Python 3 is not installed. Please install Python 3.8 or higher."
    exit 1
fi

echo "✅ Python found: $(python3 --version)"
echo ""

# Check if we're in the backend directory
if [ ! -f "app.py" ]; then
    echo "📁 Navigating to backend directory..."
    cd backend
fi

# Check if dependencies are installed
echo "📦 Checking dependencies..."
if ! python3 -c "import flask" 2>/dev/null; then
    echo "⚠️  Dependencies not found. Installing..."
    pip3 install flask flask-cors transformers torch
else
    echo "✅ Dependencies already installed"
fi

echo ""
echo "🔥 Starting AI Model Server..."
echo "⏳ Note: First run will download the AI model (~500MB)"
echo ""
echo "📱 Configure your Flutter app with one of these URLs:"
echo "   - Android Emulator: http://10.0.2.2:5000/scan"
echo "   - iOS Simulator: http://localhost:5000/scan"
echo "   - Real Device: http://$(ipconfig getifaddr en0 2>/dev/null || hostname -I | awk '{print $1}'):5000/scan"
echo ""
echo "Press Ctrl+C to stop the server"
echo "================================"
echo ""

# Start the server
python3 app.py
