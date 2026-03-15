#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce

; =============================================================================
;   main.ahk — hedglen
;   AutoHotkey v2 master script
;   Tracked in dotfiles: https://github.com/hedglen/dotfiles
; =============================================================================

; =============================================================================
;   Remaps
; =============================================================================

; CapsLock → Escape  (best remap of all time)
CapsLock::Escape

; Alt+CapsLock → actual CapsLock (in case you need it)
LAlt & CapsLock::CapsLock

; =============================================================================
;   App Launchers  (Win + key)
; =============================================================================

; Win+T → Windows Terminal (PowerShell)
#t:: Run "wt.exe"

; Win+E → File Pilot  (your file manager)
#e:: {
    if WinExist("ahk_exe FilePilot.exe")
        WinActivate
    else
        Run "FilePilot.exe"
}

; Win+B → Brave Browser
#b:: {
    if WinExist("ahk_exe brave.exe")
        WinActivate
    else
        Run "brave.exe"
}

; Win+N → Notion
#n:: {
    if WinExist("ahk_exe Notion.exe")
        WinActivate
    else
        Run "Notion.exe"
}

; Win+O → Obsidian
#o:: {
    if WinExist("ahk_exe Obsidian.exe")
        WinActivate
    else
        Run "Obsidian.exe"
}

; Win+C → VS Code workspace
#c:: Run 'code "' A_MyDocuments '\..\dotfiles\hedglen.code-workspace"'

; =============================================================================
;   Text Expanders
;   Type the trigger and it expands automatically.
;   Add a space/enter after the trigger to fire.
; =============================================================================

; @@ → your email address
:*:@@::hedglen@pm.me

; /shrug
:*:/shrug::¯\_(ツ)_/¯

; /check → checkmark
:*:/check::✓

; /arrow → right arrow
:*:/arr::→

; Date stamp  (type /date)
:*:/date:: {
    SendInput FormatTime(, "yyyy-MM-dd")
}

; =============================================================================
;   Window Management
; =============================================================================

; Win+Alt+Left  → move window to left monitor
#!Left:: {
    win := WinExist("A")
    WinGetPos &x, &y, &w, &h, win
    mon := GetMonitorForWindow(win)
    if (mon > 1) {
        MonitorGet mon - 1, &mL, &mT, &mR, &mB
        WinMove mL + 50, mT + 50, w, h, win
    }
}

; Win+Alt+Right → move window to right monitor
#!Right:: {
    win := WinExist("A")
    WinGetPos &x, &y, &w, &h, win
    mon := GetMonitorForWindow(win)
    if (mon < MonitorGetCount()) {
        MonitorGet mon + 1, &mL, &mT, &mR, &mB
        WinMove mL + 50, mT + 50, w, h, win
    }
}

; Win+Alt+F → true fullscreen toggle (borderless, any window)
#!f:: {
    win := WinExist("A")
    WinGetPos &x, &y, &w, &h, win
    MonitorGetWorkArea , &mL, &mT, &mR, &mB
    if (w = mR - mL and h = mB - mT)
        WinRestore win
    else
        WinMove mL, mT, mR - mL, mB - mT, win
}

; =============================================================================
;   Clipboard
; =============================================================================

; Ctrl+Shift+V → paste as plain text (strip formatting)
^+v:: {
    clip := A_Clipboard
    A_Clipboard := clip
    Send "^v"
}

; =============================================================================
;   Helpers
; =============================================================================

GetMonitorForWindow(hwnd) {
    WinGetPos &x, &y, &w, &h, hwnd
    cx := x + w // 2
    cy := y + h // 2
    loop MonitorGetCount() {
        MonitorGet A_Index, &mL, &mT, &mR, &mB
        if (cx >= mL and cx < mR and cy >= mT and cy < mB)
            return A_Index
    }
    return 1
}
