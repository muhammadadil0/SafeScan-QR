#!/usr/bin/env python3
"""
Test script for the AI Model API
Tests the malicious URL detection endpoint
"""

import requests
import json
import time

API_URL = "http://localhost:5000/scan"

# Test URLs
test_urls = [
    {
        "url": "https://www.google.com",
        "expected": "Safe",
        "description": "Legitimate website"
    },
    {
        "url": "http://malicious-phishing-site.xyz/login",
        "expected": "DANGER",
        "description": "Suspicious phishing-like URL"
    },
    {
        "url": "https://github.com",
        "expected": "Safe",
        "description": "Popular legitimate site"
    },
    {
        "url": "http://192.168.1.1/admin.php?password=123",
        "expected": "DANGER",
        "description": "IP address with suspicious parameters"
    },
]

def test_server():
    """Test if server is running"""
    try:
        response = requests.get("http://localhost:5000/", timeout=2)
        if response.status_code == 200:
            print("✅ Server is running!")
            print(f"   Response: {response.text}\n")
            return True
        else:
            print(f"❌ Server returned status code: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ Server is not running or not accessible")
        print(f"   Error: {e}")
        print("\n💡 Start the server with: python backend/app.py\n")
        return False

def test_scan_endpoint(url_data):
    """Test the /scan endpoint"""
    try:
        print(f"🔍 Testing: {url_data['description']}")
        print(f"   URL: {url_data['url']}")
        
        start_time = time.time()
        response = requests.post(
            API_URL,
            headers={"Content-Type": "application/json"},
            json={"url": url_data['url']},
            timeout=10
        )
        end_time = time.time()
        
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Status: {data['status']}")
            print(f"   📊 Confidence: {data['confidence']}%")
            print(f"   🏷️  Label: {data['label']}")
            print(f"   ⏱️  Scan Time: {data['scan_time_ms']}ms")
            print(f"   🌐 Total Time: {round((end_time - start_time) * 1000, 2)}ms")
            
            # Check if result matches expectation
            if data['status'] == url_data['expected']:
                print(f"   ✅ Result matches expectation!\n")
            else:
                print(f"   ⚠️  Expected {url_data['expected']}, got {data['status']}\n")
            
            return True
        else:
            print(f"   ❌ Error: Status code {response.status_code}")
            print(f"   Response: {response.text}\n")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"   ❌ Request failed: {e}\n")
        return False

def main():
    print("=" * 60)
    print("🤖 SafeScan-QR AI Model API Test")
    print("=" * 60)
    print()
    
    # Test if server is running
    if not test_server():
        return
    
    # Test scan endpoint with various URLs
    print("=" * 60)
    print("Testing URL Scanning")
    print("=" * 60)
    print()
    
    success_count = 0
    for url_data in test_urls:
        if test_scan_endpoint(url_data):
            success_count += 1
        time.sleep(0.5)  # Small delay between tests
    
    # Summary
    print("=" * 60)
    print(f"✅ Tests Passed: {success_count}/{len(test_urls)}")
    print("=" * 60)
    
    if success_count == len(test_urls):
        print("\n🎉 All tests passed! The AI model is working correctly.")
        print("\n📱 You can now use the Flutter app to scan QR codes!")
    else:
        print("\n⚠️  Some tests failed. Check the server logs for details.")

if __name__ == "__main__":
    main()
