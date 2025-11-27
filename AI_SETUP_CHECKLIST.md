# ✅ AI Model Integration Checklist

Use this checklist to ensure everything is set up correctly.

## 📋 Pre-Setup

- [ ] Python 3.8+ installed (`python3 --version`)
- [ ] pip installed (`pip3 --version`)
- [ ] Flutter SDK installed (`flutter --version`)
- [ ] Git repository up to date

## 🔧 Backend Setup

- [ ] Navigate to backend directory (`cd backend`)
- [ ] Install Python dependencies:
  ```bash
  pip install flask flask-cors transformers torch
  ```
- [ ] Start the server:
  ```bash
  python app.py
  ```
- [ ] Verify server is running:
  - [ ] See "✅ Model Loaded and Ready!" message
  - [ ] Visit http://localhost:5000 in browser
  - [ ] See "QR Security Server is Running!" message

## 📱 Flutter Configuration

- [ ] Open `lib/services/security_service.dart`
- [ ] Find line 13: `static const String AI_API_URL`
- [ ] Choose your configuration:

  ### For Android Emulator:
  - [ ] Use: `"http://10.0.2.2:5000/scan"`
  
  ### For Real Device:
  - [ ] Find your PC's IP address:
    - Mac/Linux: `ifconfig | grep "inet "`
    - Windows: `ipconfig`
  - [ ] Update to: `"http://YOUR_IP:5000/scan"`
  - [ ] Ensure phone and PC on same Wi-Fi
  
  ### For iOS Simulator:
  - [ ] Use: `"http://localhost:5000/scan"`

## 🧪 Testing

- [ ] Run the test script:
  ```bash
  python backend/test_api.py
  ```
- [ ] All tests should pass (4/4)
- [ ] Run Flutter app:
  ```bash
  flutter run
  ```
- [ ] Scan a test QR code
- [ ] Check for AI detection messages:
  - [ ] Look for 🤖 emoji in results
  - [ ] See confidence percentage
  - [ ] Verify risk score includes AI analysis

## 🔍 Verification

### Server Logs Should Show:
```
🔎 Scanning: https://example.com
🤖 AI Result: Safe (95.67% confidence)
```

### Flutter Console Should Show:
```
🤖 Sending URL to AI model: https://example.com
🤖 AI Result: Safe (95.67% confidence)
```

### Result Screen Should Display:
- [ ] Risk score circle
- [ ] AI detection message with 🤖 icon
- [ ] Confidence percentage
- [ ] Overall security status

## 🐛 Troubleshooting

If something doesn't work, check:

- [ ] Server is running (Terminal 1)
- [ ] Flutter app is running (Terminal 2)
- [ ] IP address is correct
- [ ] Port 5000 is not blocked by firewall
- [ ] Internet connection is active (for model download)
- [ ] No error messages in server logs
- [ ] No error messages in Flutter console

## 📊 Performance Check

- [ ] First scan takes 2-5 seconds (normal - model loading)
- [ ] Subsequent scans take <1 second
- [ ] Server responds within 5 seconds
- [ ] No crashes or freezes

## 🎯 Final Verification

Test with these URLs:

- [ ] Safe URL: `https://www.google.com`
  - Should show: ✅ Safe with high confidence
  
- [ ] Suspicious URL: `http://192.168.1.1/admin.php?password=123`
  - Should show: ⚠️ Suspicious or 🚨 Dangerous
  
- [ ] Shortened URL: `https://bit.ly/test`
  - Should show: ⚠️ URL shortener detected

## 🚀 Production Readiness (Optional)

For production deployment:

- [ ] Deploy Flask server to cloud service
- [ ] Update `AI_API_URL` to production endpoint
- [ ] Add HTTPS support
- [ ] Implement authentication
- [ ] Add rate limiting
- [ ] Set up monitoring
- [ ] Configure error logging

## 📝 Documentation Review

- [ ] Read [AI_MODEL_SETUP.md](AI_MODEL_SETUP.md)
- [ ] Read [QUICKSTART_AI.md](QUICKSTART_AI.md)
- [ ] Read [backend/README.md](backend/README.md)
- [ ] Read [AI_INTEGRATION_SUMMARY.md](AI_INTEGRATION_SUMMARY.md)

## ✨ Success Criteria

You're done when:

- ✅ Server starts without errors
- ✅ Model loads successfully
- ✅ Test script passes all tests
- ✅ Flutter app connects to server
- ✅ QR scans show AI predictions
- ✅ Confidence scores are displayed
- ✅ Risk scores include AI analysis

---

## 🎉 Congratulations!

If all checkboxes are checked, your AI model integration is complete!

**Next Steps:**
1. Test with various QR codes
2. Share with beta testers
3. Deploy to production (optional)
4. Enjoy enhanced security! 🛡️

---

**Need Help?**
- Check server logs for errors
- Run `python backend/test_api.py`
- Review documentation files
- Check firewall settings
- Verify IP configuration
