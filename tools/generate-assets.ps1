$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$assetDir = Join-Path $root "assets"

function New-Canvas {
    param([int]$Width, [int]$Height)
    $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Add-LinearBackground {
    param($Graphics, [int]$Width, [int]$Height, [string]$Top, [string]$Bottom)
    $rect = New-Object System.Drawing.Rectangle(0, 0, $Width, $Height)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.ColorTranslator]::FromHtml($Top),
        [System.Drawing.ColorTranslator]::FromHtml($Bottom),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $Graphics.FillRectangle($brush, $rect)
    $brush.Dispose()
}

function Add-Glow {
    param($Graphics, [int]$X, [int]$Y, [int]$Radius, [string]$Color, [int]$Alpha)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse($X - $Radius, $Y - $Radius, $Radius * 2, $Radius * 2)
    $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
    $brush.CenterColor = [System.Drawing.Color]::FromArgb($Alpha, [System.Drawing.ColorTranslator]::FromHtml($Color))
    $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, [System.Drawing.ColorTranslator]::FromHtml($Color)))
    $Graphics.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function Add-Noise {
    param($Bitmap, [int]$Every = 5)
    $random = New-Object System.Random(27)
    for ($x = 0; $x -lt $Bitmap.Width; $x += $Every) {
        for ($y = 0; $y -lt $Bitmap.Height; $y += $Every) {
            $v = $random.Next(0, 28)
            $a = $random.Next(10, 35)
            $c = [System.Drawing.Color]::FromArgb($a, $v, $v, $v)
            $Bitmap.SetPixel($x, $y, $c)
        }
    }
}

function Add-HeartPath {
    param($Graphics, [int]$CenterX, [int]$CenterY, [int]$Scale, [string]$Stroke, [int]$Alpha, [float]$Width)
    $points = New-Object System.Collections.Generic.List[System.Drawing.PointF]
    for ($i = 0; $i -le 220; $i++) {
        $t = (2 * [Math]::PI) * ($i / 220)
        $x = 16 * [Math]::Pow([Math]::Sin($t), 3)
        $y = 13 * [Math]::Cos($t) - 5 * [Math]::Cos(2 * $t) - 2 * [Math]::Cos(3 * $t) - [Math]::Cos(4 * $t)
        $points.Add([System.Drawing.PointF]::new($CenterX + ($x * $Scale), $CenterY - ($y * $Scale)))
    }
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($Alpha, [System.Drawing.ColorTranslator]::FromHtml($Stroke)), $Width)
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $Graphics.DrawLines($pen, $points.ToArray())
    $pen.Dispose()
}

function Add-Vinyl {
    param($Graphics, [int]$X, [int]$Y, [int]$Size, [string]$LabelColor)
    $shadow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(70, 0, 0, 0))
    $Graphics.FillEllipse($shadow, $X + 22, $Y + 30, $Size, $Size)
    $shadow.Dispose()

    $rect = New-Object System.Drawing.Rectangle($X, $Y, $Size, $Size)
    $vinylBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect,
        [System.Drawing.Color]::FromArgb(255, 17, 18, 22),
        [System.Drawing.Color]::FromArgb(255, 48, 46, 55),
        35
    )
    $Graphics.FillEllipse($vinylBrush, $rect)
    $vinylBrush.Dispose()

    foreach ($offset in @(26, 48, 73, 101, 134)) {
        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(48, 245, 245, 239), 2)
        $Graphics.DrawEllipse($pen, $X + $offset, $Y + $offset, $Size - ($offset * 2), $Size - ($offset * 2))
        $pen.Dispose()
    }

    $labelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml($LabelColor))
    $Graphics.FillEllipse($labelBrush, $X + ($Size * 0.34), $Y + ($Size * 0.34), $Size * 0.32, $Size * 0.32)
    $labelBrush.Dispose()
}

function Save-Png {
    param($Bitmap, [string]$Name)
    $path = Join-Path $assetDir $Name
    $Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

$hero = New-Canvas 1800 1100
$g = $hero.Graphics
Add-LinearBackground $g 1800 1100 "#17151c" "#08080b"
Add-Glow $g 350 250 480 "#e04d67" 120
Add-Glow $g 1420 330 500 "#19b8b1" 100
Add-Glow $g 920 880 420 "#d6b85a" 88

$floorBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    [System.Drawing.Rectangle]::new(0, 665, 1800, 435),
    [System.Drawing.Color]::FromArgb(180, 244, 242, 232),
    [System.Drawing.Color]::FromArgb(8, 244, 242, 232),
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$g.FillRectangle($floorBrush, 0, 665, 1800, 435)
$floorBrush.Dispose()

for ($i = 0; $i -lt 18; $i++) {
    $x = 80 + ($i * 98)
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(28, 246, 241, 220), 2)
    $g.DrawLine($pen, $x, 670, $x + 180, 1100)
    $pen.Dispose()
}

Add-Vinyl $g 1110 515 360 "#e04d67"
Add-Vinyl $g 1250 410 280 "#16aaa4"

Add-HeartPath $g 720 430 18 "#f4f1e8" 205 18
Add-HeartPath $g 720 430 22 "#e04d67" 120 5
Add-HeartPath $g 720 430 27 "#19b8b1" 70 3

$wavePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(190, 244, 241, 232), 7)
$wavePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$wavePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
for ($i = 0; $i -lt 54; $i++) {
    $x = 230 + ($i * 18)
    $height = 22 + ([Math]::Abs([Math]::Sin($i * 0.48)) * 126) + ([Math]::Abs([Math]::Cos($i * 0.21)) * 42)
    $g.DrawLine($wavePen, $x, 785 - ($height / 2), $x, 785 + ($height / 2))
}
$wavePen.Dispose()

Add-Noise $hero.Bitmap 6
Save-Png $hero.Bitmap "silverheart-hero.png"
$g.Dispose()
$hero.Bitmap.Dispose()

$artistSpecs = @(
    @{ Name = "artist-luna-vale.png"; A = "#e04d67"; B = "#17151c"; C = "#f4f1e8"; Seed = 4 },
    @{ Name = "artist-neon-carter.png"; A = "#19b8b1"; B = "#101014"; C = "#d6b85a"; Seed = 9 },
    @{ Name = "artist-mika-rose.png"; A = "#d6b85a"; B = "#111017"; C = "#7fc060"; Seed = 15 },
    @{ Name = "artist-the-afterhours.png"; A = "#7a8cff"; B = "#101014"; C = "#e04d67"; Seed = 21 }
)

foreach ($spec in $artistSpecs) {
    $canvas = New-Canvas 960 960
    $g = $canvas.Graphics
    Add-LinearBackground $g 960 960 $spec.B "#050507"
    Add-Glow $g 235 220 310 $spec.A 150
    Add-Glow $g 760 690 360 $spec.C 115
    Add-Vinyl $g 120 170 610 $spec.A

    $random = New-Object System.Random($spec.Seed)
    for ($i = 0; $i -lt 12; $i++) {
        $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb($random.Next(70, 145), [System.Drawing.ColorTranslator]::FromHtml($spec.C)), $random.Next(2, 8))
        $x1 = $random.Next(80, 900)
        $y1 = $random.Next(60, 900)
        $x2 = $random.Next(80, 900)
        $y2 = $random.Next(60, 900)
        $g.DrawBezier($pen, $x1, $y1, ($x1 + $x2) / 2, $random.Next(40, 920), ($x1 + $x2) / 2, $random.Next(40, 920), $x2, $y2)
        $pen.Dispose()
    }

    Add-HeartPath $g 700 275 8 $spec.C 190 8
    $framePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(135, 244, 241, 232), 7)
    $g.DrawRectangle($framePen, 36, 36, 888, 888)
    $framePen.Dispose()

    Add-Noise $canvas.Bitmap 4
    Save-Png $canvas.Bitmap $spec.Name
    $g.Dispose()
    $canvas.Bitmap.Dispose()
}

Write-Host "Generated Silverheart Studios assets in $assetDir"
