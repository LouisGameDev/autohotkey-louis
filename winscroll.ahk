#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

TraySetIcon(A_ScriptDir "\winscroll.ico")

; ── Minimize / Restore Stack ─────────────────────────────────────────
; Win+ScrollDown  = minimize window under cursor, push to stack
; Win+ScrollUp    = restore last minimized window from stack
; Win+MButton     = minimize all windows on monitor under cursor
; If a window is manually restored, it is removed from the stack.

minimized := []       ; LIFO stack of HWNDs we minimized
restoring := false    ; re-entry guard during WinRestore
minimizing := false   ; re-entry guard during WinMinimize

; ── IsAltTabWindow ───────────────────────────────────────────────────
; Canonical Win32 algorithm: returns true only for windows that appear
; in Alt+Tab / the taskbar.
IsAltTabWindow(hwnd) {
    if !hwnd
        return false
    try {
        if !WinExist("ahk_id " hwnd)
            return false
        hwndWalk := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 3, "Ptr")  ; GA_ROOTOWNER
        loop {
            hwndTry := DllCall("GetLastActivePopup", "Ptr", hwndWalk, "Ptr")
            if hwndTry = hwndWalk
                break
            if DllCall("IsWindowVisible", "Ptr", hwndTry)
                break
            hwndWalk := hwndTry
        }
        if hwndWalk != hwnd
            return false
        exStyle := WinGetExStyle("ahk_id " hwnd)
        if exStyle & 0x80           ; WS_EX_TOOLWINDOW
            return false
        if !(exStyle & 0x40000) {   ; not WS_EX_APPWINDOW
            style := WinGetStyle("ahk_id " hwnd)
            if !(style & 0x10000000)
                return false
            title := WinGetTitle("ahk_id " hwnd)
            if title = ""
                return false
        }
        cloaked := 0
        DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "UInt*", &cloaked, "UInt", 4)
        if cloaked
            return false
        return true
    } catch
        return false
}

; ── CanMinimize — window is Alt+Tab, has minimize box, not minimized ─
CanMinimize(hwnd) {
    if !IsAltTabWindow(hwnd)
        return false
    try {
        style := WinGetStyle("ahk_id " hwnd)
        if !(style & 0x20000)       ; WS_MINIMIZEBOX
            return false
        if style & 0x20000000       ; WS_MINIMIZE (already minimized)
            return false
        return true
    } catch
        return false
}

; ── GetTopLevelOwner — walk to the root owner of a child/popup ───────
GetTopLevelOwner(hwnd) {
    loop {
        owner := DllCall("GetWindow", "Ptr", hwnd, "UInt", 4, "Ptr")  ; GW_OWNER
        if !owner
            break
        hwnd := owner
    }
    return hwnd
}

; ── MinimizeAndPush — minimize a window and record it ────────────────
MinimizeAndPush(hwnd) {
    global minimized, minimizing
    minimizing := true
    try
        WinMinimize("ahk_id " hwnd)
    finally
        minimizing := false
    minimized.Push(hwnd)
}

; ── Restore — pop and restore the most recent minimized window ───────
RestoreOne() {
    global minimized, restoring
    while minimized.Length > 0 {
        hwnd := minimized.Pop()
        try {
            if !WinExist("ahk_id " hwnd)
                continue
            ; only restore if still minimized (user may have restored it manually)
            if WinGetMinMax("ahk_id " hwnd) != -1
                continue
            restoring := true
            try
                WinRestore("ahk_id " hwnd)
            finally
                restoring := false
            try
                WinActivate("ahk_id " hwnd)
            return
        } catch
            continue
    }
}

; ── Hooks: track external minimize/restore ───────────────────────────
; EVENT_SYSTEM_MINIMIZESTART = 0x0016, EVENT_SYSTEM_MINIMIZEEND = 0x0017
DllCall("SetWinEventHook"
    , "UInt", 0x0016      ; eventMin
    , "UInt", 0x0017      ; eventMax
    , "Ptr",  0
    , "Ptr",  CallbackCreate(OnMinimizeEvent)
    , "UInt", 0
    , "UInt", 0
    , "UInt", 0x0002)     ; WINEVENT_OUTOFCONTEXT

OnMinimizeEvent(hHook, event, hwnd, idObj, idChild, dwThread, dwTime) {
    global minimized, minimizing, restoring
    if !hwnd
        return
    if event = 0x0016 {   ; MINIMIZESTART
        if minimizing     ; we did this minimize ourselves — already pushed
            return
        ; external minimize (Win+D, taskbar click, etc.) — track it
        if IsAltTabWindow(hwnd)
            minimized.Push(hwnd)
    } else {              ; MINIMIZEEND
        if restoring      ; we did this restore ourselves — ignore
            return
        ; manual restore — remove from stack
        i := minimized.Length
        while i >= 1 {
            if minimized[i] = hwnd
                minimized.RemoveAt(i)
            i--
        }
    }
}

; ── Hotkeys ──────────────────────────────────────────────────────────

; Win+ScrollDown — minimize window under cursor
#WheelDown::{
    try {
        MouseGetPos(,, &mouseHwnd)
        if !mouseHwnd
            return
        mouseHwnd := GetTopLevelOwner(mouseHwnd)
        if CanMinimize(mouseHwnd)
            MinimizeAndPush(mouseHwnd)
    }
}

; Win+ScrollUp — restore last minimized window
#WheelUp::RestoreOne()

; Win+MButton — minimize all windows on monitor under cursor (except active)
#MButton::{
    global minimized
    MouseGetPos(,, &mouseWin)
    if !mouseWin
        return
    hMon := DllCall("MonitorFromWindow", "Ptr", mouseWin, "UInt", 2, "Ptr")
    if !hMon
        return
    try activeHwnd := WinGetID("A")
    catch
        activeHwnd := 0
    for hwnd in WinGetList() {
        if hwnd = activeHwnd
            continue
        if !CanMinimize(hwnd)
            continue
        try {
            wMon := DllCall("MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr")
            if wMon != hMon
                continue
            MinimizeAndPush(hwnd)
        }
    }
}
