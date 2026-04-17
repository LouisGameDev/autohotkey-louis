# em-dash-icon.ps1 — Generate em-dash.ico (em dash character)
# Run: powershell -ExecutionPolicy Bypass -File em-dash-icon.ps1

Add-Type -AssemblyName System.Drawing

$size = 64
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([System.Drawing.Color]::Transparent)

# Draw an em dash character "—"
$font = New-Object System.Drawing.Font("Segoe UI", 40, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$sf.LineAlignment = [System.Drawing.StringAlignment]::Center
$rect = New-Object System.Drawing.RectangleF(0, 0, $size, $size)
$g.DrawString([char]0x2014, $font, $brush, $rect, $sf)

# ── Save as .ico ──
$outPath = Join-Path $PSScriptRoot "em-dash.ico"
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

$g.Dispose(); $bmp.Dispose(); $font.Dispose(); $brush.Dispose(); $sf.Dispose()
Write-Host "Created $outPath"
