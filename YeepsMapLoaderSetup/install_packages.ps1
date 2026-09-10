param(
    [string]$ProjectPath = "."
)

$manifestPath = Join-Path $ProjectPath "Packages\manifest.json"

if (-not (Test-Path $manifestPath)) {
    Write-Error "Could not find $manifestPath -- pass -ProjectPath pointing at the Unity project root (the folder containing Assets\ and Packages\)."
    exit 1
}

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

$toAdd = [ordered]@{
    "com.unity.formats.fbx" = "5.1.6"
    "com.unity.ugui"        = "2.0.0"
}

$changed = $false
foreach ($pkg in $toAdd.Keys) {
    if (-not ($manifest.dependencies.PSObject.Properties.Name -contains $pkg)) {
        $manifest.dependencies | Add-Member -NotePropertyName $pkg -NotePropertyValue $toAdd[$pkg]
        Write-Output "Added $pkg $($toAdd[$pkg])"
        $changed = $true
    } else {
        Write-Output "$pkg already present, skipping"
    }
}

if ($changed) {
    $json = $manifest | ConvertTo-Json -Depth 10
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($manifestPath, $json, $utf8NoBom)
    Write-Output ""
    Write-Output "manifest.json updated. Open (or re-open) the project in Unity -- it will resolve and install these automatically."
    Write-Output "Once TextMeshPro is in, run Window > TextMeshPro > Import TMP Essential Resources."
} else {
    Write-Output "Nothing to do -- all packages already listed."
}

$assetsPath = Join-Path $ProjectPath "Assets"
$duplicateNames = @("Unity.TextMeshPro", "Unity.Timeline", "UnityEngine.UI")
$backupPath = Join-Path $ProjectPath "_RemovedDuplicatePackages"
$movedAny = $false

foreach ($name in $duplicateNames) {
    $hit = Get-ChildItem -Path $assetsPath -Directory -Recurse -Filter $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($hit) {
        if (-not (Test-Path $backupPath)) { New-Item -ItemType Directory -Path $backupPath | Out-Null }
        $dest = Join-Path $backupPath $name
        Move-Item -Path $hit.FullName -Destination $dest -Force
        $metaPath = "$($hit.FullName).meta"
        if (Test-Path $metaPath) { Move-Item -Path $metaPath -Destination "$dest.meta" -Force }
        Write-Output "Moved duplicate loose package source '$name' out of Assets (was conflicting with the real installed package) -> $backupPath"
        $movedAny = $true
    }
}

if ($movedAny) {
    Write-Output ""
    Write-Output "Some full-source AssetRipper exports ship a loose copy of Unity's own package source (TextMeshPro, Timeline, UnityEngine.UI) directly under Assets, which conflicts with the real package once installed ('Assembly with name ... already exists'). Those loose copies were moved to $backupPath -- safe to delete once you've confirmed the project compiles."
}

$graphicsSettingsPath = Join-Path $ProjectPath "ProjectSettings\GraphicsSettings.asset"
$qualitySettingsPath  = Join-Path $ProjectPath "ProjectSettings\QualitySettings.asset"
$rpFixed = $false

if (Test-Path $graphicsSettingsPath) {
    $text = Get-Content $graphicsSettingsPath -Raw
    $newText = $text -replace '(?m)^(\s*m_CustomRenderPipeline:\s*)\{fileID: \d+.*\}', '${1}{fileID: 0}'
    if ($newText -ne $text) {
        [System.IO.File]::WriteAllText($graphicsSettingsPath, $newText, (New-Object System.Text.UTF8Encoding $false))
        Write-Output "Cleared dangling render pipeline reference in GraphicsSettings.asset"
        $rpFixed = $true
    }
}

if (Test-Path $qualitySettingsPath) {
    $text = Get-Content $qualitySettingsPath -Raw
    $newText = $text -replace '(?m)^(\s*customRenderPipeline:\s*)\{fileID: \d+.*\}', '${1}{fileID: 0}'
    if ($newText -ne $text) {
        [System.IO.File]::WriteAllText($qualitySettingsPath, $newText, (New-Object System.Text.UTF8Encoding $false))
        Write-Output "Cleared dangling render pipeline reference in QualitySettings.asset"
        $rpFixed = $true
    }
}

if ($rpFixed) {
    Write-Output ""
    Write-Output "This export references a render pipeline asset (URP) that isn't actually installed, which crashes Unity the moment you open the Game view. That reference has been cleared so the project falls back to the Built-in Render Pipeline instead."
}
