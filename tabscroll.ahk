; ══════════════════════════════════════════════════════════════════════
; Tab Scroll
; Author:  LouisGameDev
; Repo:    https://github.com/LouisGameDev/autohotkey-louis
; ══════════════════════════════════════════════════════════════════════
; OVERVIEW
;   Scroll through browser/editor tabs and close them using the mouse
;   scroll wheel with Alt held down.
;
; TUTORIAL
;   Alt + ScrollDown   →  Next tab        (sends Ctrl+Tab)
;   Alt + ScrollUp     →  Previous tab    (sends Ctrl+Shift+Tab)
;   Alt + MButton      →  Close tab       (sends Ctrl+W)
;
;   Hold Alt and scroll up/down to cycle tabs. Middle-click with Alt
;   held to close the current tab.
; ══════════════════════════════════════════════════════════════════════

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
