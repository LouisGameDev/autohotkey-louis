# autohotkey-louis

Personal AutoHotkey v2 scripts. All scripts run at Windows startup via shortcuts in `shell:startup` pointing to `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`.

---

## winscroll.ahk

Window management driven by **Win + scroll wheel**. Provides a fast, physical workflow for focusing on one window at a time.

https://github.com/user-attachments/assets/e5aabd5c-7509-459e-9728-294f9ff21262

### Mental model

With enough windows open, normal window management breaks down. Alt-Tab becomes a guessing game of thumbnails. The taskbar turns into a wall of unlabeled buttons. You end up spending more time hunting for the right window than actually using it.

winscroll reframes the problem. Instead of navigating *to* what you want, you scroll away everything you don't need. Windows you're done with disappear one by one — out of sight, out of mind — until only your target is left. The desktop is no longer a pile to dig through; it's a stack you're in control of.

Restoring is just as fast. Scroll back up and your windows return in reverse order, exactly as you left them.

### How the stack works

Every minimized window is pushed onto a **LIFO stack** (last-in, first-out). Scrolling up pops the most recently minimized window and restores it. This means the restore order is the exact reverse of the minimize order — the windows you cleared last come back first.

The stack also tracks **external minimizes** (Win+D, taskbar clicks, etc.) via a system-wide `EVENT_SYSTEM_MINIMIZESTART` hook. If you manually restore a window (clicking it in the taskbar, Alt-Tab, etc.), it is automatically removed from the stack so it won't be restored a second time.

### Hotkeys

| Hotkey | Action |
|---|---|
| **Win + ScrollDown** | Minimize the window under the cursor, push it onto the stack |
| **Win + ScrollUp** | Restore the last minimized window from the stack |
| **Win + MButton** | Minimize all windows on the monitor under the cursor (except the active window) |

### Safety

Only "real" application windows can be minimized. The script uses the canonical `IsAltTabWindow` algorithm (the same logic Windows uses for Alt-Tab) combined with a `WS_MINIMIZEBOX` style check. Shell components like the taskbar, system tray, and desktop are never touched.

---

## focus-or-minimize.ahk

Toggle **focus-lock** on individual windows. A locked window automatically minimizes when it loses focus and restores when it regains focus — useful for keeping a reference window visible only while you're actively using it.

### Hotkeys

| Hotkey | Action |
|---|---|
| **Win + Alt + Pause** | Toggle focus-lock on the active window |

Tracked windows are polled every 200 ms. Closing a tracked window removes it automatically.

---

## tabscroll.ahk

Cycle browser/editor tabs with **Alt + scroll wheel**.

### Hotkeys

| Hotkey | Action |
|---|---|
| **Alt + ScrollDown** | Next tab (Ctrl+Tab) |
| **Alt + ScrollUp** | Previous tab (Ctrl+Shift+Tab) |
| **Alt + MButton** | Close tab (Ctrl+W) |

---

## em-dash.ahk

Type an **em dash** (—) with a single keystroke.

### Hotkeys

| Hotkey | Action |
|---|---|
| **Alt + -** | Send `—` |

---

## transparency.ahk

Toggle **65% opacity** on any window.

### Hotkeys

| Hotkey | Action |
|---|---|
| **Win + Shift + Pause** | Toggle transparency on the active window |
