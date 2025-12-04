"""
SafeScan QR - AI Backend for PythonAnywhere
Optimized for cloud deployment
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from transformers import pipeline
import time
import os

app = Flask(__name__)
CORS(app)  # Allow requests from mobile app

# Global variable to store classifier
classifier = None

def load_model():
    """Load the AI model (called on first request)"""
    global classifier
    if classifier is None:
        print("⏳ Loading AI Model... (This may take 1-2 minutes)")
        try:
            classifier = pipeline(
                "text-classification",
                model="kmack/malicious-url-detection",
                device=-1  # Force CPU (PythonAnywhere doesn't have GPU)
            )
            print("✅ Model Loaded Successfully!")
        except Exception as e:
            print(f"❌ Error loading model: {e}")
            raise
    return classifier

@app.route('/', methods=['GET'])
def home():
    """Health check endpoint"""
    return jsonify({
        "status": "online",
        "message": "SafeScan QR AI Server is Running!",
        "version": "1.0",
        "model": "kmack/malicious-url-detection"
    })

@app.route('/health', methods=['GET'])
def health():
    """Detailed health check"""
    return jsonify({
        "status": "healthy",
        "model_loaded": classifier is not None,
        "timestamp": time.time()
    })

@app.route('/scan', methods=['POST'])
def scan_url():
    """
    Scan URL for malicious content
    
    Request body:
    {
        "url": "https://example.com"
    }
    
    Response:
    {
        "url": "https://example.com",
        "status": "Safe" or "DANGER",
        "is_safe": true/false,
        "confidence": 99.97,
        "scan_time_ms": 123.45,
        "label": "BENIGN" or "MALWARE"
    }
    """
    try:
        # Get URL from request
        data = request.json
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
            
        url_to_check = data.get('url')
        if not url_to_check:
            return jsonify({"error": "No URL provided"}), 400

        print(f"🔎 Scanning: {url_to_check}")

        # Load model if not loaded
        model = load_model()

        # Run AI analysis
        start_time = time.time()
        result = model(url_to_check)[0]
        end_time = time.time()

        # Parse result
        label = result['label']
        score = result['score']
        
        print(f"🧠 AI Output: Label={label}, Score={score}")

        # Determine if safe
        label_upper = label.upper()
        is_safe = (label_upper == 'BENIGN' or 
                  label_upper == 'SAFE' or 
                  label_upper == 'LABEL_0')
        
        # Format response
        response = {
            "url": url_to_check,
            "status": "Safe" if is_safe else "DANGER",
            "is_safe": is_safe,
            "confidence": round(score * 100, 2),
            "scan_time_ms": round((end_time - start_time) * 1000, 2),
            "label": label
        }

        return jsonify(response), 200

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({
            "error": str(e),
            "message": "Failed to analyze URL"
        }), 500

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Endpoint not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({"error": "Internal server error"}), 500

# WSGI application for PythonAnywhere
application = app

if __name__ == '__main__':
    # For local testing only
    print("🚀 Starting SafeScan QR AI Server...")
    print("📍 Server will be available at: http://127.0.0.1:5000")
    app.run(host='0.0.0.0', port=5000, debug=False)
