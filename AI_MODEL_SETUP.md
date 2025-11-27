# AI Model Integration Guide

## 🚀 Quick Start

This guide will help you set up the AI-powered malicious URL detection for SafeScan-QR.

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)
- Your PC and phone on the same Wi-Fi network (for testing on real device)

## Step 1: Install Python Dependencies

Navigate to the backend folder and install required packages:

```bash
cd backend
pip install flask flask-cors transformers torch
```

**Note:** The first time you run the server, it will automatically download the AI model (~500MB). This is a one-time download.

## Step 2: Start the AI Server

Run the Flask server:

```bash
python app.py
```

You should see:
```
⏳ Loading Model... (This might take a minute the first time)
✅ Model Loaded and Ready!
 * Running on http://0.0.0.0:5000
```

**Keep this terminal window open** while testing the app.

## Step 3: Configure the API URL in Flutter

Open `lib/services/security_service.dart` and update the `AI_API_URL` constant:

### For Android Emulator:
```dart
static const String AI_API_URL = "http://10.0.2.2:5000/scan";
```

### For Real Android/iOS Device:
1. Find your PC's IP address:
   - **Windows:** Run `ipconfig` in Command Prompt, look for "IPv4 Address"
   - **Mac/Linux:** Run `ifconfig` or `ip addr`, look for your local IP (e.g., 192.168.1.5)

2. Update the URL:
```dart
static const String AI_API_URL = "http://YOUR_PC_IP:5000/scan";
// Example: static const String AI_API_URL = "http://192.168.1.5:5000/scan";
```

### For iOS Simulator:
```dart
static const String AI_API_URL = "http://localhost:5000/scan";
```

## Step 4: Run the Flutter App

```bash
flutter run
```

## Testing the Integration

1. **Test the server** by visiting `http://localhost:5000` in your browser
   - You should see: "QR Security Server is Running!"

2. **Scan a QR code** in the app
   - The app will send the URL to the AI model
   - You'll see AI predictions in the scan results with confidence scores

3. **Check the logs:**
   - **Server logs:** Watch the terminal running `app.py` for scan requests
   - **Flutter logs:** Check the console for AI model responses

## How It Works

1. User scans a QR code
2. The app performs rule-based security checks (offline)
3. The app sends the URL to the AI model API (requires internet)
4. The AI model analyzes the URL and returns:
   - `is_safe`: boolean (true/false)
   - `confidence`: percentage (0-100%)
   - `label`: 'benign' or 'malicious'
5. The app combines AI results with rule-based analysis
6. Final risk score and recommendations are shown to the user

## AI Model Details

- **Model:** Eason918/malicious-url-detector
- **Type:** DistilBERT-based text classification
- **Purpose:** Detects malicious URLs with high accuracy
- **Speed:** ~100-500ms per URL
- **Offline:** No (requires API server running)

## Troubleshooting

### "Connection Error" in Flutter app
- ✅ Make sure the Flask server is running
- ✅ Check that the IP address is correct
- ✅ Ensure your phone and PC are on the same Wi-Fi
- ✅ Check firewall settings (allow port 5000)

### "Model Loading Error" in Python
- ✅ Install torch: `pip install torch`
- ✅ Check internet connection (for first-time model download)
- ✅ Try: `pip install --upgrade transformers`

### Slow predictions
- ✅ First prediction is always slower (model initialization)
- ✅ Consider using GPU if available
- ✅ The model caches after first use

## Production Deployment

For production use, consider:
1. Deploy the Flask server to a cloud service (AWS, Google Cloud, Heroku)
2. Use HTTPS instead of HTTP
3. Add authentication/API keys
4. Implement rate limiting
5. Add caching for frequently scanned URLs

## Alternative: Run Without AI Model

If you don't want to use the AI model, the app will still work with rule-based detection only. The AI integration gracefully fails and continues with offline analysis.

---

**Need help?** Check the server logs and Flutter console for detailed error messages.
