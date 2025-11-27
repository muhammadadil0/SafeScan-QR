# 🛡️ SafeScan QR - Professional QR Code Security Scanner

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**Your Personal QR Code Security Guardian**

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Usage](#-usage) • [Tech Stack](#-tech-stack)

</div>

---

## 📱 About

**SafeScan QR** is a professional-grade cybersecurity application that protects users from malicious QR codes, phishing attacks, and malware. Built with Flutter, it provides real-time threat detection, risk scoring, and comprehensive security analysis.

### 🎯 Problem It Solves

QR codes are everywhere, but they can be dangerous:
- **Phishing Attacks** - Fake login pages
- **Malware Distribution** - Malicious APK files
- **URL Shortener Abuse** - Hidden dangerous links
- **Data Theft** - Suspicious parameter injection

SafeScan QR detects all these threats **before** you open the link!

---

## ✨ Features

### 🔍 **Advanced Security Analysis**

- ✅ **URL Shortener Detection** - Identifies 17+ shorteners (bit.ly, tinyurl, etc.)
- ✅ **Malicious File Detection** - Warns about APK, EXE, MSI, DMG files
- ✅ **Suspicious Parameter Scanning** - Finds password, email, token parameters
- ✅ **Phishing Keyword Detection** - 40+ banking/payment keywords
- ✅ **Typosquatting Detection** - Catches fake domains (paypa1, g00gle)
- ✅ **IP Address Detection** - Flags raw IP addresses
- ✅ **HTTPS Verification** - Ensures secure connections
- ✅ **Redirect Detection** - Tracks URL redirects
- ✅ **AI Model Detection** - Machine learning-powered malicious URL detection

### 📊 **Risk Scoring System**

- **0-100 Scale** - Precise risk calculation
- **Color-Coded** - Green (Safe), Yellow (Low), Orange (Medium), Red (High)
- **Circular Visualization** - Beautiful risk score display
- **Detailed Analysis** - Lists all risk factors found

### 📱 **Content Type Detection**

Automatically identifies:
- 🌐 URLs - Web links
- 📶 WiFi - Network credentials
- 📧 Email - mailto: links
- 📞 Phone - tel: numbers
- 💳 Payment - UPI/payment links
- 👤 Contact - vCard format
- 📍 Location - Geo coordinates
- 📝 Text - Plain text

### 🌙 **Dark Mode**

- Beautiful dark theme
- Eye-friendly colors
- Automatic switching
- Persistent preference

### 🌍 **Multi-Language Support**

- 🇬🇧 **English** - Full support
- 🇵🇰 **اردو (Urdu)** - Complete translation
- RTL text support
- 100+ translated strings

### 👶 **Child Mode**

- Simplified interface
- Big, clear warnings
- No technical jargon
- Perfect for schools

### 📜 **History & Statistics**

- Stores up to 100 scans
- Real-time statistics
- Filter by risk level
- Export/Clear options

### 🚩 **Report Feature**

- Report dangerous QR codes
- Add custom reasons
- Local database
- Community awareness

### ✈️ **Offline Mode**

- Works without internet
- All basic checks offline
- Privacy-focused
- Fast analysis

### 🔒 **Safe Browser**

- Sandboxed environment
- Blocks external apps
- Security indicators
- Cache control

---

## 🎨 Screenshots

### Light Mode
- Onboarding with animations
- Login/Signup with glassmorphism
- Dashboard with statistics
- Scanner with flash toggle
- Results with risk score

### Dark Mode
- Beautiful dark theme
- High contrast
- Eye-friendly
- Modern design

---

## 🚀 Installation

### Prerequisites

- Flutter SDK 3.0+
- Android Studio / VS Code
- Android device or emulator

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/safescan-qr.git
cd safescan-qr
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **(Optional) Set up AI Model Server**
```bash
cd backend
pip install flask flask-cors transformers torch
python app.py
```
See [AI_MODEL_SETUP.md](AI_MODEL_SETUP.md) for detailed instructions.

4. **Run the app**
```bash
flutter run
```

---

## 📖 Usage

### 1. **Scan a QR Code**
- Open app → Tap "Scan QR"
- Point camera at QR code
- Wait for analysis
- View risk score and details

### 2. **Upload from Gallery**
- Tap "Upload Image"
- Select QR code image
- Automatic analysis
- View results

### 3. **Check URL Manually**
- Go to "Check URL" tab
- Enter any URL
- Tap "Analyze"
- See security report

### 4. **View History**
- Settings → Scan History
- See all previous scans
- Filter by risk level
- Clear if needed

### 5. **Change Settings**
- Toggle Dark Mode
- Select Language (English/Urdu)
- Enable Child Mode
- Customize preferences

---

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language

### Packages
- `mobile_scanner` - QR code scanning
- `image_picker` - Gallery image selection
- `webview_flutter` - Safe browser
- `http` - Network requests
- `provider` - State management
- `shared_preferences` - Local storage
- `google_fonts` - Typography

### Architecture
- **Provider Pattern** - State management
- **Service Layer** - Business logic
- **Repository Pattern** - Data access
- **Clean Architecture** - Separation of concerns

---

## 📊 Security Checks

| Check | Description | Risk Points |
|-------|-------------|-------------|
| URL Shortener | Detects shortened URLs | +25 |
| Malicious File | APK, EXE, etc. | +40 |
| Suspicious Params | password, token, etc. | +20 |
| IP Address | Raw IP instead of domain | +30 |
| No HTTPS | Insecure connection | +20 |
| Phishing Keywords | Banking terms | +25 |
| Typosquatting | Fake domains | +35 |
| Long Domain | Extremely long names | +10 |
| Non-standard Port | Unusual ports | +15 |
| AI Model | ML-powered detection | +40 |

**Total Risk Score:** Sum of all points (0-100)

---

## 🎯 Use Cases

### 🏫 **Education**
- School cybersecurity training
- Digital literacy programs
- Student awareness campaigns

### 👨‍👩‍👧 **Family**
- Protect children from scams
- Teach safe QR usage
- Parental control

### 💼 **Business**
- Employee security training
- Verify payment QR codes
- Prevent phishing attacks

### 🏛️ **Public Awareness**
- Community safety programs
- Government initiatives
- NGO campaigns

---

## 🌟 Highlights

### **Why SafeScan QR is Special:**

1. **Comprehensive** - 15+ security checks
2. **Accurate** - Precise 0-100 risk scoring
3. **Fast** - Instant offline analysis
4. **Beautiful** - Premium UI/UX design
5. **Accessible** - Multi-language, dark mode
6. **Educational** - Child mode for learning
7. **Private** - No data collection
8. **Professional** - Portfolio-quality code

---

## 📈 Statistics

- **15+** Security checks
- **100** Risk score scale
- **9** Content types detected
- **17+** URL shorteners identified
- **40+** Phishing keywords
- **100** Scan history capacity
- **2** Languages supported
- **3** UI modes (Normal, Dark, Child)

---

## 🔮 Future Enhancements

- [ ] Website preview screenshots
- [x] AI/ML risk prediction ✅ **COMPLETED**
- [ ] More languages (Arabic, Pashto)
- [ ] Cloud sync
- [ ] QR code generator
- [ ] Batch scanning
- [ ] Export reports (PDF)
- [ ] Browser extension

---

## 👨‍💻 Developer

**Muhammad Adil | Muhammad Kaif**
- Portfolio: [yourwebsite.com](https://yourwebsite.com)
- LinkedIn: [linkedin.com/in/yourprofile](https://linkedin.com/in/yourprofile)
- GitHub: [@yourusername](https://github.com/yourusername)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Open-source community
- Security researchers
- Beta testers

---

## 📞 Support

- **Email:** adilraxiq64@gmail.com | muhammadkaifnu@gmail.com
- **Issues:** [GitHub Issues](https://github.com/yourusername/safescan-qr/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/safescan-qr/discussions)

---

<div align="center">

**Made with ❤️ and Flutter**

**SafeScan QR** - Protecting users, one scan at a time 🛡️

[⬆ Back to Top](#-safescan-qr---professional-qr-code-security-scanner)

</div>
