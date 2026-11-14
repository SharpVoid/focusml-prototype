$ErrorActionPreference = 'Stop'
$types = @{ '.svg' = 'image/svg+xml'; '.jpg' = 'image/jpeg'; '.png' = 'image/png'; '.woff2' = 'font/woff2' }
$source = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'prototype.html'))
$embedded = @{}
$page = [regex]::Replace($source, 'asset:([\w-]+\.(?:svg|jpg|png|woff2))', {
    param($match)
    $name = $match.Groups[1].Value
    if (!$embedded.ContainsKey($name)) {
        $bytes = [IO.File]::ReadAllBytes((Join-Path $PSScriptRoot "assets/$name"))
        $mime = $types[[IO.Path]::GetExtension($name)]
        $embedded[$name] = 'data:' + $mime + ';base64,' + [Convert]::ToBase64String($bytes)
    }
    $embedded[$name]
})
$offlineContent = $page.Replace('<a href="https://lisenkomisha.ru">', '<a>')
if ($offlineContent -match 'asset:[\w-]+\.' -or $offlineContent -match '[a-z]+://') { throw 'The prototype must be self-contained.' }
[IO.File]::WriteAllText((Join-Path $PSScriptRoot 'index.html'), $page)
