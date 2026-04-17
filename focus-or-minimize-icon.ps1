# focus-or-minimize-icon.ps1 — Generate focus-or-minimize.ico (eye with minimize bar)
# Run: powershell -ExecutionPolicy Bypass -File focus-or-minimize-icon.ps1

Add-Type -AssemblyName System.Drawing

$size = 64
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 4)
$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
$pen.LineJoin  = [System.Drawing.Drawing2D.LineJoin]::Round
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

# ── Eye shape (upper half) ──
# Top arc
$eyePath = New-Object System.Drawing.Drawing2D.GraphicsPath
$eyePath.AddArc(6, 10, 52, 32, 180, 180)   # top lid
$eyePath.AddArc(6, 14, 52, 32, 0, 180)     # bottom lid
$g.DrawPath($pen, $eyePath)

# Pupil (filled circle)
$g.FillEllipse($brush, 24, 18, 16, 16)

# ── Minimize bar (bottom) ──
$g.DrawLine($pen, 16, 50, 48, 50)

$outPath = Join-Path $PSScriptRoot "focus-or-minimize.ico"
$ms = New-Object System.IO.MemoryStream
$bmp.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
$pngBytes = $ms.ToArray()
$ms.Dispose()

$icoHeader = [byte[]]@(0,0, 1,0, 1,0)
$dirEntry = New-Object byte[] 16
$dirEntry[0]  = $size
$dirEntry[1]  = $size
$dirEntry[2]  = 0
$dirEntry[3]  = 0
[System.BitConverter]::GetBytes([uint16]1).CopyTo($dirEntry, 4)
[System.BitConverter]::GetBytes([uint16]32).CopyTo($dirEntry, 6)
[System.BitConverter]::GetBytes([uint32]$pngBytes.Length).CopyTo($dirEntry, 8)
[System.BitConverter]::GetBytes([uint32]22).CopyTo($dirEntry, 12)

$fs = [System.IO.File]::Create($outPath)
$fs.Write($icoHeader, 0, $icoHeader.Length)
$fs.Write($dirEntry, 0, $dirEntry.Length)
$fs.Write($pngBytes, 0, $pngBytes.Length)
$fs.Close()

$g.Dispose(); $bmp.Dispose(); $pen.Dispose(); $brush.Dispose()
$eyePath.Dispose()
Write-Host "Created $outPath"
