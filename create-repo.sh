#!/bin/bash

# Script to create the POE AHK Scripts GitHub repository
# Run this from the poe-ahk-scripts directory

echo "Creating POE AHK Scripts GitHub repository..."

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: POE AutoHotkey scripts with web overlay and consolidated versions

Features:
- poe-web-overlay.ahk: Modern web-based overlay script with WebView2
- poe-popup-helper-consolidated.ahk: Self-contained script with built-in content
- Configuration support via JSON files
- Comprehensive documentation and setup guides

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Create GitHub repository
gh repo create mufasadb/poe-ahk-scripts --public --description "AutoHotkey scripts for Path of Exile - provides hotkey-triggered overlays for guides, tools, and resources"

# Add remote origin
git remote add origin https://github.com/mufasadb/poe-ahk-scripts.git

# Set main branch
git branch -M main

# Push to GitHub
git push -u origin main

echo "Repository created successfully!"
echo "Clone URL: https://github.com/mufasadb/poe-ahk-scripts.git"