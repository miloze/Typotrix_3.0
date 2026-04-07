#!/bin/bash
# setup_fonts.sh — download variable fonts to the Pi
# Verifies each file is a valid TTF before keeping it

FONT_DIR="/home/milo/fonts"
mkdir -p "$FONT_DIR"

is_valid_ttf() {
  python3 -c "
import sys
with open('$1', 'rb') as f:
    magic = f.read(4)
sys.exit(0 if magic in [b'\\x00\\x01\\x00\\x00', b'true', b'OTTO', b'wOFF', b'wOF2'] else 1)
" 2>/dev/null
}

download() {
  local name="$1"
  local url="$2"
  local dest="$FONT_DIR/$name"

  if [ -f "$dest" ] && is_valid_ttf "$dest"; then
    echo "  ok (cached): $name"
    return
  fi

  echo "  downloading: $name"
  curl -sL --max-time 30 "$url" -o "$dest"

  if is_valid_ttf "$dest"; then
    echo "  ok"
  else
    echo "  FAILED (invalid file): $name — deleting"
    rm -f "$dest"
  fi
}

echo "Downloading variable fonts to $FONT_DIR..."

# Fonts with wdth + wght axes
download "RobotoFlex.ttf"      "https://github.com/google/fonts/raw/main/ofl/robotoflex/RobotoFlex%5BGRAD%2CXTRA%2CopsZ%2CslNT%2Cwdth%2Cwght%2CxPRN%2CyOPQ%2CyTAS%2CyTDE%2CyTFI%2CyTLC%2CyTUC%2CyTlc%2CyTuc%5D.ttf"
download "EncodeSans.ttf"      "https://github.com/google/fonts/raw/main/ofl/encodesans/EncodeSans%5Bwdth%2Cwght%5D.ttf"
download "Anybody.ttf"         "https://github.com/google/fonts/raw/main/ofl/anybody/Anybody%5Bwdth%2Cwght%5D.ttf"
download "Cabin.ttf"           "https://github.com/google/fonts/raw/main/ofl/cabin/Cabin%5Bwdth%2Cwght%5D.ttf"

# Weight-only variable fonts
download "Raleway.ttf"         "https://github.com/google/fonts/raw/main/ofl/raleway/Raleway%5Bwght%5D.ttf"
download "Nunito.ttf"          "https://github.com/google/fonts/raw/main/ofl/nunito/Nunito%5Bwght%5D.ttf"
download "Manrope.ttf"         "https://github.com/google/fonts/raw/main/ofl/manrope/Manrope%5Bwght%5D.ttf"
download "DMSans.ttf"          "https://github.com/google/fonts/raw/main/ofl/dmsans/DMSans%5Bopsz%2Cwght%5D.ttf"
download "Inter.ttf"           "https://github.com/google/fonts/raw/main/ofl/inter/Inter%5Bopsz%2Cwght%5D.ttf"
download "Jost.ttf"            "https://github.com/google/fonts/raw/main/ofl/jost/Jost%5Bwght%5D.ttf"
download "Fraunces.ttf"        "https://github.com/google/fonts/raw/main/ofl/fraunces/Fraunces%5Bopsz%2Cwght%5D.ttf"
download "Syne.ttf"            "https://github.com/google/fonts/raw/main/ofl/syne/Syne%5Bwght%5D.ttf"
download "Outfit.ttf"          "https://github.com/google/fonts/raw/main/ofl/outfit/Outfit%5Bwght%5D.ttf"
download "Urbanist.ttf"        "https://github.com/google/fonts/raw/main/ofl/urbanist/Urbanist%5Bwght%5D.ttf"
download "PlusJakartaSans.ttf" "https://github.com/google/fonts/raw/main/ofl/plusjakartasans/PlusJakartaSans%5Bwght%5D.ttf"
download "Figtree.ttf"         "https://github.com/google/fonts/raw/main/ofl/figtree/Figtree%5Bwght%5D.ttf"
download "Recursive.ttf"       "https://github.com/google/fonts/raw/main/ofl/recursive/Recursive%5Bcrsv%2CMONOS%2Cwght%5D.ttf"

echo ""
echo "Results:"
for f in "$FONT_DIR"/*.ttf; do
  size=$(du -k "$f" | cut -f1)
  echo "  ${size}KB  $(basename $f)"
done
