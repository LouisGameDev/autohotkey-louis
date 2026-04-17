; ══════════════════════════════════════════════════════════════════════
; Em-Dash
; Author:  LouisGameDev
; Repo:    https://github.com/LouisGameDev/autohotkey-louis
; ══════════════════════════════════════════════════════════════════════
; OVERVIEW
;   Types an em dash (—) using a simple keyboard shortcut.
;
; TUTORIAL
;   Alt + -  →  Inserts an em dash (—) at the cursor position.
;
;   Run this script and press Alt+Minus in any text field to insert
;   an em dash instead of hunting through character maps.
; ══════════════════════════════════════════════════════════════════════

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

TraySetIcon(A_ScriptDir "\em-dash.ico")

!-::Send("—")