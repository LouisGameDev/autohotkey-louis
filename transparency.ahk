; ══════════════════════════════════════════════════════════════════════
; Transparency
; Author:  LouisGameDev
; Repo:    https://github.com/LouisGameDev/autohotkey-louis
; ══════════════════════════════════════════════════════════════════════
; OVERVIEW
;   Toggles transparency for the active window only.
;
; TUTORIAL
;   Win + Shift + Pause  →  Toggle transparency for the active window.
;
;   1. Focus the window you want to make transparent.
;   2. Press Win+Shift+Pause — a tooltip confirms "Transparent ON".
;   3. That window becomes 95% opaque.
;   4. Press the hotkey again to restore full opacity.
; ══════════════════════════════════════════════════════════════════════

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

TraySetIcon(A_ScriptDir "\transparency.ico")

targetAlpha := Round(255 * 0.95)

#++Pause:: {
    global targetAlpha
    try
        hwnd := WinGetID("A")
    catch
        return
    if !hwnd
        return

    currentAlpha := ""
    try currentAlpha := WinGetTransparent("ahk_id " hwnd)

    if currentAlpha = "" || currentAlpha >= 255 {
        try WinSetTransparent(targetAlpha, "ahk_id " hwnd)
        ToolTip("Transparent ON")
    } else {
        try WinSetTransparent(255, "ahk_id " hwnd)
        ToolTip("Transparent OFF")
    }

    SetTimer(() => ToolTip(), -2000)
}
