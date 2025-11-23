#!/usr/bin/env python3
"""
Generate Android splash screen images from logo.png
Creates larger splash screen images for better visibility
"""
from PIL import Image
import os

def generate_splash_screens(source_image_path, output_base_dir):
    """Generate splash screen images for Android"""
    # Open the source image
    img = Image.open(source_image_path)
    
    # Convert to RGBA if not already
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    # Define sizes for splash screens (larger than app icons)
    # These will be displayed at the center of the splash screen
    splash_sizes = {
        'drawable-mdpi': 200,      # ~2 inches on mdpi
        'drawable-hdpi': 300,      # ~2 inches on hdpi
        'drawable-xhdpi': 400,     # ~2 inches on xhdpi
        'drawable-xxhdpi': 600,    # ~2 inches on xxhdpi
        'drawable-xxxhdpi': 800,   # ~2 inches on xxxhdpi
    }
    
    for folder, size in splash_sizes.items():
        output_dir = os.path.join(output_base_dir, folder)
        os.makedirs(output_dir, exist_ok=True)
        
        # Resize image
        resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save as PNG
        output_path = os.path.join(output_dir, 'splash_logo.png')
        resized_img.save(output_path, 'PNG')
        print(f"Generated: {output_path} ({size}x{size})")

if __name__ == '__main__':
    source = 'logo.png'
    output_dir = 'android/app/src/main/res'
    
    print(f"Generating Android splash screen images from {source}...")
    generate_splash_screens(source, output_dir)
    print("Done! Splash screen images created.")
