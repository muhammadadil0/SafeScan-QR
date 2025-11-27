from flask import Flask, request, jsonify
from flask_cors import CORS
from transformers import pipeline
import time

app = Flask(__name__)
CORS(app)  # This allows your Flutter app to talk to this server

print("⏳ Loading Model... (This might take a minute the first time)")
# We use 'kmack/malicious-url-detection' which is verified to work
classifier = pipeline("text-classification", model="kmack/malicious-url-detection")
print("✅ Model Loaded and Ready!")

@app.route('/', methods=['GET'])
def home():
    return "QR Security Server is Running!"

@app.route('/scan', methods=['POST'])
def scan_url():
    try:
        # 1. Get data from Flutter
        data = request.json
        url_to_check = data.get('url')

        if not url_to_check:
            return jsonify({"error": "No URL provided"}), 400

        print(f"🔎 Scanning: {url_to_check}")

        # 2. Run the AI Model
        start_time = time.time()
        result = classifier(url_to_check)[0]
        end_time = time.time()

        label = result['label']
        score = result['score']
        
        print(f"🧠 AI Output: Label={label}, Score={score}")

        # 3. Format response for Flutter
        # This model returns 'benign' and 'malicious' (lowercase or uppercase)
        label_upper = label.upper()
        is_safe = (label_upper == 'BENIGN' or label_upper == 'SAFE' or label_upper == 'LABEL_0')
        
        response = {
            "url": url_to_check,
            "status": "Safe" if is_safe else "DANGER",
            "is_safe": is_safe,
            "confidence": round(score * 100, 2), # Convert to percentage
            "scan_time_ms": round((end_time - start_time) * 1000, 2),
            "label": label
        }

        return jsonify(response)

    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # host='0.0.0.0' makes the server accessible to other devices (like your phone)
    app.run(host='0.0.0.0', port=5001, debug=True)
