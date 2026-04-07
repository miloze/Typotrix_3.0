#!/bin/bash
# setup_pi.sh — run once on the Pi to set up Chromium autostart
# SSH in and run: bash setup_pi.sh

mkdir -p ~/.config/autostart

cat > ~/.config/autostart/typotrix.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Typotrix
Exec=chromium --kiosk --no-first-run --noerrdialogs --disable-infobars --allow-file-access-from-files --remote-debugging-port=9222 file:///home/milo/typotrix3.html
Hidden=false
X-GNOME-Autostart-enabled=true
EOF

echo "✓ Autostart created — Chromium will launch on next login/reboot"
echo ""
echo "To start now without rebooting, run:"
echo "  chromium --kiosk --no-first-run --noerrdialogs --disable-infobars --allow-file-access-from-files --remote-debugging-port=9222 file:///home/milo/typotrix3.html &"
