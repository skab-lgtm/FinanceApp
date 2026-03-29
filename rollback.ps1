# Financial Command Center - Emergency Rollback Script
# Usage: .\rollback.ps1

$ErrorActionPreference = "Stop"

# Configuration
$REPO_DIR = "C:\GitHub Projects\Finance Tracker"
$MAIN_FILE = "index.html"
$BACKUP_FILE = "index-stable.html"
$BRANCH = "main"

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Red
Write-Host "  EMERGENCY ROLLBACK" -ForegroundColor Red
Write-Host "=========================================================" -ForegroundColor Red
Write-Host ""

Set-Location $REPO_DIR

# Check if backup exists
if (-not (Test-Path $BACKUP_FILE)) {
    Write-Host "Backup file not found: $BACKUP_FILE" -ForegroundColor Red
    Write-Host "Attempting to restore from git history..." -ForegroundColor Yellow
    Write-Host ""
    
    # Show recent commits
    Write-Host "Recent versions:" -ForegroundColor Yellow
    git log --oneline -10
    Write-Host ""
    
    $commitHash = Read-Host "Enter commit hash to restore (or press Enter for previous commit)"
    
    if ([string]::IsNullOrWhiteSpace($commitHash)) {
        $commitHash = "HEAD~1"
    }
    
    Write-Host "Restoring from commit: $commitHash" -ForegroundColor Yellow
    git checkout $commitHash -- $MAIN_FILE
    
} else {
    # Restore from backup file
    Write-Host "Found backup: $BACKUP_FILE" -ForegroundColor Yellow
    Write-Host ""
    
    # Show file sizes
    $currentSize = (Get-Item $MAIN_FILE).Length
    $backupSize = (Get-Item $BACKUP_FILE).Length
    
    Write-Host "Current version: $currentSize bytes"
    Write-Host "Backup version:  $backupSize bytes"
    Write-Host ""
    
    $confirm = Read-Host "Restore from backup? (y/n)"
    if ($confirm -ne "y") {
        Write-Host "Rollback cancelled" -ForegroundColor Red
        exit 0
    }
    
    # Create emergency backup of current broken version
    $brokenName = "$MAIN_FILE.broken-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    Write-Host "Backing up current (broken) version..." -ForegroundColor Yellow
    Copy-Item $MAIN_FILE $brokenName -Force
    
    # Restore backup
    Write-Host "Restoring backup..." -ForegroundColor Yellow
    Copy-Item $BACKUP_FILE $MAIN_FILE -Force
}

# Commit the rollback
Write-Host ""
Write-Host "Committing rollback..." -ForegroundColor Yellow
git add $MAIN_FILE
git commit -m "rollback: restore to working version"

# Push to GitHub
Write-Host ""
Write-Host "Pushing rollback to GitHub..." -ForegroundColor Yellow
git push origin $BRANCH

# Success
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "  ROLLBACK SUCCESSFUL" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Waiting for GitHub Pages to deploy (30s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30
Write-Host ""
Write-Host "Your site should now be restored" -ForegroundColor Green
Write-Host ""
