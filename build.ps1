$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$templatePath = Join-Path $root "index.template.html"
$threePath = Join-Path $root "three.min.js"
$outputPath = Join-Path $root "index.html"

$template = Get-Content $templatePath -Raw
$three = Get-Content $threePath -Raw
$replacement = "<script>`n$three`n</script>"
$output = $template.Replace("<!-- THREE_INLINE -->", $replacement)
[System.IO.File]::WriteAllText($outputPath, $output, [System.Text.UTF8Encoding]::new($false))

Write-Output "Built $outputPath"
