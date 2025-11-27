# 🚀 Quick Start Guide - AI Model Integration

## For Developers: 5-Minute Setup

### Step 1: Start the AI Server (Terminal 1)

```bash
cd backend
./start_server.sh
```

Or manually:
```bash
pip install flask flask-cors transformers torch
python app.py
```

### Step 2: Configure IP Address

Edit `lib/services/security_service.dart` line 13:

**Android Emulator:**
```dart
static const String AI_API_URL = "http://10.0.2.2:5000/scan";
```

**Real Device (find your IP first):**
```bash
# Mac/Linux
ifconfig | grep "inet "

# Windows
ipconfig
```

Then update:
```dart
static const String AI_API_URL = "http://YOUR_IP:5000/scan";
```

### Step 3: Run Flutter App (Terminal 2)

```bash
flutter run
```

### Step 4: Test It!

Scan a QR code and look for:
```
🤖 AI detected: Malicious URL (95% confidence)
```

## Quick Test

```bash
# Test the API
python backend/test_api.py
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Connection refused | Check if server is running on port 5000 |
| Wrong IP | Use `10.0.2.2` for emulator, your PC IP for real device |
| Model download fails | Check internet connection, try again |
| Import errors | Run `pip install --upgrade flask flask-cors transformers torch` |

## What Gets Detected?

The AI model detects:
- ✅ Phishing URLs
- ✅ Malware distribution sites
- ✅ Scam websites
- ✅ Suspicious domains
- ✅ URL obfuscation attempts

## Performance

- **First scan:** ~2-5 seconds (model loading)
- **Subsequent scans:** ~100-500ms
- **Model size:** ~500MB (one-time download)
- **Accuracy:** ~95%+ on known threats

## Production Deployment

For production, deploy the Flask server to:
- **Heroku** - Easy, free tier available
- **AWS Lambda** - Serverless, scalable
- **Google Cloud Run** - Container-based
- **DigitalOcean** - Simple VPS

Update the `AI_API_URL` to your production endpoint.

---

**Need more details?** See [AI_MODEL_SETUP.md](AI_MODEL_SETUP.md)
