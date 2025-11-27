from transformers import pipeline

try:
    classifier = pipeline("text-classification", model="kmack/malicious-url-detection")
    print("✅ Model found!")
    print(classifier("http://google.com"))
except Exception as e:
    print(f"❌ Error: {e}")
