"""
SafeScan QR - ML Model Training Script
Trains a neural network to classify URLs as safe, phishing, malware, or spam
"""

import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import re
from urllib.parse import urlparse

# URL Feature Extraction
class URLFeatureExtractor:
    def __init__(self):
        self.suspicious_keywords = [
            'login', 'verify', 'account', 'update', 'secure', 'banking',
            'paypal', 'amazon', 'microsoft', 'apple', 'google', 'facebook',
            'password', 'confirm', 'suspended', 'locked', 'urgent', 'click'
        ]
        
    def extract_features(self, url):
        """Extract 30+ features from URL"""
        features = []
        
        try:
            parsed = urlparse(url)
            domain = parsed.netloc
            path = parsed.path
            
            # 1. URL Length
            features.append(len(url))
            
            # 2. Domain Length
            features.append(len(domain))
            
            # 3. Path Length
            features.append(len(path))
            
            # 4. Number of dots
            features.append(url.count('.'))
            
            # 5. Number of hyphens
            features.append(url.count('-'))
            
            # 6. Number of underscores
            features.append(url.count('_'))
            
            # 7. Number of slashes
            features.append(url.count('/'))
            
            # 8. Number of question marks
            features.append(url.count('?'))
            
            # 9. Number of equals
            features.append(url.count('='))
            
            # 10. Number of @ symbols
            features.append(url.count('@'))
            
            # 11. Number of ampersands
            features.append(url.count('&'))
            
            # 12. Number of digits
            features.append(sum(c.isdigit() for c in url))
            
            # 13. Has HTTPS
            features.append(1 if parsed.scheme == 'https' else 0)
            
            # 14. Has IP address
            features.append(1 if re.match(r'\d+\.\d+\.\d+\.\d+', domain) else 0)
            
            # 15. Number of subdomains
            features.append(len(domain.split('.')) - 2 if len(domain.split('.')) > 2 else 0)
            
            # 16. Domain has numbers
            features.append(1 if any(c.isdigit() for c in domain) else 0)
            
            # 17. Suspicious keywords count
            keyword_count = sum(1 for kw in self.suspicious_keywords if kw in url.lower())
            features.append(keyword_count)
            
            # 18. Has port number
            features.append(1 if parsed.port else 0)
            
            # 19. TLD length
            tld = domain.split('.')[-1] if '.' in domain else ''
            features.append(len(tld))
            
            # 20. Has suspicious TLD
            suspicious_tlds = ['.tk', '.ml', '.ga', '.cf', '.gq', '.xyz', '.top']
            features.append(1 if any(domain.endswith(tld) for tld in suspicious_tlds) else 0)
            
            # 21-25. Character entropy (randomness)
            if len(domain) > 0:
                char_freq = {}
                for char in domain:
                    char_freq[char] = char_freq.get(char, 0) + 1
                entropy = -sum((freq/len(domain)) * np.log2(freq/len(domain)) 
                              for freq in char_freq.values())
                features.append(entropy)
            else:
                features.append(0)
            
            # 26. Ratio of digits to letters
            letters = sum(c.isalpha() for c in url)
            digits = sum(c.isdigit() for c in url)
            features.append(digits / (letters + 1))
            
            # 27. Has double slashes in path
            features.append(1 if '//' in path else 0)
            
            # 28. Number of parameters
            features.append(len(parsed.query.split('&')) if parsed.query else 0)
            
            # 29. Has fragment
            features.append(1 if parsed.fragment else 0)
            
            # 30. Vowel to consonant ratio
            vowels = sum(1 for c in domain.lower() if c in 'aeiou')
            consonants = sum(1 for c in domain.lower() if c.isalpha() and c not in 'aeiou')
            features.append(vowels / (consonants + 1))
            
        except Exception as e:
            # Return zeros if parsing fails
            features = [0] * 30
            
        return np.array(features)

def create_model(input_dim=30, num_classes=4):
    """Create neural network model"""
    model = keras.Sequential([
        layers.Input(shape=(input_dim,)),
        layers.Dense(128, activation='relu'),
        layers.Dropout(0.3),
        layers.Dense(64, activation='relu'),
        layers.Dropout(0.2),
        layers.Dense(32, activation='relu'),
        layers.Dense(num_classes, activation='softmax')
    ])
    
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

def train_model():
    """Main training function"""
    print("🚀 SafeScan QR - ML Model Training")
    print("=" * 50)
    
    # Load or create dataset
    print("\n📊 Loading dataset...")
    
    # Sample dataset (in production, use real data)
    sample_urls = [
        # Safe URLs
        ("https://www.google.com", 0),
        ("https://www.github.com", 0),
        ("https://www.stackoverflow.com", 0),
        ("https://www.wikipedia.org", 0),
        ("https://www.amazon.com", 0),
        
        # Phishing URLs
        ("http://paypal-verify.tk/login", 1),
        ("https://secure-banking-update.ml/account", 1),
        ("http://amazon-security.xyz/verify", 1),
        ("https://microsoft-account-locked.ga/unlock", 1),
        
        # Malware URLs
        ("http://192.168.1.1/download.exe", 2),
        ("https://free-software.tk/crack.apk", 2),
        ("http://get-app-now.ml/install.msi", 2),
        
        # Spam URLs
        ("https://click-here-win-prize.xyz", 3),
        ("http://free-money-now.tk/claim", 3),
    ]
    
    # Extract features
    print("🔍 Extracting features...")
    extractor = URLFeatureExtractor()
    
    X = []
    y = []
    
    for url, label in sample_urls:
        features = extractor.extract_features(url)
        X.append(features)
        y.append(label)
    
    X = np.array(X)
    y = np.array(y)
    
    print(f"✅ Dataset shape: {X.shape}")
    print(f"✅ Labels: {len(set(y))} classes")
    
    # Split dataset
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Create and train model
    print("\n🧠 Creating neural network...")
    model = create_model(input_dim=X.shape[1], num_classes=len(set(y)))
    
    print("\n🏋️ Training model...")
    history = model.fit(
        X_train, y_train,
        epochs=50,
        batch_size=4,
        validation_split=0.2,
        verbose=1
    )
    
    # Evaluate
    print("\n📈 Evaluating model...")
    test_loss, test_acc = model.evaluate(X_test, y_test, verbose=0)
    print(f"✅ Test Accuracy: {test_acc * 100:.2f}%")
    
    # Save model
    print("\n💾 Saving model...")
    model.save('url_classifier_model.h5')
    print("✅ Model saved as 'url_classifier_model.h5'")
    
    return model, extractor

if __name__ == "__main__":
    model, extractor = train_model()
    print("\n🎉 Training complete!")
    print("\n📝 Next steps:")
    print("1. Run 'python convert_to_tflite.py' to convert to TFLite")
    print("2. Copy .tflite file to Flutter assets")
    print("3. Use ML model in app for predictions")