param(
    [string]$BaseUrl = "https://sulahmitra.in"
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$baseUrl = $BaseUrl.TrimEnd("/")
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Download-RemoteFile {
    param(
        [Parameter(Mandatory = $true)][string]$Url,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    $destinationDir = Split-Path -Parent $Destination
    if ($destinationDir) {
        New-Item -ItemType Directory -Force -Path $destinationDir | Out-Null
    }

    try {
        Invoke-WebRequest -Uri $Url -OutFile $Destination
        return $true
    }
    catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 404) {
            Write-Warning "Skipped missing URL: $Url"
            return $false
        }

        throw
    }
}

function Get-PageUrl {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    if ($RelativePath -eq "index.html") {
        return "$baseUrl/"
    }

    $relativeDirectory = (Split-Path -Parent $RelativePath) -replace "\\", "/"
    return "$baseUrl/$relativeDirectory/"
}

function Normalize-Html {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath
    )

    $content = [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
    $content = $content -replace "https?://www\.sulahmitra\.in", ""
    $content = $content -replace "https?://sulahmitra\.in", ""

    $content = [regex]::Replace(
        $content,
        '<script data-no-optimize="1">var litespeed_vary=.*?</script>',
        "",
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    $content = [regex]::Replace(
        $content,
        '<script defer src="https://static\.cloudflareinsights\.com/.*?</script>',
        "",
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )

    [System.IO.File]::WriteAllText($FilePath, $content, $utf8NoBom)
}

$htmlFiles = Get-ChildItem -Path $repoRoot -Recurse -Filter "index.html" |
    Where-Object { $_.FullName -notmatch "\\tmp_" } |
    Sort-Object FullName

foreach ($htmlFile in $htmlFiles) {
    $relativePath = $htmlFile.FullName.Substring($repoRoot.Length + 1)
    $pageUrl = Get-PageUrl -RelativePath $relativePath
    $null = Download-RemoteFile -Url $pageUrl -Destination $htmlFile.FullName
}

$topLevelFiles = Get-ChildItem -Path $repoRoot -File |
    Where-Object { $_.Name -match '^(robots\.txt|sitemap.*\.xml|page-sitemap\.xml|main-sitemap\.xsl)$' }

foreach ($topLevelFile in $topLevelFiles) {
    $fileUrl = "$baseUrl/$($topLevelFile.Name)"
    $null = Download-RemoteFile -Url $fileUrl -Destination $topLevelFile.FullName
}

foreach ($htmlFile in $htmlFiles) {
    Normalize-Html -FilePath $htmlFile.FullName
}

$assetPattern = '/[^"''\s<>()]+?\.(?:css|js|png|jpe?g|gif|svg|webp|avif|ico|xml|xsl|txt|woff2?|ttf|eot|json)(?:\?[^"''\s<>()]*)?'
$regexOptions = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
$assetPaths = New-Object System.Collections.Generic.HashSet[string]

foreach ($htmlFile in $htmlFiles) {
    $content = [System.IO.File]::ReadAllText($htmlFile.FullName, [System.Text.Encoding]::UTF8)
    $matches = [regex]::Matches($content, $assetPattern, $regexOptions)
    foreach ($match in $matches) {
        $assetPath = $match.Value.Split("?")[0]
        if ($assetPath.StartsWith("/")) {
            $null = $assetPaths.Add($assetPath)
        }
    }
}

foreach ($assetPath in ($assetPaths | Sort-Object)) {
    $localAssetPath = Join-Path $repoRoot $assetPath.TrimStart("/")
    if (-not (Test-Path $localAssetPath)) {
        $null = Download-RemoteFile -Url "$baseUrl$assetPath" -Destination $localAssetPath
    }
}
