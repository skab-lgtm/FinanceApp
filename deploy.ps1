# Financial Command Center - Deploy Script
# Usage: .\deploy.ps1 "commit message"

$ErrorActionPreference = "Stop"

# Configuration
$REPO_DIR = "C:\GitHub Projects\Finance Tracker"
$MAIN_FILE = "index.html"
$BACKUP_FILE = "index-stable.html"
$VERSION_DIR = "versions"
$BRANCH = "main"

# Version from timestamp
$VERSION = Get-Date -Format "yyyyMMdd-HHmmss"
$COMMIT_MSG = if ($args.Count -gt 0) { $args[0] } else { "Update: Auto-deploy $VERSION" }

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "  Financial Command Center - Deployment" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""

Set-Location $REPO_DIR

# Check if there are changes
$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
    Write-Host "No changes detected" -ForegroundColor Yellow
    $continue = Read-Host "Continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit 0
    }
}

# Create versions directory if it doesn't exist
New-Item -ItemType Directory -Force -Path $VERSION_DIR | Out-Null

# Backup current production version
Write-Host "Creating backup of current version..." -ForegroundColor Yellow
if (Test-Path $MAIN_FILE) {
    Copy-Item $MAIN_FILE $BACKUP_FILE -Force
    Copy-Item $MAIN_FILE "$VERSION_DIR\v$VERSION.html" -Force
    Write-Host "Backup created: $BACKUP_FILE" -ForegroundColor Green
    Write-Host "Archived: $VERSION_DIR\v$VERSION.html" -ForegroundColor Green
} else {
    Write-Host "$MAIN_FILE not found" -ForegroundColor Red
    exit 1
}

# Stage changes
Write-Host ""
Write-Host "Staging changes..." -ForegroundColor Yellow
git add .
Write-Host "Changes staged" -ForegroundColor Green

# Show what's being committed
Write-Host ""
Write-Host "Changes to be committed:" -ForegroundColor Yellow
git status --short

# Confirm deployment
Write-Host ""
$deploy = Read-Host "Deploy these changes? (y/n)"
if ($deploy -ne "y") {
    Write-Host "Deployment cancelled" -ForegroundColor Red
    exit 0
}

# Commit
Write-Host ""
Write-Host "Committing changes..." -ForegroundColor Yellow
git commit -m "$COMMIT_MSG"
Write-Host "Committed: $COMMIT_MSG" -ForegroundColor Green

# Tag the version
Write-Host ""
Write-Host "Tagging version v$VERSION..." -ForegroundColor Yellow
git tag -a "v$VERSION" -m "Version $VERSION"
Write-Host "Tagged: v$VERSION" -ForegroundColor Green

# Push to GitHub
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push origin $BRANCH
git push origin --tags
Write-Host "Pushed to GitHub" -ForegroundColor Green

# Wait for GitHub Pages
Write-Host ""
Write-Host "Waiting for GitHub Pages to deploy (30s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Success
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT SUCCESSFUL" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Version: v$VERSION" -ForegroundColor Green
Write-Host "Backup:  $BACKUP_FILE" -ForegroundColor Green
Write-Host ""
Write-Host "Your site should be live at:" -ForegroundColor Yellow
Write-Host "   https://skab-lgtm.github.io/FinanceApp/"
Write-Host ""
Write-Host "Rollback command if needed:" -ForegroundColor Yellow
Write-Host "   .\rollback.ps1" -ForegroundColor Green
Write-Host ""
