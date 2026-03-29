# Claude to GitHub Sync Script
# Copies latest file from Downloads to repo and deploys

# Configuration
$REPO_DIR = "C:\GitHub Projects\Finance Tracker"
$DOWNLOADS_DIR = "$env:USERPROFILE\Downloads"
$MAIN_FILE = "index.html"

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "  Claude to GitHub Sync" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""

# Find most recent HTML file in Downloads
Write-Host "Looking for latest file in Downloads..." -ForegroundColor Yellow

$latestFile = Get-ChildItem "$DOWNLOADS_DIR\*.html" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1

if (-not $latestFile) {
    Write-Host "No HTML files found in Downloads" -ForegroundColor Red
    exit 1
}

Write-Host "Found: $($latestFile.Name)" -ForegroundColor Green
Write-Host ""

# Show file info
Write-Host "File: $($latestFile.Name)"
Write-Host "Size: $($latestFile.Length) bytes"
Write-Host "Date: $($latestFile.LastWriteTime)"
Write-Host ""

# Confirm
$confirm = Read-Host "Copy this file to repo and deploy? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Cancelled" -ForegroundColor Red
    exit 0
}

# Check if repo exists
if (-not (Test-Path $REPO_DIR)) {
    Write-Host "Repository directory doesn't exist: $REPO_DIR" -ForegroundColor Red
    Write-Host "Run setup.ps1 first!" -ForegroundColor Yellow
    exit 1
}

Set-Location $REPO_DIR

# Copy file
Write-Host ""
Write-Host "Copying file to repo..." -ForegroundColor Yellow
Copy-Item $latestFile.FullName $MAIN_FILE -Force
Write-Host "Copied to $REPO_DIR\$MAIN_FILE" -ForegroundColor Green
Write-Host ""

# Get commit message
Write-Host "Running deployment..." -ForegroundColor Yellow
Write-Host ""

$commitMsg = Read-Host "Commit message (or press Enter for default)"

if ([string]::IsNullOrWhiteSpace($commitMsg)) {
    $commitMsg = "Update from Claude: " + (Get-Date -Format "yyyy-MM-dd HH:mm")
}

# Run deploy script if it exists
if (Test-Path "deploy.ps1") {
    .\deploy.ps1 "$commitMsg"
} else {
    # Manual deployment
    git add $MAIN_FILE
    git commit -m "$commitMsg"
    git push origin main
    Write-Host "Deployed" -ForegroundColor Green
}

Write-Host ""
Write-Host "Sync complete!" -ForegroundColor Green
