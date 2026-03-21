#!/bin/bash

# WatchNext App Icon 生成腳本
# 修復 16-bit PNG 導致 Xcode 編譯後顏色丟失的問題

set -e

SOURCE_DIR="WatchNext/Assets.xcassets/AppIcon.appiconset"
TEMP_DIR="/tmp/watchnext_icons"

echo "清理暫存目錄..."
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo "生成漸層背景 (1024x1024)..."
magick -size 1448x1448 gradient:'#FFB5B5-#FF6B6B' \
    -rotate -45 \
    -gravity center -extent 1024x1024 \
    "$TEMP_DIR/gradient.png"

echo "生成圓框 (使用 stroke)..."
magick -size 1024x1024 xc:none \
    -stroke white -strokewidth 4 -fill none \
    -draw "circle 512,512 487,25" \
    "$TEMP_DIR/ring_white.png"

echo "用漸層填充圓框..."
magick "$TEMP_DIR/ring_white.png" "$TEMP_DIR/gradient.png" \
    -compose In -composite \
    "$TEMP_DIR/gradient_ring.png"

echo "生成主 icon (1024x1024)..."
magick -size 1024x1024 xc:none \
    "$TEMP_DIR/gradient_ring.png" -compose Over -composite \
    -fill black -font "Avenir-Light" -pointsize 144 -kerning 58 \
    -gravity center -annotate +0-44 "WATCH" \
    -annotate +0+112 "NEXT" \
    "$TEMP_DIR/icon_1024_master.png"

echo "轉換為 8-bit sRGB PNG..."
magick "$TEMP_DIR/icon_1024_master.png" \
    -depth 8 \
    -colorspace sRGB \
    -alpha on \
    "$TEMP_DIR/icon_1024.png"

echo "生成各尺寸 icon (強制 8-bit sRGB)..."
for size in 16 32 64 128 256 512; do
    size2x=$((size * 2))

    # 1x
    magick "$TEMP_DIR/icon_1024.png" \
        -resize ${size}x${size} \
        -depth 8 \
        -colorspace sRGB \
        -alpha on \
        "$TEMP_DIR/icon_${size}x${size}.png"

    # 2x
    magick "$TEMP_DIR/icon_1024.png" \
        -resize ${size2x}x${size2x} \
        -depth 8 \
        -colorspace sRGB \
        -alpha on \
        "$TEMP_DIR/icon_${size}x${size}@2x.png"
done

echo "複製到 Assets.xcassets..."
cp "$TEMP_DIR/icon_16x16.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_16x16@2x.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_32x32.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_32x32@2x.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_128x128.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_128x128@2x.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_256x256.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_256x256@2x.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_512x512.png" "$SOURCE_DIR/"
cp "$TEMP_DIR/icon_512x512@2x.png" "$SOURCE_DIR/"

echo "驗證所有 icon 為 8-bit..."
for file in "$SOURCE_DIR"/icon_*.png; do
    depth=$(identify -format "%z" "$file")
    if [ "$depth" != "8" ]; then
        echo "警告: $file 不是 8-bit (depth=$depth)"
    fi
done

echo "完成！所有 icon 已更新為 8-bit sRGB PNG"
echo "請重新編譯專案以套用變更"
