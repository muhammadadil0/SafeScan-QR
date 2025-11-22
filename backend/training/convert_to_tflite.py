"""
Convert trained Keras model to TensorFlow Lite format
For use in Flutter mobile app
"""

import tensorflow as tf
import numpy as np

def convert_to_tflite():
    """Convert Keras model to TFLite"""
    print("🔄 Converting model to TensorFlow Lite...")
    print("=" * 50)
    
    # Load the trained model
    print("\n📂 Loading Keras model...")
    try:
        model = tf.keras.models.load_model('url_classifier_model.h5')
        print("✅ Model loaded successfully")
    except Exception as e:
        print(f"❌ Error loading model: {e}")
        print("\n💡 Please run 'python train_model.py' first to create the model")
        return
    
    # Print model summary
    print("\n📊 Model Summary:")
    model.summary()
    
    # Convert to TFLite
    print("\n🔧 Converting to TFLite format...")
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Optimization (optional - makes model smaller)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Convert
    tflite_model = converter.convert()
    
    # Save the model
    tflite_filename = 'url_classifier.tflite'
    print(f"\n💾 Saving TFLite model as '{tflite_filename}'...")
    with open(tflite_filename, 'wb') as f:
        f.write(tflite_model)
    
    # Get file size
    import os
    file_size = os.path.getsize(tflite_filename)
    print(f"✅ Model saved successfully!")
    print(f"📦 File size: {file_size / 1024:.2f} KB")
    
    # Test the TFLite model
    print("\n🧪 Testing TFLite model...")
    test_tflite_model(tflite_filename)
    
    print("\n" + "=" * 50)
    print("🎉 Conversion complete!")
    print("\n📝 Next steps:")
    print("1. Copy 'url_classifier.tflite' to Flutter project:")
    print("   → assets/models/url_classifier.tflite")
    print("2. Update pubspec.yaml to include the asset")
    print("3. Use tflite_flutter package in Flutter")

def test_tflite_model(model_path):
    """Test the TFLite model with sample input"""
    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"Input shape: {input_details[0]['shape']}")
    print(f"Output shape: {output_details[0]['shape']}")
    
    # Get the expected number of features from the model
    expected_features = input_details[0]['shape'][1]
    print(f"Expected features: {expected_features}")
    
    # Create sample input matching the model's expected features
    sample_input = np.array([[
        50, 15, 10, 2, 1, 0, 3, 0, 0, 0, 0, 5,  # Basic counts (12)
        1, 0, 1, 0, 2, 0, 3, 0,  # Flags (8)
        2.5, 0.1, 0, 2, 0, 0.3  # Ratios and entropy (6)
    ]], dtype=np.float32)  # Total: 26 features
    
    # Run inference
    interpreter.set_tensor(input_details[0]['index'], sample_input)
    interpreter.invoke()
    output = interpreter.get_tensor(output_details[0]['index'])
    
    # Print results
    class_names = ['Safe', 'Phishing', 'Malware', 'Spam']
    predicted_class = np.argmax(output[0])
    confidence = output[0][predicted_class] * 100
    
    print(f"\n🎯 Test Prediction:")
    print(f"   Class: {class_names[predicted_class]}")
    print(f"   Confidence: {confidence:.2f}%")
    print(f"   All probabilities: {output[0]}")

if __name__ == "__main__":
    convert_to_tflite()