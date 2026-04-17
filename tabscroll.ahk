#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

TraySetIcon(A_ScriptDir "\tabscroll.ico")

; ── Tab Scrolling ────────────────────────────────────────────────────
; Alt+ScrollDown  = Ctrl+Tab       (next tab)
; Alt+ScrollUp    = Ctrl+Shift+Tab (previous tab)

!WheelDown::Send "^{Tab}"
!WheelUp::Send "^+{Tab}"
