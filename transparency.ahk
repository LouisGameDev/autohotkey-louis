#Requires AutoHotkey v2.0

transparent := false
targetAlpha := Round(255 * 0.85) 

#++Pause:: {
    global transparent, targetAlpha
    transparent := !transparent
    if transparent
        WinSetTransparent(targetAlpha, "A")
    else
        WinSetTransparent(255, "A")
}
