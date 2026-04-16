#Requires AutoHotkey v2.0

; Map of tracked windows (hwnd -> true)
trackedWindows := Map()

; Win+Alt+Pause to toggle "focus-or-minimize" mode for current window
#!Pause:: {
    global trackedWindows
    hwnd := WinGetID("A")
    if !hwnd
        return

    if trackedWindows.Has(hwnd) {
        trackedWindows.Delete(hwnd)
        ToolTip("Focus-Lock OFF: " WinGetTitle(hwnd))
    } else {
        trackedWindows[hwnd] := true
        ToolTip("Focus-Lock ON: " WinGetTitle(hwnd))
    }
    SetTimer(() => ToolTip(), -2000)
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

    for hwnd, _ in trackedWindows {
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