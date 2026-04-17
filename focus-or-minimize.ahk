; ══════════════════════════════════════════════════════════════════════
; Focus-or-Minimize
; Author:  LouisGameDev
; Repo:    https://github.com/LouisGameDev/autohotkey-louis
; ══════════════════════════════════════════════════════════════════════
; OVERVIEW
;   Locks a process so its windows auto-minimize when they lose focus
;   and auto-restore when they regain it. State persists across restarts
;   via an INI file.
;
; TUTORIAL
;   Win + Alt + Pause  →  Toggle focus-lock for the active window's process.
;
;   1. Focus the window you want to lock.
;   2. Press Win+Alt+Pause — a tooltip confirms "Focus-Lock ON".
;   3. When you switch away, all windows of that process minimize.
;      When you click back, they restore automatically.
;   4. Press the hotkey again on the same process to turn it off.
; ══════════════════════════════════════════════════════════════════════

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

TraySetIcon(A_ScriptDir "\focus-or-minimize.ico")

iniFile := A_ScriptDir "\focus-or-minimize.ini"

; Runtime HWND tracking
trackedWindows := Map()
; Persisted process names (lowercase)
trackedProcs := Map()

LoadState()
ApplyToRunning()

; Win+Alt+Pause to toggle "focus-or-minimize" mode for current window's process
#!Pause:: {
    global trackedWindows, trackedProcs
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

    if trackedProcs.Has(procName) {
        trackedProcs.Delete(procName)
        for w, _ in trackedWindows.Clone() {
            try {
                if StrLower(WinGetProcessName("ahk_id " w)) = procName
                    trackedWindows.Delete(w)
            } catch
                trackedWindows.Delete(w)
        }
        ToolTip("Focus-Lock OFF: " procName)
    } else {
        trackedProcs[procName] := true
        try {
            for w in WinGetList("ahk_exe " procName)
                trackedWindows[w] := true
        }
        ToolTip("Focus-Lock ON: " procName)
    }
    SetTimer(() => ToolTip(), -2000)
    SaveState()
}

; Poll every 200ms to enforce minimize-on-focus-loss
SetTimer(EnforceWindowStates, 200)

EnforceWindowStates() {
    global trackedWindows
    if trackedWindows.Count = 0
        return

    try
        activeHwnd := WinGetID("A")
    catch
        activeHwnd := 0

    for hwnd, _ in trackedWindows.Clone() {
        ; Remove stale entries (window was closed)
        if !WinExist("ahk_id " hwnd) {
            trackedWindows.Delete(hwnd)
            continue
        }

        if hwnd = activeHwnd {
            ; This tracked window is focused — restore if minimized
            if WinGetMinMax("ahk_id " hwnd) = -1
                WinRestore("ahk_id " hwnd)
        } else {
            ; Not focused — minimize if not already
            if WinGetMinMax("ahk_id " hwnd) != -1
                WinMinimize("ahk_id " hwnd)
        }
    }
}

LoadState() {
    global trackedProcs, iniFile
    if !FileExist(iniFile)
        return
    try
        section := IniRead(iniFile, "TrackedProcesses")
    catch
        return
    loop parse section, "`n", "`r" {
        line := Trim(A_LoopField)
        if line = ""
            continue
        key := StrSplit(line, "=")[1]
        trackedProcs[StrLower(key)] := true
    }
}

SaveState() {
    global trackedProcs, iniFile
    try FileDelete(iniFile)
    for procName, _ in trackedProcs
        IniWrite("1", iniFile, "TrackedProcesses", procName)
}

ApplyToRunning() {
    global trackedWindows, trackedProcs
    for procName, _ in trackedProcs {
        try {
            for hwnd in WinGetList("ahk_exe " procName)
                trackedWindows[hwnd] := true
        }
    }
}