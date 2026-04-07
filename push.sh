#!/bin/bash
# push.sh — copy typotrix3.html to Pi and reload Chromium via CDP

PI="milo@192.168.1.227"
KEY="$HOME/.ssh/id_typotrix"
SSH="ssh -i $KEY"
SCP="scp -i $KEY"
FILE="typotrix3.html"
REMOTE_PATH="/home/milo/$FILE"

echo "→ Pushing $FILE..."
$SCP "$FILE" "$PI:$REMOTE_PATH"

echo "→ Ensuring boot setup..."
$SSH "$PI" bash << 'SETUP'
# .xinitrc — Chromium launches directly into X (no desktop)
printf '%s\n' \
  'sleep 3' \
  'exec chromium --kiosk --incognito --no-first-run --noerrdialogs --disable-infobars --allow-file-access-from-files --remote-debugging-port=9222 file:///home/milo/typotrix3.html' \
  > ~/.xinitrc

# .bash_profile — auto startx on tty1 console login
if ! grep -q 'startx' ~/.bash_profile 2>/dev/null; then
  printf '\nif [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then\n  exec startx -- -nocursor\nfi\n' >> ~/.bash_profile
fi
echo "✓ Boot setup verified"
SETUP

echo "→ Reloading..."
$SSH "$PI" "python3 - << 'PYEOF'
import json, socket, base64, os, urllib.request, subprocess

def reload_via_cdp():
    tabs = json.loads(urllib.request.urlopen('http://localhost:9222/json', timeout=3).read())
    if not tabs:
        return False
    ws_url = tabs[0]['webSocketDebuggerUrl']
    path   = '/' + ws_url.split('/', 3)[3]
    sock   = socket.create_connection(('localhost', 9222), timeout=5)
    key    = base64.b64encode(os.urandom(16)).decode()
    sock.sendall(f'GET {path} HTTP/1.1\r\nHost: localhost:9222\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: {key}\r\nSec-WebSocket-Version: 13\r\n\r\n'.encode())
    buf = b''
    while b'\r\n\r\n' not in buf:
        buf += sock.recv(512)
    msg   = json.dumps({'id':1,'method':'Page.reload','params':{}}).encode()
    mask  = os.urandom(4)
    frame = bytes([0x81, 0x80|len(msg)]) + mask + bytes([b^mask[i%4] for i,b in enumerate(msg)])
    sock.sendall(frame)
    sock.close()
    return True

try:
    if reload_via_cdp():
        print('✓ Reloaded')
    else:
        raise Exception('No tabs')
except:
    print('Chromium not running — launching...')
    subprocess.Popen([
        'chromium', '--kiosk', '--incognito', '--no-first-run', '--noerrdialogs',
        '--disable-infobars', '--allow-file-access-from-files',
        '--remote-debugging-port=9222', 'file:///home/milo/typotrix3.html'
    ], env={**os.environ, 'DISPLAY': ':0'},
    stdout=open('/tmp/chromium.log','w'), stderr=subprocess.STDOUT)
    print('✓ Launched')
PYEOF"

echo "✓ Done"
