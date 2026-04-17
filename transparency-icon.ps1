# transparency-icon.ps1 — Generate transparency.ico (checkerboard/opacity square)
# Run: powershell -ExecutionPolicy Bypass -File transparency-icon.ps1

Add-Type -AssemblyName System.Drawing

$size = 64
$bmp = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)

$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 4)
$pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

# ── Outer rounded rectangle (window frame) ──
$outerRect = New-Object System.Drawing.Rectangle(8, 8, 48, 48)
$g.DrawRectangle($pen, $outerRect)

# ── Checkerboard pattern inside (transparency symbol) ──
$cellSize = 12
$semiWhite = [System.Drawing.Color]::FromArgb(180, 255, 255, 255)
$dimWhite  = [System.Drawing.Color]::FromArgb(70, 255, 255, 255)
$brushLight = New-Object System.Drawing.SolidBrush($semiWhite)
$brushDark  = New-Object System.Drawing.SolidBrush($dimWhite)

for ($row = 0; $row -lt 3; $row++) {
    for ($col = 0; $col -lt 3; $col++) {
        $x = 14 + $col * $cellSize
        $y = 14 + $row * $cellSize
        $isLight = (($row + $col) % 2 -eq 0)
        $b = if ($isLight) { $brushLight } else { $brushDark }
        $g.FillRectangle($b, $x, $y, $cellSize, $cellSize)
    }
}

# ── Save as .ico ──
$outPath = Join-Path $PSScriptRoot "transparency.ico"
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

$g.Dispose(); $bmp.Dispose(); $pen.Dispose()
$brushLight.Dispose(); $brushDark.Dispose()
Write-Host "Created $outPath"
