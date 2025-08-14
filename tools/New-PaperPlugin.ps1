[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,

    [string]$Package = "com.example.plugin",

    [ValidateSet("java", "kotlin")]
    [string]$Template = "java",

    [string]$ApiVersion = "1.20",

    [string]$PaperApi = "1.20.6-R0.1-SNAPSHOT",

    [string]$TargetDir
)

trap {
    Write-Error $_
    exit 1
}

$ErrorActionPreference = "Stop"

function Resolve-PathSafe([string]$path) {
    if (-not [string]::IsNullOrWhiteSpace($path)) {
        try { return (Resolve-Path -LiteralPath $path).Path } catch { return $path }
    }
    return (Get-Location).Path
}

function Replace-InFile([string]$filePath, [hashtable]$replacements) {
    try {
        $content = Get-Content -LiteralPath $filePath -Raw -ErrorAction Stop
    } catch {
        return
    }
    foreach ($key in $replacements.Keys) {
        $content = $content -replace [regex]::Escape($key), [string]$replacements[$key]
    }
    Set-Content -LiteralPath $filePath -Value $content -Encoding UTF8
}

function Is-TextFile([string]$filePath) {
    $textExt = @('.xml', '.kt', '.java', '.yml', '.yaml', '.properties', '.md', '.txt', '.gitignore')
    $ext = [System.IO.Path]::GetExtension($filePath)
    return $textExt -contains $ext
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-PathSafe (Join-Path $scriptDir "..")
$templatesDir = Join-Path $repoRoot "templates"

$templateFolder = if ($Template -ieq 'kotlin') { 'kotlin-paper' } else { 'java-paper' }
$templatePath = Join-Path $templatesDir $templateFolder

if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Template path not found: $templatePath"
}

$targetRoot = if ($TargetDir) { Resolve-PathSafe $TargetDir } else { (Get-Location).Path }
if (-not (Test-Path -LiteralPath $targetRoot)) { New-Item -ItemType Directory -Path $targetRoot | Out-Null }

$projectDir = Join-Path $targetRoot $Name
if (Test-Path -LiteralPath $projectDir) {
    throw "Target project directory already exists: $projectDir"
}
New-Item -ItemType Directory -Path $projectDir | Out-Null

Write-Host "Copying template '$templateFolder' to '$projectDir'..."
Copy-Item -Path (Join-Path $templatePath '*') -Destination $projectDir -Recurse -Force

$mainClass = "$Package.$Name"

$replacements = @{ 
    '__PLUGIN_NAME__'       = $Name
    '__BASE_PACKAGE__'      = $Package
    '__API_VERSION__'       = $ApiVersion
    '__PAPER_API_VERSION__' = $PaperApi
    '__MAIN_CLASS__'        = $mainClass
}

Get-ChildItem -Path $projectDir -Recurse -File | Where-Object { Is-TextFile $_.FullName } | ForEach-Object {
    Replace-InFile -filePath $_.FullName -replacements $replacements
}

$lang = if ($Template -ieq 'kotlin') { 'kotlin' } else { 'java' }
$srcBase = Join-Path $projectDir ("src\main\$lang")
$defaultPkgPath = Join-Path $srcBase ("com\example\plugin")
if (-not (Test-Path -LiteralPath $defaultPkgPath)) {
    throw "Default package path not found: $defaultPkgPath"
}

$destPkgPath = Join-Path $srcBase ($Package -replace '\.', '\\')
New-Item -ItemType Directory -Path $destPkgPath -Force | Out-Null

Write-Host "Placing sources under package '$Package'..."
Get-ChildItem -Path $defaultPkgPath -File | ForEach-Object {
    Move-Item -LiteralPath $_.FullName -Destination (Join-Path $destPkgPath $_.Name) -Force
}

if (Test-Path -LiteralPath $defaultPkgPath) {
    Remove-Item -LiteralPath $defaultPkgPath -Recurse -Force -ErrorAction SilentlyContinue
    $defaultComPath = Join-Path $srcBase 'com'
    if ((Get-ChildItem -LiteralPath $defaultComPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
        Remove-Item -LiteralPath $defaultComPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Rename main class file
$defaultMainJava = Join-Path $destPkgPath 'MyPlugin.java'
$defaultMainKt = Join-Path $destPkgPath 'MyPlugin.kt'
if (Test-Path -LiteralPath $defaultMainJava) {
    Rename-Item -LiteralPath $defaultMainJava -NewName ("$Name.java") -Force
}
if (Test-Path -LiteralPath $defaultMainKt) {
    Rename-Item -LiteralPath $defaultMainKt -NewName ("$Name.kt") -Force
}

Write-Host "Done. Project created at: $projectDir" -ForegroundColor Green
Write-Host "Next steps:"
Write-Host "  1) cd `"$projectDir`""
Write-Host "  2) mvn -q -DskipTests package"
Write-Host "  3) Поместите JAR из target на сервер Paper"


