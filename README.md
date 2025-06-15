# POE AutoHotkey Scripts

A collection of AutoHotkey scripts for Path of Exile to provide quick access to guides, tools, and resources through hotkey-triggered overlays.

## Scripts Included

- **poe-web-overlay.ahk** - Modern web-based overlay script using WebView2
- **poe-popup-helper-consolidated.ahk** - All-in-one popup script with built-in content

## Features

- **Hotkey-Triggered Overlays**: Press F1-F5 for instant access to different guides
- **Web-Based UI**: Modern interface using WebView2 for rich content display
- **Draggable Positioning**: Use Move Mode (Ctrl+Alt+M) to position overlays exactly where you want
- **Dynamic Content**: Loads content from remote server for always up-to-date information
- **Multiple Categories**: Leveling guides, Atlas progression, trading tools, vendor recipes, and more

## Quick Start

1. **Download AutoHotkey v2.0+** from https://www.autohotkey.com/download/
2. **Download the script** you want to use (recommended: `poe-web-overlay.ahk`)
3. **Set up libraries**:
   - Create a `Lib` folder next to the script
   - Download libraries from https://github.com/thqby/ahk2_lib
   - Extract `WebView2/` and `ComVar.ahk` to the Lib folder
4. **Run the script** by double-clicking the .ahk file

## Default Hotkeys

- **F1** - Leveling Guide overlay
- **F2** - Atlas Guide overlay  
- **F3** - Boot Search templates
- **F4** - Trading Tools
- **F5** - Currency Recipes
- **Ctrl+Alt+H** - Show help and all available hotkeys
- **Ctrl+Alt+M** - Toggle Move Mode for repositioning overlays
- **Ctrl+Alt+R** - Reload script

## Requirements

- AutoHotkey v2.0 or newer
- Windows 10/11 with WebView2 Runtime
- Internet connection for content loading
- Required libraries from ahk2_lib repository

## Troubleshooting

- Ensure AutoHotkey v2.0+ is installed (not v1.x)
- Check that WebView2 Runtime is installed (comes with Windows 11)
- Verify the Lib folder structure is correct
- Run as administrator if you encounter permission issues
- Check Windows antivirus settings if scripts won't run

## Content Categories

The overlays provide quick access to:

- **Leveling Guides** - Step-by-step progression paths
- **Atlas Strategies** - Map progression and optimization
- **Trading Templates** - Pre-filled search strings for trade site
- **Vendor Recipes** - Currency and crafting recipes
- **League Mechanics** - Sanctum, Expedition, Heist guides
- **Quick References** - Cheat sheets and essential information

## Customization

You can modify the script to:
- Change hotkey bindings
- Adjust overlay sizes and positions
- Add custom content categories
- Modify the server endpoint for content loading

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Ensure all requirements are met
3. Verify the Lib folder contains the required files
4. Try running as administrator