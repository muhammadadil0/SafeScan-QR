# SafeScan-QR Backend - AI Model Server

This directory contains the Flask API server that provides AI-powered malicious URL detection for the SafeScan-QR app.

## 📁 Files

- **`app.py`** - Main Flask server with AI model integration
- **`requirements.txt`** - Python dependencies
- **`start_server.sh`** - Convenient startup script (Mac/Linux)
- **`test_api.py`** - API testing script

## 🚀 Quick Start

### Option 1: Using the startup script (Recommended)

```bash
./start_server.sh
```

### Option 2: Manual setup

```bash
# Install dependencies
pip install flask flask-cors transformers torch

# Start the server
python app.py
```

## 🧪 Testing

After starting the server, run the test script:

```bash
python test_api.py
```

This will verify that the AI model is working correctly.

## 🔧 Configuration

### Change the port

Edit `app.py` and modify the last line:

```python
app.run(host='0.0.0.0', port=5000, debug=True)  # Change 5000 to your desired port
```

### Use GPU acceleration (if available)

The model will automatically use GPU if PyTorch detects CUDA. To force CPU:

```python
classifier = pipeline("text-classification", model="Eason918/malicious-url-detector", device=-1)
```

## 📊 API Endpoints

### `GET /`
Health check endpoint

**Response:**
```
QR Security Server is Running!
```

### `POST /scan`
Scan a URL for malicious content

**Request:**
```json
{
  "url": "https://example.com"
}
```

**Response:**
```json
{
  "url": "https://example.com",
  "status": "Safe",
  "is_safe": true,
  "confidence": 95.67,
  "scan_time_ms": 123.45,
  "label": "benign"
}
```

## 🤖 AI Model

- **Name:** Eason918/malicious-url-detector
- **Base:** DistilBERT
- **Task:** Binary text classification (benign/malicious)
- **Size:** ~500MB (downloaded on first run)
- **Speed:** 100-500ms per URL

## 🔒 Security Notes

⚠️ **This is a development server.** For production use:

1. Use a production WSGI server (gunicorn, uWSGI)
2. Add authentication/API keys
3. Implement rate limiting
4. Use HTTPS
5. Add input validation and sanitization

## 📝 Logs

The server logs all scan requests:

```
🔎 Scanning: https://example.com
🤖 AI Result: Safe (95.67% confidence)
```

## 🐛 Troubleshooting

### Port already in use
```bash
# Find and kill the process using port 5000
lsof -ti:5000 | xargs kill -9
```

### Model download fails
- Check internet connection
- Try: `pip install --upgrade transformers`
- Manually download model: `python -c "from transformers import pipeline; pipeline('text-classification', model='Eason918/malicious-url-detector')"`

### Import errors
```bash
pip install --upgrade flask flask-cors transformers torch
```

## 📚 Dependencies

See `requirements.txt` for full list. Main dependencies:

- **Flask** - Web framework
- **Flask-CORS** - Cross-origin resource sharing
- **Transformers** - Hugging Face model library
- **PyTorch** - Deep learning framework

## 🌐 Network Configuration

### For Android Emulator
The emulator can access your localhost via `10.0.2.2`

### For Real Devices
1. Find your PC's IP: `ifconfig` (Mac/Linux) or `ipconfig` (Windows)
2. Ensure phone and PC are on same Wi-Fi
3. Update Flutter app with your IP address

### Firewall
Make sure port 5000 is allowed in your firewall settings.

---

**Made with ❤️ for SafeScan-QR**
