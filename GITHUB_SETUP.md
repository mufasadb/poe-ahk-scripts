# GitHub Repository Setup Instructions

This folder contains all the files needed for the POE AutoHotkey scripts repository.

## To create the GitHub repository:

1. **Navigate to the folder**:
   ```bash
   cd /Users/danielbeach/Code/beachys-poe-helper/poe-ahk-scripts
   ```

2. **Initialize Git repository**:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: POE AutoHotkey scripts with web overlay and consolidated versions

   Features:
   - poe-web-overlay.ahk: Modern web-based overlay script with WebView2
   - poe-popup-helper-consolidated.ahk: Self-contained script with built-in content
   - Configuration support via JSON files
   - Comprehensive documentation and setup guides

   🤖 Generated with [Claude Code](https://claude.ai/code)

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

3. **Create GitHub repository**:
   ```bash
   gh repo create poe-ahk-scripts --public --description "AutoHotkey scripts for Path of Exile - provides hotkey-triggered overlays for guides, tools, and resources"
   ```

4. **Push to GitHub**:
   ```bash
   git remote add origin https://github.com/[your-username]/poe-ahk-scripts.git
   git branch -M main
   git push -u origin main
   ```

## Alternative: Manual GitHub Creation

1. Go to https://github.com/new
2. Repository name: `poe-ahk-scripts`
3. Description: "AutoHotkey scripts for Path of Exile - provides hotkey-triggered overlays for guides, tools, and resources"
4. Make it public
5. Don't initialize with README (we have one)
6. Create repository
7. Follow the instructions to push existing repository

## Repository URL

Once created, the repository will be available at:
`https://github.com/[your-username]/poe-ahk-scripts`

Your other machine can then clone with:
```bash
git clone https://github.com/[your-username]/poe-ahk-scripts
```