; =================================================================
; POE Web Overlay (v2.1 - Smart Config)
; =================================================================
; Uses base config with dynamic server updates - works offline & online
; Requires libraries from https://github.com/thqby/ahk2_lib in /Lib folder
#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Library Includes ---
#Include Lib\WebView2\WebView2.ahk
#Include Lib\ComVar.ahk

; --- Global Variables ---
Global AppTitle := "POE Web Overlay"
Global PopupWindows := Map()
Global WebBaseUrl := "https://www.poe-helpr.space"
Global Config := Map("popups", [], "positions", Map(), "macros", Map())
Global MoveMode := false

; --- Initialization ---
LoadConfig()
LoadPositions()
RegisterHotkeys()
OnMessage(0x201, WM_LBUTTONDOWN) ; For dragging windows
TrayTip(AppTitle, "Loaded! Press Ctrl+Alt+H for help.", 1)

; --- Core Hotkeys ---
^!h::ShowHelp()
^!r::Reload()
^!m::ToggleMoveMode()
^!c::ConfigureHotkeys()

; --- Game Macros ---
~::LogoutMacro()
F5::HideoutMacro()

; --- Configuration ---
LoadConfig() {
    ; Base configuration that works immediately
    baseConfig := [
        {
            module: "popup",
            category: "leveling-guide",
            title: "Leveling Guide",
            hotkey: "^F5",
            width: 400,
            height: 600
        },
        {
            module: "popup",
            category: "atlas-quick",
            title: "Atlas Quick Ref",
            hotkey: "^F6",
            width: 350,
            height: 500
        },
        {
            module: "popup",
            category: "movement-boots",
            title: "Movement Boots",
            hotkey: "^F7",
            width: 300,
            height: 400
        },
        {
            module: "popup",
            category: "vendor-recipes",
            title: "Vendor Recipes",
            hotkey: "^F8",
            width: 380,
            height: 520
        }
    ]
    
    ; Set base config first
    Config["popups"] := baseConfig
    
    ; Try to fetch updated config from server
    remoteUrl := "https://www.poe-helpr.space/config.json"
    localCacheFile := A_ScriptDir . "/popups.json"

    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.Open("GET", remoteUrl, true)
        req.Send()
        req.WaitForResponse(5) ; 5 second timeout
        if (req.Status == 200) {
            jsonString := req.ResponseText
            FileWrite(jsonString, localCacheFile, "UTF-8") ; Cache the fresh config
            Config["popups"] := JsonParse(jsonString) ; Use server config
            TrayTip(AppTitle, "Configuration updated from server", 1)
        } else {
            throw Error("Server returned status " . req.Status)
        }
    } catch e {
        ; Try to load from local cache
        try {
            jsonString := FileRead(localCacheFile, "UTF-8")
            Config["popups"] := JsonParse(jsonString)
            TrayTip(AppTitle, "Using cached configuration", 1)
        } catch {
            ; Fall back to base config (already set above)
            TrayTip(AppTitle, "Using base configuration", 1)
        }
    }
}

LoadPositions() {
    iniFile := A_ScriptDir . "/positions.ini"
    if FileExist(iniFile) {
        for popup in Config["popups"] {
            popupId := GetPopupId(popup)
            x := IniRead(iniFile, popupId, "x", "Center")
            y := IniRead(iniFile, popupId, "y", "Center")
            Config["positions"][popupId] := {x: x, y: y}
        }
    }
}

SavePositions() {
    iniFile := A_ScriptDir . "/positions.ini"
    for id, popup in PopupWindows {
        WinGetPos(&x, &y, &w, &h, popup["hwnd"])
        Config["positions"][id] := {x: x, y: y}
        IniWrite(x, iniFile, id, "x")
        IniWrite(y, iniFile, id, "y")
    }
    TrayTip(AppTitle, "Window positions saved!", 1)
}

; --- Hotkey Registration ---
RegisterHotkeys() {
    for _, popup in Config["popups"] {
        if popup.HasOwnProp("hotkey") {
            try {
                Hotkey(popup["hotkey"], ShowOverlay.Bind(popup))
            } catch e {
                TrayTip(AppTitle, "Error registering hotkey " . popup["hotkey"], 3)
            }
        }
    }
}

; --- Overlay Management ---
ShowOverlay(popup, *) {
    popupId := GetPopupId(popup)
    
    if PopupWindows.Has(popupId) {
        try {
            win := PopupWindows[popupId]
            win["wv"] := 0, win["wvc"] := 0
            win["gui"].Destroy()
        }
        PopupWindows.Delete(popupId)
    } else {
        CreateWebOverlay(popupId, popup)
    }
}

CreateWebOverlay(popupId, popup) {
    url := WebBaseUrl . "/" . popup["module"]
    if popup.HasOwnProp("category") && popup["category"] != "" {
        url .= "/" . popup["category"]
    }
    
    myGui := Gui("+AlwaysOnTop -Caption +ToolWindow", popup["title"])
    
    pos := Config["positions"].Has(popupId) ? Config["positions"][popupId] : {x: "Center", y: "Center"}
    myGui.Show("w" . popup["width"] . " h" . popup["height"] . " x" . pos["x"] . " y" . pos["y"] . " Hide")

    try {
        wvc := WebView2.CreateControllerAsync(myGui.Hwnd).await2()
        wv := wvc.CoreWebView2
        wv.DefaultBackgroundColor := 0x00FFFFFF 
        wv.Navigate(url)
    } catch e {
        myGui.Destroy()
        MsgBox("Failed to create WebView2 control: " . e.Message, AppTitle, 48)
        return
    }
    
    hwnd := myGui.Hwnd
    
    if (!MoveMode) {
        WinSetTransparent(170, hwnd)
        WinSetExStyle("+0x20", hwnd)
    }
    
    myGui.Show()
    PopupWindows[popupId] := {gui: myGui, hwnd: hwnd, wvc: wvc, wv: wv, popup: popup}
}

; --- Game Macros ---
LogoutMacro() {
    ; Send /logout command to chat
    Send("{Enter}/logout{Enter}")
    TrayTip(AppTitle, "Logout macro triggered", 1)
}

HideoutMacro() {
    ; Send /hideout command to chat
    Send("{Enter}/hideout{Enter}")
    TrayTip(AppTitle, "Hideout macro triggered", 1)
}

; --- Features ---
ToggleMoveMode() {
    Global MoveMode := !MoveMode
    if (MoveMode) {
        TrayTip(AppTitle, "Move Mode: ON`nOverlays are now solid and can be dragged.`nPress Ctrl+Alt+M to exit and save positions.", 1)
        for _, win in PopupWindows {
            WinSetTransparent("Off", win["hwnd"])
            WinSetExStyle("-0x20", win["hwnd"])
        }
    } else {
        TrayTip(AppTitle, "Move Mode: OFF`nOverlays are back to normal.", 1)
        SavePositions()
        for _, win in PopupWindows {
            WinSetTransparent(170, win["hwnd"])
            WinSetExStyle("+0x20", win["hwnd"])
        }
    }
}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    if MoveMode && GetPopupByHwnd(hwnd) != "" {
        PostMessage(0xA1, 2, 0, , hwnd) ; Drag the window
    }
}


; --- Utilities ---
GetPopupId(popup) {
    id := popup["module"]
    if popup.HasOwnProp("category") && popup["category"] != "" {
        id .= "_" . popup["category"]
    }
    return id
}

JsonParse(json) {
    static doc := ""
    if !IsObject(doc) {
        doc := ComObject("HTMLFile")
        doc.write('<meta http-equiv="X-UA-Compatible" content="IE=Edge">')
        doc.close()
    }
    return doc.parentWindow.JSON.parse(json)
}

ShowHelp() {
    helpText := AppTitle . " - Hotkeys:`n"
    helpText .= "`n--- Game Macros ---"
    helpText .= "`n~ (Tilde) - Logout (/logout)"
    helpText .= "`nF5 - Return to Hideout (/hideout)"
    helpText .= "`n`n--- Popup Overlays ---"
    for _, popup in Config["popups"] {
        if popup.HasOwnProp("hotkey")
            helpText .= "`n" . popup["hotkey"] . " - " . popup["title"]
    }
    helpText .= "`n`n--- Configuration ---"
    helpText .= "`n^!c - Configure Hotkeys"
    helpText .= "`n^!m - Toggle Move Mode (drag to reposition)"
    helpText .= "`n`n--- Other ---"
    helpText .= "`n^!h - Show this help"
    helpText .= "`n^!r - Reload script"
    helpText .= "`n`nNote: F1-F4 are reserved for POE's default functions"
    helpText .= "`n`nTip: Use Move Mode to drag overlays to permanent positions!"
    
    result := MsgBox(helpText . "`n`nPress 'Yes' to activate Move Mode now, 'No' to close help.", AppTitle . " - Help", "YesNo")
    if (result == "Yes") {
        if (!MoveMode) {
            ToggleMoveMode()
        }
    }
}

ConfigureHotkeys() {
    configText := "Current Hotkey Configuration:`n`n"
    configText .= "Game Macros:`n"
    configText .= "~ (Tilde) - Logout (/logout)`n"
    configText .= "F5 - Hideout (/hideout)`n`n"
    configText .= "Popup Overlays:`n"
    
    for _, popup in Config["popups"] {
        if popup.HasOwnProp("hotkey")
            configText .= popup["hotkey"] . " - " . popup["title"] . "`n"
    }
    
    configText .= "`nTo modify hotkeys, edit the config at:`n"
    configText .= "https://www.poe-helpr.space/config.json`n`n"
    configText .= "Or edit popups.json in script directory after download.`n"
    configText .= "Then press Ctrl+Alt+R to reload."
    
    MsgBox(configText, AppTitle . " - Hotkey Configuration")
}

; --- Cleanup ---
OnExit(Cleanup)
Cleanup(*) {
    for _, popup in PopupWindows {
        try popup["gui"].Destroy()
    }
}

; Helper function to find popup by HWND
GetPopupByHwnd(hwnd) {
    for id, win in PopupWindows {
        if win["hwnd"] == hwnd {
            return id
        }
    }
    return ""
}