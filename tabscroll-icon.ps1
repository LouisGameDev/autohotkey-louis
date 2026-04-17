# tabscroll-icon.ps1 — Generate tabscroll.ico (horizontal arrows)
# Run: powershell -ExecutionPolicy Bypass -File tabscroll-icon.ps1

Add-Type -AssemblyName System.Drawing

$size = 64
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 5)
$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$pen.LineJoin  = [System.Drawing.Drawing2D.LineJoin]::Round

$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

# ── Left arrow (top half) ──
$leftArrow = New-Object System.Drawing.Drawing2D.GraphicsPath
$leftArrow.AddLine(30, 12, 10, 22)   # top arm  → tip
$leftArrow.AddLine(10, 22, 30, 32)   # tip → bottom arm
$g.DrawPath($pen, $leftArrow)

# ── Right arrow (bottom half) ──
$rightArrow = New-Object System.Drawing.Drawing2D.GraphicsPath
$rightArrow.AddLine(34, 32, 54, 42)  # top arm  → tip
$rightArrow.AddLine(54, 42, 34, 52)  # tip → bottom arm
$g.DrawPath($pen, $rightArrow)

# ── Save as .ico ──
$outPath = Join-Path $PSScriptRoot "tabscroll.ico"
$ms = New-Object System.IO.MemoryStream
$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$pngBytes = $ms.ToArray()
$ms.Dispose()

# ICO format: header + one directory entry + PNG payload
$icoHeader = [byte[]]@(0,0, 1,0, 1,0)  # reserved, type=1 (ICO), count=1
$dirEntry = New-Object byte[] 16
$dirEntry[0]  = $size          # width
$dirEntry[1]  = $size          # height
$dirEntry[2]  = 0              # palette
$dirEntry[3]  = 0              # reserved
[System.BitConverter]::GetBytes([uint16]1).CopyTo($dirEntry, 4)   # color planes
[System.BitConverter]::GetBytes([uint16]32).CopyTo($dirEntry, 6)  # bits per pixel
[System.BitConverter]::GetBytes([uint32]$pngBytes.Length).CopyTo($dirEntry, 8)   # image size
[System.BitConverter]::GetBytes([uint32]22).CopyTo($dirEntry, 12)                # offset (6+16)

$fs = [System.IO.File]::Create($outPath)
$fs.Write($icoHeader, 0, $icoHeader.Length)
$fs.Write($dirEntry, 0, $dirEntry.Length)
$fs.Write($pngBytes, 0, $pngBytes.Length)
$fs.Close()

$g.Dispose()
$bmp.Dispose()
$pen.Dispose()
$brush.Dispose()

Write-Host "Created $outPath"
