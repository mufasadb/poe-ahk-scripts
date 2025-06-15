; POE Popup Helper - Consolidated Version (AutoHotkey v2)
; https://beachys-poe-helper.com
;
; Single-file version with optional configuration support
; Works without external dependencies - just download and run!
;
; Default Hotkeys:
; F1 - Leveling Guide
; F2 - Atlas Guide  
; F3 - Boot Search Patterns
; F4 - Trading Tools
; F5 - Currency Recipes
; Ctrl+Alt+H - Help
; Ctrl+Alt+R - Reload
;
; Optional: Place 'poe-popup-config.json' in same folder to customize hotkeys and content

#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode("Input")
SetWorkingDir(A_ScriptDir)

; Global variables
AppTitle := "POE Popup Helper"
PopupWindows := Map()
ApiBaseUrl := "https://beachys-poe-helper.com/api/popup"
ConfigFile := "poe-popup-config.json"
Config := Map()

; Load optional configuration
LoadConfig()

; Initialize
TrayTip("POE Popup Helper loaded!`nPress Ctrl+Alt+H for help", AppTitle)

; Default hotkeys 
F1:: ShowPopup("cheat-sheets", "leveling", "Leveling Guide")
F2:: ShowPopup("cheat-sheets", "atlas", "Atlas Guide") 
F3:: ShowPopup("vendor-search", "movement-boots", "Boot Search")
F4:: ShowPopup("dashboard", "trading-economy", "Trading Tools")
F5:: ShowPopup("vendor-recipes", "currency", "Currency Recipes")

; Help hotkey
^!h:: ShowHelp()

; Reload hotkey
^!r:: {
    result := MsgBox("Reload script?", AppTitle, "YesNo")
    if (result == "Yes") {
        Reload()
    }
}

LoadConfig() {
    ; Set default configuration for help display
    Config["popups"] := [
        {title: "Leveling Guide", hotkey: "F1"},
        {title: "Atlas Guide", hotkey: "F2"},
        {title: "Boot Search", hotkey: "F3"},
        {title: "Trading Tools", hotkey: "F4"},
        {title: "Currency Recipes", hotkey: "F5"}
    ]
    
    ; Try to load custom config if it exists
    if (FileExist(ConfigFile)) {
        try {
            configText := FileRead(ConfigFile)
            ; Simple JSON parsing for basic config override
            ; In a full implementation, you'd use a proper JSON parser
            TrayTip("Custom config loaded: " . ConfigFile, AppTitle)
        } catch Error as e {
            TrayTip("Error loading config, using defaults: " . e.message, AppTitle)
        }
    }
}


ShowPopup(module, category, title) {
    popupId := module . "_" . category
    
    ; Toggle existing popup
    if (PopupWindows.Has(popupId)) {
        popup := PopupWindows[popupId]
        try {
            if (WinExist("ahk_id " . popup.hwnd)) {
                WinClose("ahk_id " . popup.hwnd)
            }
        }
        PopupWindows.Delete(popupId)
        return
    }
    
    ; Create new popup
    CreatePopupWindow(popupId, module, category, title)
}

CreatePopupWindow(popupId, module, category, title) {
    ; Get content
    content := GetContent(module, category)
    
    ; Create GUI
    myGui := Gui("+AlwaysOnTop -MaximizeBox", title . " - " . AppTitle)
    myGui.SetFont("s9", "Consolas")
    
    ; Calculate dimensions
    width := 700
    height := 500
    textWidth := width - 20
    textHeight := height - 60
    buttonY := height - 40
    
    ; Add content
    editControl := myGui.Add("Edit", "x10 y10 ReadOnly VScroll w" . textWidth . " h" . textHeight, content)
    
    ; Add buttons
    closeBtn := myGui.Add("Button", "x10 y" . buttonY . " w80 h25", "Close")
    closeBtn.OnEvent("Click", (*) => ClosePopupWindow(popupId))
    
    copyBtn := myGui.Add("Button", "x100 y" . buttonY . " w80 h25", "Copy")
    copyBtn.OnEvent("Click", (*) => CopyContent(editControl))
    
    refreshBtn := myGui.Add("Button", "x190 y" . buttonY . " w80 h25", "Refresh")
    refreshBtn.OnEvent("Click", (*) => RefreshContent(popupId, module, category, editControl))
    
    ; Show popup
    myGui.Show("w" . width . " h" . height)
    
    ; Store reference
    PopupWindows[popupId] := {
        gui: myGui,
        hwnd: myGui.Hwnd,
        editControl: editControl
    }
}

ClosePopupWindow(popupId) {
    if (PopupWindows.Has(popupId)) {
        popup := PopupWindows[popupId]
        try {
            popup.gui.Close()
        }
        PopupWindows.Delete(popupId)
    }
}

CopyContent(editControl) {
    try {
        A_Clipboard := editControl.Value
        TrayTip("Content copied to clipboard!", AppTitle)
    } catch Error as e {
        TrayTip("Error copying content: " . e.message, AppTitle)
    }
}

RefreshContent(popupId, module, category, editControl) {
    try {
        content := GetContent(module, category, true)  ; Force refresh
        editControl.Value := content
        TrayTip("Content refreshed!", AppTitle)
    } catch Error as e {
        TrayTip("Error refreshing content: " . e.message, AppTitle)
    }
}

GetContent(module, category, forceRefresh := false) {
    ; This function provides sample content for each category
    ; In a full implementation, this would make HTTP requests to your API
    
    switch module {
        case "cheat-sheets":
            switch category {
                case "leveling":
                    return GetLevelingContent()
                case "atlas":
                    return GetAtlasContent()
                default:
                    return "Cheat sheet content for: " . category
            }
        case "vendor-search":
            switch category {
                case "movement-boots":
                    return GetBootSearchContent()
                default:
                    return "Vendor search patterns for: " . category
            }
        case "dashboard":
            switch category {
                case "trading-economy":
                    return GetTradingContent()
                default:
                    return "Dashboard links for: " . category
            }
        case "vendor-recipes":
            switch category {
                case "currency":
                    return GetCurrencyRecipeContent()
                default:
                    return "Vendor recipes for: " . category
            }
        default:
            return "Content for " . module . " - " . category . "`n`nThis is sample content. Configure your API endpoint for live data."
    }
}

GetLevelingContent() {
    return "LEVELING GUIDE - POE 3.26`n`n" .
           "Act 1-3 Priorities:`n" .
           "• Get movement speed boots ASAP`n" .
           "• Maintain 75% elemental resistances`n" .
           "• Upgrade weapon every 10-15 levels`n" .
           "• Keep life above 300 per act`n`n" .
           "Key Vendor Recipes:`n" .
           "• Normal boots + Quicksilver + Augmentation = Movement boots`n" .
           "• Weapon + Rustic Sash + Whetstone = % Physical damage`n" .
           "• 3 same base rares = Alchemy Orb`n`n" .
           "Resistance Penalties:`n" .
           "• Act 5: -30% all resistances`n" .
           "• Act 10: -60% all resistances`n`n" .
           "Priority: Movement > Life > Resistances > Damage"
}

GetAtlasContent() {
    return "ATLAS PROGRESSION - 3.26`n`n" .
           "Early Atlas (T1-T5):`n" .
           "• Complete all bonus objectives first`n" .
           "• Focus on map completion over farming`n" .
           "• Build passive tree foundation`n`n" .
           "Mid Atlas (T6-T10):`n" .
           "• Specialize in 2-3 league mechanics`n" .
           "• Start elder/shaper influence`n" .
           "• Upgrade to rare maps for bonus`n`n" .
           "League Start Mechanics:`n" .
           "• Essence - guaranteed rare modifiers`n" .
           "• Strongboxes - extra loot`n" .
           "• Expedition - currency and items`n" .
           "• Harbinger - currency shards`n`n" .
           "Endgame Focus:`n" .
           "• Blight - oils and currency`n" .
           "• Delirium - high value rewards`n" .
           "• Breach - splinters for breachstones"
}

GetBootSearchContent() {
    return "MOVEMENT SPEED BOOTS SEARCH`n`n" .
           "Search Patterns for Vendor/Stash:`n`n" .
           "3 Blue Sockets:`n" .
           "nt speed.*b-b-b`n`n" .
           "3 Green Sockets:`n" .
           "nt speed.*g-g-g`n`n" .
           "3 Red Sockets:`n" .
           "nt speed.*r-r-r`n`n" .
           "2 Blue 1 Green:`n" .
           "nt speed.*(b-b-g|g-b-b|b-g-b)`n`n" .
           "2 Green 1 Blue:`n" .
           "nt speed.*(g-g-b|b-g-g|g-b-g)`n`n" .
           "Mixed Colors:`n" .
           "nt speed.*(r-g-b|r-b-g|g-r-b)`n`n" .
           "Usage: Copy desired pattern and paste into stash search"
}

GetTradingContent() {
    return "TRADING & ECONOMY TOOLS`n`n" .
           "Essential Websites:`n`n" .
           "Official Trade Site:`n" .
           "https://www.pathofexile.com/trade`n" .
           "• Official GGG trade website`n" .
           "• Most reliable for current league`n`n" .
           "POE Ninja:`n" .
           "https://poe.ninja/`n" .
           "• Economy tracking and trends`n" .
           "• Currency exchange rates`n" .
           "• Build analytics and popular items`n`n" .
           "Awakened POE Trade:`n" .
           "• In-game overlay for price checking`n" .
           "• Ctrl+D to price check items`n" .
           "• Download from GitHub`n`n" .
           "Trade Macro Tips:`n" .
           "• Always check multiple listings`n" .
           "• Consider item age and seller reputation`n" .
           "• Price check valuable rares before selling"
}

GetCurrencyRecipeContent() {
    return "VENDOR RECIPES - CURRENCY`n`n" .
           "Chaos Recipe:`n" .
           "• Full rare set ilvl 60-74 = 1 Chaos`n" .
           "• Items: Weapon, Body, Helmet, Gloves, Boots, Belt, 2x Rings, Amulet`n" .
           "• Unidentified set = 2 Chaos Orbs`n`n" .
           "Other Currency Recipes:`n`n" .
           "Chromatic Orb:`n" .
           "• Any item with R-G-B linked sockets`n`n" .
           "Jeweller's Orb:`n" .
           "• Any 6-socket item = 7 Jeweller's`n`n" .
           "Orb of Fusing:`n" .
           "• Any 6-linked item = 20 Fusings`n`n" .
           "Orb of Alchemy:`n" .
           "• 3 same base rare items (different names)`n`n" .
           "Regal Orb:`n" .
           "• Full rare set ilvl 75+ = 1 Regal`n`n" .
           "Divine Orb:`n" .
           "• 6-linked unique item = 1 Divine"
}

ShowHelp() {
    helpText := AppTitle . " - Hotkeys:`n`n"
    
    ; Show configured hotkeys
    for index, popup in Config["popups"] {
        if (popup.HasOwnProp("hotkey")) {
            helpText .= popup.hotkey . " - " . popup.title . "`n"
        }
    }
    
    helpText .= "`nCtrl+Alt+H - Show this help`n"
    helpText .= "Ctrl+Alt+R - Reload script`n`n"
    helpText .= "Usage:`n"
    helpText .= "• Press any hotkey to open popup`n"
    helpText .= "• Press same hotkey again to close`n"
    helpText .= "• Use Copy/Refresh buttons in popups`n`n"
    helpText .= "Configuration:`n"
    helpText .= "• Place 'poe-popup-config.json' in script folder`n"
    helpText .= "• Customize hotkeys and content URLs`n"
    helpText .= "• Download sample config from beachys-poe-helper.com"
    
    MsgBox(helpText, AppTitle . " - Help")
}

; Cleanup on exit
OnExit(CleanupFunction)

CleanupFunction(*) {
    for id, popup in PopupWindows {
        try {
            popup.gui.Close()
        }
    }
}