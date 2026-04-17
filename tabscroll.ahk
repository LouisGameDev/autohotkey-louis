#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

TraySetIcon(A_ScriptDir "\tabscroll.ico")

; ── Tab Scrolling ────────────────────────────────────────────────────
; Alt+ScrollDown  = Ctrl+Tab       (next tab)
; Alt+ScrollUp    = Ctrl+Shift+Tab (previous tab)
; Alt+MButton     = Ctrl+W         (close tab)

!WheelDown::Send "^{Tab}"
!WheelUp::Send "^+{Tab}"
!MButton::Send "^w"
