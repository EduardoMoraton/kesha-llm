#!/bin/sh
# Builds dist/kesha-llm_<version>_arm64.deb for the Cardputer Zero app store layout.
# Needs: curl, tar, python3 with pip, dpkg-deb (run it on the device or any Debian box).
set -eu
cd "$(dirname "$0")"

VERSION=1.4.0
LLAMA_BUILD=b12319   # prebuilt llama.cpp release (ships an armv8.0 CPU backend the CM0 can run)
ORT=1.31.1           # official onnxruntime wheel; Debian's python3-onnxruntime dies with SIGILL on the CM0's Cortex-A53
MAINTAINER=${MAINTAINER:-"Eduardo Moraton <moraton.eduardo@gmail.com>"}

PKG=build/pkg
APP=$PKG/opt/kesha-llm
LAUNCH=$PKG/usr/share/APPLaunch
rm -rf "$PKG"
mkdir -p "$APP/llama" "$PKG/usr/bin" "$LAUNCH/applications" "$LAUNCH/share/images" "$PKG/DEBIAN" dist

TARBALL=build/llama-$LLAMA_BUILD.tar.gz
[ -f "$TARBALL" ] || curl -fL -o "$TARBALL" \
    "https://github.com/ggml-org/llama.cpp/releases/download/$LLAMA_BUILD/llama-$LLAMA_BUILD-bin-ubuntu-arm64.tar.gz"
# Only the server and the libraries it loads; the other tools would add ~10 MB for nothing.
tar xzf "$TARBALL" -C "$APP/llama" --strip-components=1 --wildcards \
    '*/llama-server' '*/libllama-server-impl.so' '*/libllama-common.so*' '*/libllama.so*' \
    '*/libmtmd.so*' '*/libggml*' '*/LICENSE'

WHEEL=build/onnxruntime-$ORT-cp313-cp313-manylinux_2_28_aarch64.whl
[ -f "$WHEEL" ] || python3 -m pip download "onnxruntime==$ORT" --no-deps --only-binary=:all: \
    --platform manylinux_2_28_aarch64 --python-version 313 -d build
rm -rf build/ort && python3 -m zipfile -e "$WHEEL" build/ort
mkdir -p "$APP/vendor/onnxruntime"
for part in __init__.py LICENSE ThirdPartyNotices.txt capi backend; do
    cp -r "build/ort/onnxruntime/$part" "$APP/vendor/onnxruntime/"
done
rm "$APP"/vendor/onnxruntime/capi/libonnxruntime.so.*   # C API copy (25 MB); the Python module does not load it

install -m 755 kesha-llm "$APP/kesha-llm"
install -m 644 icon.png yolox_nano.onnx device.txt "$APP/"
ln -s /opt/kesha-llm/kesha-llm "$PKG/usr/bin/kesha-llm"
install -m 644 icon.png "$LAUNCH/share/images/kesha-llm.png"
cat > "$LAUNCH/applications/kesha-llm.desktop" <<EOF
[Desktop Entry]
Name=Kesha Code LLM
Comment=Tiny local AI that writes and runs scripts, plus chat and camera
Exec=/usr/bin/kesha-llm
Terminal=false
Icon=share/images/kesha-llm.png
Type=Application
EOF
cat > "$PKG/DEBIAN/control" <<EOF
Package: kesha-llm
Version: $VERSION
Architecture: arm64
Maintainer: $MAINTAINER
Section: utils
Priority: optional
Depends: python3 (>= 3.13), python3 (<< 3.14), python3-pygame, python3-numpy, python3-picamera2, ffmpeg, tesseract-ocr, fonts-dejavu-core, libc6 (>= 2.38), libstdc++6, libgomp1, libssl3t64 | libssl3, zlib1g, libzstd1
Recommends: tesseract-ocr-spa
Description: Kesha Code LLM - tiny local AI for the M5Stack Cardputer Zero
 A tiny local model writes shell and Python scripts you review and run,
 with a per-project file manager, chat and console, and built-in skills
 for common tasks (wifi, web server, Python snippets). Pick the model per
 task: a 90M for speed, a 350M for better code, or a 0.5B coder; Power mode
 frees RAM (camera off) so the bigger ones fit. Also chat offline and run
 live camera object detection (YOLOX) with text recognition.
EOF

DEB=dist/kesha-llm_${VERSION}_arm64.deb
dpkg-deb --root-owner-group --build "$PKG" "$DEB"
ls -lh "$DEB"
