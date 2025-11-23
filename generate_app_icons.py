#!/usr/bin/env python3
"""
Generate Android launcher icons from logo.png
"""
from PIL import Image
import os

# Define the sizes for different Android densities
ICON_SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

def generate_icons(source_image_path, output_base_dir):
    """Generate launcher icons for Android"""
    # Open the source image
    img = Image.open(source_image_path)
    
    # Convert to RGBA if not already
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    # Generate icons for each density
    for folder, size in ICON_SIZES.items():
        output_dir = os.path.join(output_base_dir, folder)
        os.makedirs(output_dir, exist_ok=True)
        
        # Resize image
        resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save as PNG
        output_path = os.path.join(output_dir, 'ic_launcher.png')
        resized_img.save(output_path, 'PNG')
        print(f"Generated: {output_path} ({size}x{size})")

if __name__ == '__main__':
    source = 'logo.png'
    output_dir = 'android/app/src/main/res'
    
    print(f"Generating Android launcher icons from {source}...")
    generate_icons(source, output_dir)
    print("Done!")
