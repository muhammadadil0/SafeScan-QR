# 🚀 Deploy AI Model to PythonAnywhere - Complete Guide

## What is PythonAnywhere?

PythonAnywhere is a free cloud hosting service for Python apps. Perfect for hosting your AI backend so your mobile app can access it from anywhere!

**Benefits:**
- ✅ Free tier available
- ✅ Always online (24/7)
- ✅ No credit card required
- ✅ Easy to set up
- ✅ HTTPS included

---

## Step 1: Create PythonAnywhere Account

1. Go to: https://www.pythonanywhere.com/
2. Click **"Start running Python online in less than a minute!"**
3. Click **"Create a Beginner account"** (Free)
4. Fill in:
   - Username (e.g., `safescanqr`)
   - Email
   - Password
5. Verify your email

---

## Step 2: Upload Your Backend Code

### Option A: Using Git (Recommended)

1. **Open PythonAnywhere Console:**
   - Dashboard → Consoles → Bash

2. **Clone your repository:**
   ```bash
   git clone https://github.com/muhammadadil0/SafeScan-QR.git
   cd SafeScan-QR/backend
   ```

### Option B: Manual Upload

1. **Go to Files tab**
2. **Create folder:** `SafeScan-QR/backend`
3. **Upload files:**
   - `app.py`
   - `requirements.txt`

---

## Step 3: Install Dependencies

1. **Open Bash Console**

2. **Create virtual environment:**
   ```bash
   cd SafeScan-QR/backend
   python3.10 -m venv venv
   source venv/bin/activate
   ```

3. **Install packages:**
   ```bash
   pip install flask flask-cors transformers torch
   ```

   **Note:** This will take 5-10 minutes (large AI model)

---

## Step 4: Modify app.py for PythonAnywhere

Create a new file `pythonanywhere_app.py`:

```python
from flask import Flask, request, jsonify
from flask_cors import CORS
from transformers import pipeline
import time

app = Flask(__name__)
CORS(app)

print("⏳ Loading Model...")
classifier = pipeline("text-classification", model="kmack/malicious-url-detection")
print("✅ Model Loaded!")

@app.route('/', methods=['GET'])
def home():
    return "SafeScan QR AI Server is Running!"

@app.route('/scan', methods=['POST'])
def scan_url():
    try:
        data = request.json
        url_to_check = data.get('url')

        if not url_to_check:
            return jsonify({"error": "No URL provided"}), 400

        start_time = time.time()
        result = classifier(url_to_check)[0]
        end_time = time.time()

        label = result['label']
        score = result['score']
        
        label_upper = label.upper()
        is_safe = (label_upper == 'BENIGN' or label_upper == 'SAFE' or label_upper == 'LABEL_0')
        
        response = {
            "url": url_to_check,
            "status": "Safe" if is_safe else "DANGER",
            "is_safe": is_safe,
            "confidence": round(score * 100, 2),
            "scan_time_ms": round((end_time - start_time) * 1000, 2),
            "label": label
        }

        return jsonify(response)

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# PythonAnywhere WSGI configuration
application = app
```

---

## Step 5: Configure Web App

1. **Go to Web tab**
2. **Click "Add a new web app"**
3. **Choose:**
   - Manual configuration
   - Python 3.10

4. **Configure WSGI file:**
   - Click on WSGI configuration file link
   - Replace content with:

```python
import sys
import os

# Add your project directory to the sys.path
project_home = '/home/YOUR_USERNAME/SafeScan-QR/backend'
if project_home not in sys.path:
    sys.path = [project_home] + sys.path

# Activate virtual environment
activate_this = os.path.join(project_home, 'venv/bin/activate_this.py')
with open(activate_this) as file_:
    exec(file_.read(), dict(__file__=activate_this))

# Import Flask app
from pythonanywhere_app import application
```

**Replace `YOUR_USERNAME` with your PythonAnywhere username!**

5. **Set Virtual Environment:**
   - In Web tab, find "Virtualenv" section
   - Enter: `/home/YOUR_USERNAME/SafeScan-QR/backend/venv`

6. **Click "Reload" button**

---

## Step 6: Test Your Deployment

### Test in Browser:
```
https://YOUR_USERNAME.pythonanywhere.com/
```

Should show: "SafeScan QR AI Server is Running!"

### Test API:
```bash
curl -X POST https://YOUR_USERNAME.pythonanywhere.com/scan \
  -H "Content-Type: application/json" \
  -d '{"url":"https://google.com"}'
```

---

## Step 7: Update Flutter App

Update the API URL in your Flutter app:

**File:** `lib/services/security_service.dart`

```dart
// OLD (Local):
static const String AI_API_URL = "http://10.0.2.2:5001/scan";

// NEW (PythonAnywhere):
static const String AI_API_URL = "https://YOUR_USERNAME.pythonanywhere.com/scan";
```

**Replace `YOUR_USERNAME` with your actual PythonAnywhere username!**

---

## Step 8: Rebuild and Test Mobile App

1. **Update the code**
2. **Rebuild app:**
   ```bash
   flutter run
   ```

3. **Test scanning a QR code**
4. **Check if AI results appear!**

---

## Troubleshooting

### Problem: Model takes too long to load

**Solution:** PythonAnywhere free tier has limited resources. The model loads on first request (takes 1-2 minutes).

### Problem: "Error 504 Gateway Timeout"

**Solution:** 
1. Increase timeout in Flutter app
2. Or use a smaller model

### Problem: "ModuleNotFoundError"

**Solution:**
```bash
cd SafeScan-QR/backend
source venv/bin/activate
pip install flask flask-cors transformers torch
```

### Problem: App shows "Offline Analysis"

**Solution:**
1. Check URL is correct (https://YOUR_USERNAME.pythonanywhere.com/scan)
2. Test URL in browser first
3. Check PythonAnywhere error logs (Web tab → Error log)

---

## Free Tier Limitations

**PythonAnywhere Free Account:**
- ✅ 512MB disk space
- ✅ 1 web app
- ✅ HTTPS included
- ⚠️ CPU time: 100 seconds/day
- ⚠️ Model loads on first request (slow)
- ⚠️ App sleeps after 3 months inactivity

**Workaround for CPU limit:**
- Use caching
- Optimize model loading
- Upgrade to paid plan ($5/month) for unlimited CPU

---

## Alternative: Use Hugging Face Inference API (Easier!)

If PythonAnywhere is too slow, use Hugging Face's free API:

### Step 1: Get API Token
1. Go to: https://huggingface.co/
2. Sign up (free)
3. Go to Settings → Access Tokens
4. Create new token

### Step 2: Update Flutter App

```dart
Future<Map<String, dynamic>?> _callAIModel(String url) async {
  try {
    final response = await http.post(
      Uri.parse('https://api-inference.huggingface.co/models/kmack/malicious-url-detection'),
      headers: {
        "Authorization": "Bearer YOUR_HF_TOKEN_HERE",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"inputs": url}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final result = data[0][0]; // First prediction
      
      return {
        'is_safe': result['label'].toUpperCase() == 'BENIGN',
        'confidence': (result['score'] * 100).toDouble(),
        'label': result['label'],
        'status': result['label'].toUpperCase() == 'BENIGN' ? 'Safe' : 'DANGER',
        'scan_time_ms': 0,
      };
    }
    return null;
  } catch (e) {
    print('HF API Error: $e');
    return null;
  }
}
```

**Benefits:**
- ✅ No server setup needed
- ✅ Fast and reliable
- ✅ Free tier: 30,000 requests/month
- ✅ Always online

---

## Recommended Approach

### For Testing:
Use **Hugging Face API** (easiest, fastest)

### For Production:
Deploy to **PythonAnywhere** or upgrade to paid hosting

### For Best Performance:
Use **AWS Lambda** or **Google Cloud Run** (requires credit card)

---

## Quick Start Commands

```bash
# 1. SSH into PythonAnywhere
# (Use web console)

# 2. Clone repo
git clone https://github.com/muhammadadil0/SafeScan-QR.git
cd SafeScan-QR/backend

# 3. Setup environment
python3.10 -m venv venv
source venv/bin/activate

# 4. Install dependencies
pip install flask flask-cors transformers torch

# 5. Test locally
python pythonanywhere_app.py

# 6. Configure web app (use Web tab)

# 7. Reload and test!
```

---

## Your Deployment Checklist

- [ ] Create PythonAnywhere account
- [ ] Upload backend code
- [ ] Install dependencies
- [ ] Create pythonanywhere_app.py
- [ ] Configure WSGI file
- [ ] Set virtual environment path
- [ ] Reload web app
- [ ] Test in browser
- [ ] Update Flutter app URL
- [ ] Rebuild mobile app
- [ ] Test QR scanning with AI!

---

## Support

**PythonAnywhere Help:**
- Forum: https://www.pythonanywhere.com/forums/
- Help: https://help.pythonanywhere.com/

**Hugging Face Help:**
- Docs: https://huggingface.co/docs/api-inference/

---

**Your API URL will be:**
```
https://YOUR_USERNAME.pythonanywhere.com/scan
```

**Good luck with deployment! 🚀**
