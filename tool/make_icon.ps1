# Draws the We Learn "WL" logo as vector shapes and renders the icon PNGs.
param([string]$OutDir)

Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force $OutDir | Out-Null

# Design space: letters span x 0..100, y -8..60 (y grows downwards).
# W = four slanted strokes, stroke width 14. L = tall bar + foot.
$W = @(
  @(@(0,0),  @(14,0),  @(30,60), @(16,60)),
  @(@(16,60),@(30,60), @(45,15), @(31,15)),
  @(@(31,15),@(45,15), @(60,60), @(46,60)),
  @(@(46,60),@(60,60), @(76,0),  @(62,0))
)
$Lbar  = @(@(62,-8), @(78,-8), @(78,60), @(62,60))
$Lfoot = @(@(62,45), @(100,45), @(100,60), @(62,60))

# Where the W's last stroke crosses the L's bar (exact triangle, see notes).
$Overlap = @(@(62,0), @(76,0), @(62,52.5))

function New-Path($polys, [double]$scale, [double]$ox, [double]$oy) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.FillMode = [System.Drawing.Drawing2D.FillMode]::Winding
  foreach ($poly in $polys) {
    # All polygons must wind the same way, or Winding fill cancels overlaps.
    $area = 0.0
    for ($i = 0; $i -lt $poly.Count; $i++) {
      $a = $poly[$i]; $b = $poly[($i + 1) % $poly.Count]
      $area += $a[0] * $b[1] - $b[0] * $a[1]
    }
    $ordered = if ($area -lt 0) { @($poly[($poly.Count - 1)..0]) } else { $poly }
    $pts = foreach ($p in $ordered) { New-Object System.Drawing.PointF(([float]($ox + $p[0] * $scale)), ([float]($oy + $p[1] * $scale))) }
    $path.AddPolygon([System.Drawing.PointF[]]$pts)
  }
  return $path
}

function Render([string]$file, [int]$size, [double]$contentWidth, [string]$mode) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $g.Clear([System.Drawing.Color]::Transparent)

  if ($mode -eq 'full') { $g.Clear([System.Drawing.Color]::FromArgb(255, 0, 0, 0)) }

  $scale = $contentWidth / 100.0
  $ox = ($size - $contentWidth) / 2.0
  $oy = $size / 2.0 - 26 * $scale   # centre of y range -8..60 is 26

  $wPath = New-Path $W $scale $ox $oy
  $lPath = New-Path @($Lbar, $Lfoot) $scale $ox $oy

  if ($mode -eq 'mono') {
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillPath($white, $wPath); $g.FillPath($white, $lPath)
  } else {
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 255, 255))
    $blue  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 43, 108, 255))
    $deep  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 22, 64, 190))
    $g.FillPath($white, $wPath)
    $g.FillPath($blue, $lPath)
    # Where the W's last stroke crosses the L: a deeper blue, as in the design.
    $g.FillPath($deep, (New-Path @(,$Overlap) $scale $ox $oy))
  }
  $g.Dispose()
  $bmp.Save((Join-Path $OutDir $file), [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

# Full icon (iOS, Play Store, legacy Android): letters ~58% of the width.
Render 'icon_full.png' 1024 590 'full'
# Adaptive foreground: flutter_launcher_icons insets it by 16%, so the letters
# use ~70% of this image to land inside the 66dp safe zone of 108dp.
Render 'icon_foreground.png' 1024 720 'color'
# Android 13+ themed icon silhouette.
Render 'icon_monochrome.png' 1024 720 'mono'
# In-app logo.
Render 'logo.png' 512 300 'full'
"done"
