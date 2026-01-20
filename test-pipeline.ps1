# Quick test script for Jenkinsfile & Docker pipeline
# Run: powershell -ExecutionPolicy Bypass -File test-pipeline.ps1

$ErrorActionPreference = "Continue"
$testsPassed = 0
$testsFailed = 0

# Banner
Write-Host "════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "   Pipeline Test Suite" -ForegroundColor Magenta
Write-Host "   Testing Jenkinsfile + Docker Setup" -ForegroundColor Magenta
Write-Host "════════════════════════════════════════" -ForegroundColor Magenta

# Prerequisites
Write-Host "`n>>> Checking Prerequisites..." -ForegroundColor Yellow

Write-Host "`n[Java Installation]" -ForegroundColor Cyan
java -version 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Java not found" -ForegroundColor Red
    $testsFailed++
}

Write-Host "`n[Maven Installation]" -ForegroundColor Cyan
mvn -v 2>&1 | Select-Object -First 1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Maven not found" -ForegroundColor Red
    $testsFailed++
}

Write-Host "`n[Docker Installation]" -ForegroundColor Cyan
docker --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Docker not found" -ForegroundColor Red
    $testsFailed++
}

# Project Structure
Write-Host "`n>>> Checking Project Structure..." -ForegroundColor Yellow

Write-Host "`n[Jenkinsfile Exists]" -ForegroundColor Cyan
if (Test-Path "Jenkinsfile") {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Jenkinsfile not found" -ForegroundColor Red
    $testsFailed++
}

Write-Host "`n[Dockerfile Exists]" -ForegroundColor Cyan
if (Test-Path "Dockerfile") {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Dockerfile not found" -ForegroundColor Red
    $testsFailed++
}

Write-Host "`n[pom.xml Exists]" -ForegroundColor Cyan
if (Test-Path "pom.xml") {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: pom.xml not found" -ForegroundColor Red
    $testsFailed++
}

# Maven Build Tests
Write-Host "`n>>> Testing Maven Build Pipeline..." -ForegroundColor Yellow

Write-Host "`n[Maven Clean]" -ForegroundColor Cyan
mvn clean -q 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Maven clean failed" -ForegroundColor Red
    $testsFailed++
}

Write-Host "`n[Maven Compile]" -ForegroundColor Cyan
mvn compile -q 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Maven compile failed" -ForegroundColor Red
    $testsFailed++
}

Write-Host "`n[Maven Test]" -ForegroundColor Cyan
mvn test -q 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Maven test failed" -ForegroundColor Red
    $testsFailed++
}

Write-Host "`n[Maven Package]" -ForegroundColor Cyan
mvn package -DskipTests -q 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Maven package failed" -ForegroundColor Red
    $testsFailed++
}

# JAR Validation
Write-Host "`n>>> Testing JAR Artifact..." -ForegroundColor Yellow

Write-Host "`n[JAR File Created]" -ForegroundColor Cyan
$jar = Get-ChildItem -Path "target" -Filter "*.jar" -ErrorAction SilentlyContinue | Select-Object -First 1
if ($jar) {
    $sizeMB = [math]::Round($jar.Length / 1MB, 2)
    Write-Host "Found: $($jar.Name) ($sizeMB MB)"
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: No JAR file found in target/" -ForegroundColor Red
    $testsFailed++
}

Write-Host "`n[JAR Execution]" -ForegroundColor Cyan
if ($jar) {
    $output = java -jar $jar.FullName 2>&1
    if ($output -match "Hello") {
        Write-Host "Output: $output"
        Write-Host "✓ PASSED" -ForegroundColor Green
        $testsPassed++
    }
    else {
        Write-Host "✗ FAILED: JAR output unexpected" -ForegroundColor Red
        $testsFailed++
    }
}
else {
    Write-Host "JAR file not available for execution test" -ForegroundColor Yellow
}

# Docker Tests
Write-Host "`n>>> Testing Docker Build..." -ForegroundColor Yellow

Write-Host "`n[Docker Image Build]" -ForegroundColor Cyan
docker build -t simple-app:test -q . 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ PASSED - Image: simple-app:test" -ForegroundColor Green
    $testsPassed++
    
    Write-Host "`n[Docker Container Execution]" -ForegroundColor Cyan
    $containerId = docker run -d simple-app:test 2>&1
    Start-Sleep -Seconds 2
    $logs = docker logs $containerId 2>&1
    docker stop $containerId 2>&1 | Out-Null
    docker rm $containerId 2>&1 | Out-Null
    
    if ($logs -match "Hello") {
        Write-Host "Container output: $logs"
        Write-Host "✓ PASSED" -ForegroundColor Green
        $testsPassed++
    }
    else {
        Write-Host "✗ FAILED: Container output unexpected" -ForegroundColor Red
        $testsFailed++
    }
    
    # Cleanup
    docker image rm simple-app:test -f 2>&1 | Out-Null
}
else {
    Write-Host "✗ FAILED: Docker build failed" -ForegroundColor Red
    $testsFailed++
}

# Jenkinsfile Validation
Write-Host "`n>>> Validating Jenkinsfile..." -ForegroundColor Yellow

Write-Host "`n[Jenkinsfile Syntax]" -ForegroundColor Cyan
$content = Get-Content Jenkinsfile -Raw
if (($content -match "pipeline\s*\{") -and ($content -match "stages\s*\{") -and ($content -match "agent")) {
    Write-Host "Jenkinsfile structure valid"
    Write-Host "✓ PASSED" -ForegroundColor Green
    $testsPassed++
}
else {
    Write-Host "✗ FAILED: Jenkinsfile syntax invalid" -ForegroundColor Red
    $testsFailed++
}

# Summary
Write-Host "`n════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "           TEST SUMMARY" -ForegroundColor Magenta
Write-Host "════════════════════════════════════════" -ForegroundColor Magenta

$total = $testsPassed + $testsFailed
$percentage = if ($total -gt 0) { [math]::Round(($testsPassed / $total) * 100) } else { 0 }

Write-Host "`nTests Passed:  $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed:  $testsFailed" -ForegroundColor Red
Write-Host "Success Rate:  $percentage%" -ForegroundColor Yellow

if ($testsFailed -eq 0) {
    Write-Host "`n✓ ALL TESTS PASSED!" -ForegroundColor Green -BackgroundColor DarkGreen
    Write-Host "Ready for Jenkins deployment.`n" -ForegroundColor Green
}
else {
    Write-Host "`n✗ Some tests failed. Review errors above.`n" -ForegroundColor Red -BackgroundColor DarkRed
}
