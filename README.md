# Typotrix 3.0

A typographic display app for Raspberry Pi. Variable fonts animate their weight and width axes in real time, displayed as a 2×2 grid of letters on a HyperPixel 4 Square (720×720) touchscreen.

Built with HTML/CSS/JS running in Chromium — no Python, no pre-rendering, GPU-accelerated animation at 60fps.

![Typotrix 3.0](https://raw.githubusercontent.com/miloze/Typotrix_3.0/main/preview.jpg)

---

## Features

- Variable font animation — weight and width axes breathing simultaneously via `font-variation-settings`
- 2×2 letter grid with staggered reveal on font change
- 16 variable fonts (Google Fonts, stored locally on the Pi)
- Touch navigation — tap left/right to cycle fonts, long press to invert
- Keyboard navigation — `←` `→` or `a` `d` to cycle, `i` to invert
- Font name + axis range displayed at the bottom
- Word cache — going back shows the same word you saw before
- Fully configurable — all timings, colours, fonts and layout in one `CONFIG` block

---

## Hardware

- Raspberry Pi 3B or 4B
- Pimoroni HyperPixel 4 Square (720×720 touchscreen)
- Raspberry Pi OS (Bookworm)

---

## Setup

### 1. Clone the repo on your Mac/PC

```bash
git clone https://github.com/miloze/Typotrix_3.0.git
cd Typotrix_3.0
```

### 2. Set up the Pi

Edit `push.sh` and `setup_fonts.sh` with your Pi's IP address if different from `192.168.1.227`.

Run the one-time setup (downloads variable fonts to the Pi):

```bash
scp setup_fonts.sh milo@192.168.1.227:~ && ssh milo@192.168.1.227 "bash setup_fonts.sh"
```

Run the autostart setup (Chromium launches on boot):

```bash
scp setup_pi.sh milo@192.168.1.227:~ && ssh milo@192.168.1.227 "bash setup_pi.sh"
```

### 3. First launch

SSH into the Pi and start Chromium manually the first time:

```bash
ssh milo@192.168.1.227 "DISPLAY=:0 nohup chromium --kiosk --no-first-run --noerrdialogs --allow-file-access-from-files --remote-debugging-port=9222 'file:///home/milo/typotrix3.html' >/tmp/chromium.log 2>&1 &"
```

After that, Chromium will autostart on boot.

---

## Workflow

Edit `typotrix3.html`, then push and reload in one command:

```bash
./push.sh
```

The page reloads instantly via Chrome DevTools Protocol — no restart, no delay.

---

## Configuration

Everything you'd want to tweak is in the `CONFIG` block at the top of `typotrix3.html`:

| Setting | Description |
|---|---|
| `fontScale` | How much of each cell the letter fills (0–1) |
| `anim.wdthPeriod` | Width breathing cycle in seconds |
| `anim.wghtPeriod` | Weight breathing cycle in seconds |
| `anim.wdthPhase` / `wghtPhase` | Phase offset so axes peak at different times |
| `anim.letterStagger` | Per-letter phase offset — try `0.4` for independent drift |
| `anim.revealDelay` | Stagger between letters appearing on font change |
| `colors` | All colours including inverted mode |
| `fonts` | Font list with axis ranges — add/remove as needed |
| `words` | Word pool for the grid |

---

## Adding fonts

Variable fonts need a `wght` axis at minimum. Fonts with a `wdth` axis will also animate width.

1. Download the variable TTF to `/home/milo/fonts/` on the Pi
2. Add an entry to `CONFIG.fonts` in `typotrix3.html`:

```javascript
{ name: "Font Name", localFile: "FontName_variable.ttf", wdth: [75, 125], wght: [100, 900] }
```

---

## Predecessor

[Typotrix 2.0](https://github.com/miloze/Typotrix_2.0) — Python/pygame version with pre-rendered font instances.
