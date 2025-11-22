# 🤖 ML Model Placeholder

## ⚠️ Model Not Yet Generated

The TensorFlow Lite model file (`url_classifier.tflite`) needs to be generated before the ML features will work.

## 📝 Steps to Generate the Model:

### 1. Install Python Dependencies

```bash
cd backend
pip install -r requirements.txt
```

### 2. Train the Model

```bash
cd training
python train_model.py
```

This will:
- Extract 30+ features from URLs
- Train a neural network
- Save the model as `url_classifier_model.h5`

### 3. Convert to TFLite

```bash
python convert_to_tflite.py
```

This will:
- Convert the Keras model to TensorFlow Lite format
- Optimize for mobile devices
- Create `url_classifier.tflite`

### 4. Copy to Flutter Assets

```bash
cp url_classifier.tflite ../../assets/models/
```

### 5. Run Flutter App

```bash
cd ../..
flutter pub get
flutter run
```

## 🎯 Model Features

The model extracts **30 features** from each URL:

1. URL length
2. Domain length
3. Path length
4. Number of special characters (., -, _, /, ?, =, @, &)
5. Number of digits
6. HTTPS flag
7. IP address detection
8. Subdomain count
9. Suspicious keywords
10. Port number
11. TLD analysis
12. Character entropy
13. Digit/letter ratio
14. And more...

## 🏷️ Classification Labels

The model classifies URLs into 4 categories:

- **0: Safe** - Legitimate websites
- **1: Phishing** - Fake login pages, scams
- **2: Malware** - Virus, trojan, malicious files
- **3: Spam** - Advertising, clickbait

## 📊 Model Architecture

```
Input (30 features)
    ↓
Dense Layer (128 neurons, ReLU)
    ↓
Dropout (30%)
    ↓
Dense Layer (64 neurons, ReLU)
    ↓
Dropout (20%)
    ↓
Dense Layer (32 neurons, ReLU)
    ↓
Output (4 classes, Softmax)
```

## 🎓 Training Data

For production use, you should train with a large dataset:

- **Legitimate URLs**: Top websites, verified domains
- **Phishing URLs**: PhishTank, OpenPhish databases
- **Malware URLs**: URLhaus, MalwareURL datasets
- **Spam URLs**: Spam link databases

Recommended dataset size: **10,000+ URLs** per class

## 📈 Expected Performance

With proper training data:
- **Accuracy**: 90-95%
- **Precision**: 85-90%
- **Recall**: 85-90%
- **F1-Score**: 85-90%

## 🚀 Integration in App

Once the model is generated, it will be automatically used by:

1. `MLService` - Loads and runs the model
2. `SecurityService` - Combines ML predictions with rule-based checks
3. `ResultScreen` - Shows ML confidence scores

## 💡 Tips for Better Accuracy

1. **Use Real Data**: Train with actual phishing/malware URLs
2. **Balance Dataset**: Equal samples per class
3. **Feature Engineering**: Add more URL features
4. **Hyperparameter Tuning**: Adjust layers, neurons, dropout
5. **Regular Updates**: Retrain monthly with new threats

---

**Note**: The app will work without the ML model using rule-based detection only. ML adds an extra layer of AI-powered protection.
