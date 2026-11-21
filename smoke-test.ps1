param(
    [string]$Url,
    [int]$Width = 390,
    [int]$Height = 844,
    [int]$Scale = 2,
    [string]$Name = "mobile"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$artifacts = Join-Path $root "artifacts"
$screenshot = Join-Path $artifacts "$Name.png"
$domDump = Join-Path $artifacts "$Name-dom.txt"
$browserLog = Join-Path $artifacts "browser.log"
$browserStdout = Join-Path $artifacts "browser.out"
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

if (-not (Test-Path $edge)) {
    throw "Microsoft Edge is required for the smoke test."
}

New-Item -ItemType Directory -Path $artifacts -Force | Out-Null
Remove-Item $screenshot, $domDump, $browserLog, $browserStdout -Force -ErrorAction SilentlyContinue

if ([string]::IsNullOrWhiteSpace($Url)) {
    $htmlPath = Join-Path $root "index.html"
    if (-not (Test-Path $htmlPath)) {
        throw "index.html is missing."
    }

    $html = Get-Content $htmlPath -Raw
    if ($html -match '<(?:script|link)[^>]+(?:src|href)=["'']https?://') {
        throw "Remote script or stylesheet dependency found."
    }
    $target = ([System.Uri]$htmlPath).AbsoluteUri
} else {
    $target = $Url
}

$browserArgs = @(
    "--headless=new",
    "--no-first-run",
    "--disable-extensions",
    "--hide-scrollbars",
    "--enable-webgl",
    "--ignore-gpu-blocklist",
    "--use-angle=swiftshader",
    "--window-size=$Width,$Height",
    "--force-device-scale-factor=$Scale",
    "--virtual-time-budget=4000",
    "--screenshot=$screenshot",
    $target
)

$browser = Start-Process -FilePath $edge -ArgumentList $browserArgs -Wait -PassThru -WindowStyle Hidden `
    -RedirectStandardError $browserLog -RedirectStandardOutput $browserStdout
if ($browser.ExitCode -ne 0) {
    throw "Headless browser failed with exit code $($browser.ExitCode). See $browserLog."
}
if (-not (Test-Path $screenshot)) {
    throw "Headless browser did not produce a screenshot."
}

$screenshotInfo = Get-Item $screenshot
if ($screenshotInfo.Length -lt 10240) {
    throw "Screenshot is too small to contain the rendered scene: $($screenshotInfo.Length) bytes."
}

Add-Type -AssemblyName System.Drawing
$bitmap = [System.Drawing.Bitmap]::FromFile($screenshot)
try {
    $brightSamples = 0
    $topEdgeLimit = [Math]::Max(10, [int]($bitmap.Height * 0.06))
    for ($y = 0; $y -lt $bitmap.Height; $y += 16) {
        for ($x = 0; $x -lt $bitmap.Width; $x += 16) {
            $pixel = $bitmap.GetPixel($x, $y)
            if (($pixel.R + $pixel.G + $pixel.B) -gt 90) {
                $brightSamples++
            }
        }
    }
    $topEdgeBright = 0
    for ($y = 0; $y -lt $topEdgeLimit; $y += 2) {
        for ($x = 0; $x -lt $bitmap.Width; $x += 2) {
            $pixel = $bitmap.GetPixel($x, $y)
            if (($pixel.R + $pixel.G + $pixel.B) -gt 250) {
                $topEdgeBright++
            }
        }
    }
    if ($brightSamples -lt 40) {
        throw "Screenshot appears blank: only $brightSamples bright samples."
    }
    if ($topEdgeBright -gt 100) {
        throw "The tree appears cropped at the top edge: $topEdgeBright bright edge samples."
    }
} finally {
    $bitmap.Dispose()
}

$domArgs = @(
    "--headless=new",
    "--no-first-run",
    "--disable-extensions",
    "--enable-webgl",
    "--ignore-gpu-blocklist",
    "--use-angle=swiftshader",
    "--virtual-time-budget=4000",
    "--dump-dom",
    $target
)
Remove-Item $browserLog, $browserStdout -Force -ErrorAction SilentlyContinue
$browser = Start-Process -FilePath $edge -ArgumentList $domArgs -Wait -PassThru -WindowStyle Hidden `
    -RedirectStandardError $browserLog -RedirectStandardOutput $browserStdout
if ($browser.ExitCode -ne 0) {
    throw "DOM capture failed with exit code $($browser.ExitCode). See $browserLog."
}
$dom = Get-Content $browserStdout -Raw
Set-Content -Path $domDump -Value $dom -Encoding utf8
if ($dom -notmatch 'data-renderer-ready="true"') {
    throw "The renderer did not report a completed frame."
}
if ($dom -notmatch '>lyx<') {
    throw "The custom name text is not lyx."
}

Write-Output "PASS: $Name screenshot rendered with $brightSamples bright samples."
