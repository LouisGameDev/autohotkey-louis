; ══════════════════════════════════════════════════════════════════════
; Transparency
; Author:  LouisGameDev
; Repo:    https://github.com/LouisGameDev/autohotkey-louis
; ══════════════════════════════════════════════════════════════════════
; OVERVIEW
;   Toggles window transparency (75% opacity) for any process.
;   State persists across restarts via transparency.ini.
;
; TUTORIAL
;   Win + Shift + Pause  →  Toggle transparency for the active window's process.
;
;   1. Focus the window you want to make transparent.
;   2. Press Win+Shift+Pause — a tooltip confirms "Transparent ON".
;   3. All windows of that process become 75% opaque.
;   4. Press the hotkey again on the same process to restore full opacity.
; ══════════════════════════════════════════════════════════════════════

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

TraySetIcon(A_ScriptDir "\transparency.ico")

targetAlpha := Round(255 * 0.75)
iniFile := A_ScriptDir "\transparency.ini"

; Process names (lowercase) that should be transparent
transparentProcs := Map()

LoadState()
ApplyToRunning()

#++Pause:: {
    global transparentProcs, targetAlpha, iniFile
    try
        hwnd := WinGetID("A")
    catch
        return
    if !hwnd
        return
    try
        procName := StrLower(WinGetProcessName("ahk_id " hwnd))
    catch
        return

    if transparentProcs.Has(procName) {
        transparentProcs.Delete(procName)
        for w in WinGetList("ahk_exe " procName)
            try WinSetTransparent(255, "ahk_id " w)
        ToolTip("Transparent OFF: " procName)
    } else {
        transparentProcs[procName] := true
        for w in WinGetList("ahk_exe " procName)
            try WinSetTransparent(targetAlpha, "ahk_id " w)
        ToolTip("Transparent ON: " procName)
    }
    SetTimer(() => ToolTip(), -2000)
    SaveState()
}

LoadState() {
    global transparentProcs, iniFile
    if !FileExist(iniFile)
        return
    try
        section := IniRead(iniFile, "TransparentProcesses")
    catch
        return
    loop parse section, "`n", "`r" {
        line := Trim(A_LoopField)
        if line = ""
            continue
        key := StrSplit(line, "=")[1]
        transparentProcs[StrLower(key)] := true
    }
}

SaveState() {
    global transparentProcs, iniFile
    try FileDelete(iniFile)
    for procName, _ in transparentProcs
        IniWrite("1", iniFile, "TransparentProcesses", procName)
}

ApplyToRunning() {
    global transparentProcs, targetAlpha
    for procName, _ in transparentProcs {
        try {
            for hwnd in WinGetList("ahk_exe " procName)
                try WinSetTransparent(targetAlpha, "ahk_id " hwnd)
        }
    }
}
