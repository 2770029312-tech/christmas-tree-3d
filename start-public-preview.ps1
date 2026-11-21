$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$artifacts = Join-Path $root "artifacts"
$serverOut = Join-Path $artifacts "server.out.log"
$serverErr = Join-Path $artifacts "server.err.log"
$tunnelOut = Join-Path $artifacts "tunnel.out.log"
$tunnelErr = Join-Path $artifacts "tunnel.err.log"
$python = "D:\Christmas-Tree-main\.venv\Scripts\python.exe"
$cloudflared = "C:\Program Files (x86)\cloudflared\cloudflared.exe"

New-Item -ItemType Directory -Path $artifacts -Force | Out-Null
Remove-Item $serverOut, $serverErr, $tunnelOut, $tunnelErr -Force -ErrorAction SilentlyContinue

$server = Start-Process -FilePath $python `
    -ArgumentList @("-m", "http.server", "8765", "--bind", "127.0.0.1", "--directory", $root) `
    -WorkingDirectory $root `
    -WindowStyle Hidden `
    -RedirectStandardOutput $serverOut `
    -RedirectStandardError $serverErr `
    -PassThru

Start-Sleep -Seconds 1
if ($server.HasExited) {
    throw "The local server failed to start: $(Get-Content $serverErr -Raw)"
}

$tunnel = Start-Process -FilePath $cloudflared `
    -ArgumentList @("tunnel", "--no-autoupdate", "--url", "http://127.0.0.1:8765") `
    -WindowStyle Hidden `
    -RedirectStandardOutput $tunnelOut `
    -RedirectStandardError $tunnelErr `
    -PassThru

$publicUrl = $null
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Milliseconds 500
    if (Test-Path $tunnelErr) {
        $text = Get-Content $tunnelErr -Raw
        $match = [regex]::Match($text, "https://[a-z0-9-]+\.trycloudflare\.com")
        if ($match.Success) {
            $publicUrl = $match.Value
            break
        }
    }
    if ($tunnel.HasExited) {
        throw "The public tunnel exited before a URL was created: $(Get-Content $tunnelErr -Raw)"
    }
}

if (-not $publicUrl) {
    throw "The public tunnel did not create a URL in time. See $tunnelErr."
}

[pscustomobject]@{
    Url = $publicUrl
    ServerPid = $server.Id
    TunnelPid = $tunnel.Id
} | ConvertTo-Json
