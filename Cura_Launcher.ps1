# Cura_Launcher.ps1
# Simple terminal menu to pick which Cura to open.

# TODO: EDIT THESE NOTES for all newly installed Cura instances
$curaNotes = @{
  "5.3.1" = "Chris' version"
  "5.7.1" = "Leo's version"
  "5.14.0" = "Carey's version"
}

# Check whether path exists
function CheckPathExists($p) {
  if (-not (Test-Path $p)) {
    Write-Host ""
    Write-Host "ERROR: Not found:" -ForegroundColor Red
    Write-Host "  $p" -ForegroundColor Yellow
    Write-Host ""
    return $false
  } else {
    return $true
  }
}

# Launch the specified Cura version, first assuming default path, and ask for path if fails
function LaunchCura($ver) {
  $defaultPath = "C:\Program Files\UltiMaker Cura $ver\UltiMaker-Cura.exe"
  if (CheckPathExists $defaultPath) {
    Start-Process -FilePath $defaultPath
  } else {
    while (1) {
      $actualPath = Read-Host "Specify the correct path to the executable: "
      if (CheckPathExists $actualPath) {
        break
      }
    }
    Start-Process -FilePath $actualPath
  }
}

Clear-Host

# Welcome message
Write-Host "======================" -ForegroundColor Cyan
Write-Host " Cura Version Selector " -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""

# Get all available versions assuming default path
$curaVersions = [System.Collections.Generic.List[string]]::new()
Get-ChildItem -Path "C:\Program Files\" -Filter "UltiMaker Cura *" | ForEach-Object {
  $ver = ($_.Name -split " ")[-1]   # get version number from last segment assuming standard format
  $note = ""   # default value, if a version does not have a note
  if ($curaNotes.ContainsKey($ver)) {
    $noteRaw = $curaNotes[$ver]
    $note = "($noteRaw)"   # add parentheses for output
  } else {
    Write-Warning "Cura $ver does not have a note. Please edit this script to add the note."
  }
  $curaVersions.Add($ver)
  Write-Host "$($curaVersions.Count)) Cura $ver $note  -> C:\Program Files\UltiMaker Cura $ver\UltiMaker-Cura.exe"
}
Write-Host ""
Write-Host "O) Other Cura versions"
Write-Host "Q) Quit"
Write-Host ""

$choice = Read-Host "Select (selection number/O/Q)"

switch ($choice.ToUpper()) {
  "O" {
    $ver = Read-Host "Specify the version number you want to open: "
    LaunchCura $ver
  }
  "Q" { exit 0 }
  default {
    $choiceNum = $choice -as [int]   # if conversion fails, return `$null`
    if ($null -ne $choiceNum) {
      $ver = $curaVersions[$choice - 1]
      LaunchCura $ver
    } else {
      Write-Host "Invalid selection." -ForegroundColor Yellow
      Start-Sleep -Seconds 1
    }
  }
}
