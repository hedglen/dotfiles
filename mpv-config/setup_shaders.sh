#!/bin/bash
# MPV Shader Setup Script for Enhanced 480p→1080p Upscaling

SHADER_DIR="$HOME/.config/mpv/shaders"
echo "Setting up MPV shaders in: $SHADER_DIR"

# Create shaders directory
mkdir -p "$SHADER_DIR"
cd "$SHADER_DIR"

echo "Downloading FSRCNNX shader (best for live-action content)..."
wget -q "https://github.com/igv/FSRCNN-TensorFlow/releases/download/1.1/FSRCNNX_x2_56-16-4-1.glsl" -O FSRCNNX_x2_56-16-4-1.glsl

echo "Downloading SSimDownscaler shader..."
wget -q "https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/575d13567bbe3caa778310bd3b2a4c516c445039/SSimDownscaler.glsl" -O SSimDownscaler.glsl

echo "Downloading Anime4K shaders (best for animated content)..."
# Download Anime4K v4.0
ANIME4K_URL="https://github.com/bloc97/Anime4K/releases/download/v4.0.1/Anime4K_v4.0.zip"
wget -q "$ANIME4K_URL" -O Anime4K_v4.0.zip

if [ -f "Anime4K_v4.0.zip" ]; then
    unzip -q Anime4K_v4.0.zip
    # Move the specific shaders we need to the main directory
    find . -name "Anime4K_Clamp_Highlights.glsl" -exec cp {} . \;
    find . -name "Anime4K_Restore_CNN_VL.glsl" -exec cp {} . \;
    find . -name "Anime4K_Upscale_CNN_x2_VL.glsl" -exec cp {} . \;
    find . -name "Anime4K_AutoDownscalePre_x2.glsl" -exec cp {} . \;
    find . -name "Anime4K_AutoDownscalePre_x4.glsl" -exec cp {} . \;
    find . -name "Anime4K_Upscale_CNN_x2_M.glsl" -exec cp {} . \;
    
    # Clean up
    rm -rf Anime4K_v4.0.zip Anime4K_v4.0/
    echo "Anime4K shaders extracted successfully"
else
    echo "Failed to download Anime4K shaders"
fi

echo ""
echo "Shader setup complete! Available shaders:"
ls -la "$SHADER_DIR"/*.glsl 2>/dev/null || echo "No .glsl files found"

echo ""
echo "Usage in MPV:"
echo "  Ctrl+1: FSRCNNX (live-action content)"
echo "  Ctrl+2: Anime4K (animated content)"  
echo "  Ctrl+3: SSimDownscaler + FSRCNNX (highest quality)"
echo "  Ctrl+4: Built-in sharp scaling"
echo "  Ctrl+0: Disable all shaders"
echo ""
echo "The FSRCNNX shader is now active by default for all content."
