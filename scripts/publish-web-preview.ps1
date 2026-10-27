$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$previewRepo = 'lee231-gia/limpyo-pisaan-preview'
$checkout = Join-Path $projectRoot 'artifacts/browser-preview-publish'
Push-Location (Join-Path $projectRoot 'flutter_app')
try {
    flutter build web --release --base-href /limpyo-pisaan-preview/ --no-web-resources-cdn
    if ($LASTEXITCODE -ne 0) { throw 'Flutter web build failed.' }
} finally { Pop-Location }
if (-not (Test-Path -LiteralPath (Join-Path $checkout '.git'))) {
    gh repo clone $previewRepo $checkout
    if ($LASTEXITCODE -ne 0) { throw 'Could not clone preview repository.' }
}
Push-Location $checkout
try {
    git pull --ff-only origin main
    if ($LASTEXITCODE -ne 0) { throw 'Could not update preview checkout.' }
    Copy-Item -Path (Join-Path $projectRoot 'flutter_app/build/web/*') -Destination $checkout -Recurse -Force
    Set-Content -LiteralPath (Join-Path $checkout '.nojekyll') -Value '' -NoNewline
    git add .
    git diff --cached --quiet
    if ($LASTEXITCODE -eq 1) {
        git commit -m 'Update interactive Limpyo Pisaan browser app'
        if ($LASTEXITCODE -ne 0) { throw 'Preview commit failed.' }
        git push origin main
        if ($LASTEXITCODE -ne 0) { throw 'Preview push failed.' }
    }
} finally { Pop-Location }
Write-Output 'Preview: https://lee231-gia.github.io/limpyo-pisaan-preview/'
