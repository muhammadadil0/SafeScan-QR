# ✅ AI Integration in URL Checker Tab

The AI Malicious URL Detection model has been successfully integrated into the **URL Checker** tab.

## 📱 What's New

1.  **Visual Indicator**: Added a **"Powered by AI Malicious URL Detection"** badge to the URL Checker tab.
2.  **Consistent Protection**: The same powerful AI model that scans QR codes now also analyzes manually entered URLs.
3.  **Home Screen Update**: Added an **"AI Security Enabled"** badge to the manual entry dialog on the Home screen as well.

## 🔒 How it Works

When you enter a URL in the "Check" tab:
1.  The app sends the URL to the local AI server (`http://10.0.2.2:5001/scan`).
2.  The **kmack/malicious-url-detection** model analyzes the URL.
3.  It returns a safety score and confidence level.
4.  You see the full result screen with the AI prediction (e.g., "🤖 AI detected: Malicious").

## 🚀 Try It Out

1.  Go to the **Check** tab in the bottom navigation bar.
2.  You'll see the new **"Powered by AI"** badge.
3.  Type a URL (e.g., `google.com` or `malware.wicar.org/data/eicar.com`).
4.  Tap **Analyze URL**.
5.  View the AI-powered results!
