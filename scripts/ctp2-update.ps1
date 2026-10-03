# Download or update the Call to Power II (ctp2) Freeciv mod and install
# its ruleset for an installed Freeciv 3.2.x on Windows.
#
# Usage (PowerShell):
#   powershell -ExecutionPolicy Bypass -File ctp2-update.ps1
#   powershell -ExecutionPolicy Bypass -File ctp2-update.ps1 -Branch claude/some-branch
#
# Requires git (https://git-scm.com/download/win).

param(
  [string]$RepoUrl = "https://github.com/kognar-dev/freeciv.git",
  [string]$Branch = "3.2.6",
  [string]$RepoDir = "$env:USERPROFILE\src\freeciv-ctp2",
  [string]$UserData = "$env:APPDATA\.freeciv\3.2"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw "git is required: https://git-scm.com/download/win"
}

# 1. Get or update the source
if (Test-Path "$RepoDir\.git") {
  Write-Host "==> Updating $RepoDir ($Branch)"
  if (git -C $RepoDir status --porcelain --untracked-files=no) {
    throw "Local changes in $RepoDir, not updating. Commit or stash them first."
  }
  git -C $RepoDir fetch origin $Branch
  if ($LASTEXITCODE -ne 0) { throw "git fetch failed" }
  git -C $RepoDir checkout -q -B $Branch "origin/$Branch"
  if ($LASTEXITCODE -ne 0) { throw "git checkout failed" }
} else {
  Write-Host "==> Cloning $RepoUrl ($Branch) into $RepoDir"
  New-Item -ItemType Directory -Force -Path (Split-Path $RepoDir) | Out-Null
  git clone --branch $Branch $RepoUrl $RepoDir
  if ($LASTEXITCODE -ne 0) { throw "git clone failed" }
}
Write-Host ("    Now at: " + (git -C $RepoDir log -1 --format="%h %s"))

# 2. Install the ruleset into the user data directory
Write-Host "==> Installing ctp2 ruleset into $UserData"
New-Item -ItemType Directory -Force -Path $UserData | Out-Null
if (Test-Path "$UserData\ctp2") { Remove-Item -Recurse -Force "$UserData\ctp2" }
Copy-Item -Recurse "$RepoDir\data\ctp2" "$UserData\ctp2"
Copy-Item "$RepoDir\data\ctp2.modpack" $UserData
Remove-Item -Force -ErrorAction SilentlyContinue "$UserData\ctp2\Makefile.am", "$UserData\ctp2\.gitignore"

Write-Host "==> Done. In a new game, type '/rulesetdir ctp2' before starting."
