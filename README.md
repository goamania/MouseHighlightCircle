# MouseHighlightCircle

A lightweight addon for **Turtle WoW (1.12.1)** that adds a pixelated white ring around your mouse cursor. Fully customizable — size, color, alpha, combat-only mode, and more.

## Features

- Pixelated white ring around the mouse cursor (transparent center)
- **Customizable size**: `/mhc size N` (8–128)
- **Customizable color**: `/mhc color R G B` (0–1 each)
- **Customizable alpha**: `/mhc alpha N` (0–1)
- **Combat-only mode**: `/mhc combat` — only shows the ring in combat
- **Hide on right-click**: `/mhc rightclick` — hides the ring while holding right-click
- **Auto-hide while mounted**: `/mhc mount` — hides the ring when mounted, shows when dismounted (detected via buff tooltip scan)
- **Keybinding support**: Bind a key to toggle the ring (Key Bindings → MouseHighlightCircle → Toggle Circle)
- **Settings persist** across sessions (SavedVariables)
- Slash commands: `/mhc show`, `/mhc hide`, `/mhc toggle`
- Lightweight and optimized for Turtle WoW's 1.12.1 client

## Installation

1. Download the latest release.
2. Extract `MouseHighlightCircle` into `World of Warcraft/Interface/AddOns/`.
3. Ensure `pixelring.tga` is in the addon folder.
4. Launch Turtle WoW, enable the addon, and log in.
5. Use `/mhc show` or `/mhc toggle` in-game.

## Slash Commands

| Command | Description |
|---------|-------------|
| `/mhc show` | Show the circle |
| `/mhc hide` | Hide the circle |
| `/mhc toggle` | Toggle show/hide |
| `/mhc size N` | Set ring size (8–128, default 32) |
| `/mhc color R G B` | Set RGB color (0–1 each, default 1 1 1) |
| `/mhc alpha N` | Set transparency (0–1, default 0.7) |
| `/mhc combat` | Toggle combat-only mode |
| `/mhc rightclick` | Toggle hide on right-click |
| `/mhc mount` | Toggle auto-hide while mounted |
| `/mhc status` | Show current settings |

## Texture

The addon uses `pixelring.tga` (64x64) for the ring effect. Replace it with your own design (same dimensions, transparent center).

## Keybinding

Go to **Key Bindings** → **MouseHighlightCircle** → **Toggle Circle** to assign a hotkey.

## Compatibility

- ✅ **Ascension WoW** — fully compatible (Interface 30300). Tested.
- ✅ **Turtle WoW** (Vanilla 1.12.1) — fully compatible. Tested.
- May work on other 1.12.1 / 3.3.5-based servers.

## Contributing

Fork and submit pull requests! Open an issue for bugs or suggestions.

## Credits

Developed by goamania for the Turtle WoW community.

## License

MIT License — see [LICENSE](LICENSE) for details.

---

BTC: bc1qlaurnxw4uxslr35jyxl9uzp3m7z02krwxzt9ef
