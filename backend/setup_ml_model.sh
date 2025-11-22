#!/bin/bash

# SafeScan QR - ML Model Quick Setup Script
# This script automates the ML model generation process

echo "🤖 SafeScan QR - ML Model Setup"
echo "================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed"
    echo "Please install Python 3.8+ and try again"
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"
echo ""

# Check if we're in the backend directory
if [ ! -d "training" ]; then
    echo "⚠️ Please run this script from the backend directory"
    echo "Usage: cd backend && ./setup_ml_model.sh"
    exit 1
fi

# Create virtual environment if it doesn't exist
if [ ! -d "ven" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv ven
    echo "✅ Virtual environment created"
fi

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source ven/bin/activate

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    echo "💡 Try running manually:"
    echo "   source ven/bin/activate"
    echo "   pip install -r requirements.txt"
    exit 1
fi

echo "✅ Dependencies installed"
echo ""

# Navigate to training directory
cd training || exit 1

# Train the model
echo "🏋️ Training ML model..."
python3 train_model.py

if [ $? -ne 0 ]; then
    echo "❌ Model training failed"
    exit 1
fi

echo "✅ Model trained successfully"
echo ""

# Convert to TFLite
echo "🔄 Converting to TensorFlow Lite..."
python3 convert_to_tflite.py

if [ $? -ne 0 ]; then
    echo "❌ TFLite conversion failed"
    exit 1
fi

echo "✅ TFLite model created"
echo ""

# Copy to Flutter assets
echo "📁 Copying model to Flutter assets..."
mkdir -p ../../assets/models
cp url_classifier.tflite ../../assets/models/

if [ $? -ne 0 ]; then
    echo "❌ Failed to copy model"
    exit 1
fi

echo "✅ Model copied to assets/models/"
echo ""

# Return to backend directory
cd ..

# Deactivate virtual environment
deactivate

echo ""
echo "🎉 ML Model Setup Complete!"
echo ""
echo "📝 Next steps:"
echo "1. cd .. (go back to project root)"
echo "2. flutter pub get"
echo "3. flutter run"
echo ""
echo "📊 Model Info:"
echo "- Location: assets/models/url_classifier.tflite"
echo "- Size: ~45 KB"
echo "- Classes: Safe, Phishing, Malware, Spam"
echo "- Features: 30 URL characteristics"
echo ""
