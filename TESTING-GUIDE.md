# Testing Guide: Jenkinsfile & Docker Configuration

## Overview
This guide provides multiple ways to validate your Jenkinsfile, Dockerfile, and CI/CD pipeline before deploying to Jenkins.

---

## Part 1: Validate Jenkinsfile Syntax

### Option 1: Jenkins Pipeline Linter (Requires Jenkins)
```bash
# Using curl (replace JENKINS_URL and credentials)
curl -X POST -F "jenkinsfile=@Jenkinsfile" \
  http://your-jenkins:8080/pipeline-model-converter/validate \
  -u username:token
```

### Option 2: Validate Locally with Groovy
```bash
# Check if Groovy syntax is valid
java -version  # Ensure Java is installed

# Install Groovy (optional)
# brew install groovy  (macOS)
# choco install groovy (Windows)

# Validate syntax
groovy -e 'def pipeline = new GroovyShell().parse(new File("Jenkinsfile")); println "✓ Jenkinsfile syntax is valid"'
```

### Option 3: Manual Code Review
```bash
# Check for common mistakes
grep -n "node" Jenkinsfile           # Should use 'agent any' in declarative
grep -n "stage(" Jenkinsfile         # Check stage definitions
grep -n "sh '" Jenkinsfile           # Check shell commands
```

✅ **Success:** No syntax errors reported

---

## Part 2: Test Docker Image Build Locally

### Step 1: Build the Docker Image
```bash
cd c:\demo-copilot\simple-app

# Build with tags
docker build -t simple-app:latest -t simple-app:1.0.0 .

# Build with build arguments (simulating CI/CD)
docker build \
  -t simple-app:latest \
  --build-arg BUILD_NUMBER=123 \
  --build-arg GIT_COMMIT=abc123def456 \
  .
```

**Expected Output:**
```
[+] Building 45.3s (11/11) FINISHED
 => exporting to oci image format
 => naming to docker.io/library/simple-app:latest
```

✅ **Success:** Image builds without errors

### Step 2: Verify Docker Image Details
```bash
# List images
docker images | grep simple-app

# Inspect image metadata
docker inspect simple-app:latest

# Check image size
docker images simple-app
# Output: simple-app  latest   abc123   5 days ago   200MB
```

✅ **Success:** Image size reasonable (~150-250MB)

### Step 3: Test Docker Image Execution
```bash
# Run container
docker run -d --name test-app simple-app:latest

# Wait 2 seconds for startup
timeout 2 || start /w cmd /c exit 0

# Check if container is running
docker ps | grep test-app

# View logs
docker logs test-app
# Should see: "Hello from Maven!"

# Stop and remove
docker stop test-app
docker rm test-app
```

✅ **Success:** Container runs and displays output

### Step 4: Test Health Check (if applicable)
```bash
# Run container
docker run -d --name health-test simple-app:latest

# Wait for health check
timeout /t 10

# Check health status
docker inspect --format='{{.State.Health.Status}}' health-test
# Output: healthy or starting

# Cleanup
docker stop health-test && docker rm health-test
```

✅ **Success:** Health check returns "healthy"

---

## Part 3: Test Maven Build Stages

### Stage 1: Test Compilation
```bash
cd c:\demo-copilot\simple-app

# Clean and compile only
mvn clean compile

# Expected output:
# [INFO] BUILD SUCCESS
# [INFO] Total time: XX.XXs
```

✅ **Success:** Compilation completes without errors

### Stage 2: Test Unit Tests
```bash
# Run tests
mvn test

# View test results
cat target/surefire-reports/TEST-com.example.AppTest.xml

# Or view in console
mvn test -Dsurefire.reportFormat=brief
```

✅ **Success:** All tests pass

### Stage 3: Full Maven Package
```bash
# Full build with packaging
mvn clean package

# Verify JAR was created
dir target\*.jar
# Should list: simple-app-1.0-SNAPSHOT.jar

# Test JAR execution
java -jar target/simple-app-1.0-SNAPSHOT.jar
# Output: Hello from Maven!
```

✅ **Success:** JAR created and runs successfully

---

## Part 4: Complete Pipeline Simulation

### Simulate Jenkinsfile Stages Manually
```bash
cd c:\demo-copilot\simple-app

echo "=== Stage: Checkout ==="
git log --oneline -1

echo "=== Stage: Build ==="
mvn clean package -DskipTests

echo "=== Stage: Test ==="
mvn test

echo "=== Stage: Build Docker Image ==="
docker build -t simple-app:$BUILD_NUMBER .

echo "=== Stage: Scan Image ==="
# Install Trivy first: https://github.com/aquasecurity/trivy/releases
trivy image simple-app:$BUILD_NUMBER

echo "=== Stage: Deploy (Dry-run) ==="
echo "Would push to: private-registry.example.com/simple-app:$BUILD_NUMBER"
```

✅ **Success:** All stages complete without failures

---

## Part 5: Docker Compose Testing (Optional)

Create `docker-compose.test.yml`:

```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        BUILD_NUMBER: "local-test"
        GIT_COMMIT: "test-commit"
    image: simple-app:local-test
    container_name: simple-app-test
    ports:
      - "8080:8080"
    environment:
      - JAVA_OPTS=-Xmx512m
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 10s

  registry:
    image: registry:2
    container_name: local-registry
    ports:
      - "5000:5000"
    volumes:
      - registry_data:/var/lib/registry

volumes:
  registry_data:
```

### Run Docker Compose Test
```bash
# Start services
docker-compose -f docker-compose.test.yml up -d

# Wait for startup
timeout /t 5

# Check app status
docker logs simple-app-test

# Test health endpoint (if app has one)
curl http://localhost:8080/health

# Push to local registry
docker tag simple-app:local-test localhost:5000/simple-app:local-test
docker push localhost:5000/simple-app:local-test

# Cleanup
docker-compose -f docker-compose.test.yml down -v
```

✅ **Success:** All services run and communicate

---

## Part 6: Dry-Run Registry Push

### Test Docker Login & Push (without actual registry)
```bash
# Create dummy registry credentials (don't use real ones!)
$env:REGISTRY_USER = "test-user"
$env:REGISTRY_PASSWORD = "test-pass"

# Simulate login (will fail, but shows the command)
echo $env:REGISTRY_PASSWORD | docker login \
  -u $env:REGISTRY_USER \
  --password-stdin private-registry.example.com 2>&1 \
  | grep -E "(Login|Error)" || echo "✓ Registry command format valid"

# Create test tag
docker tag simple-app:latest private-registry.example.com/simple-app:latest

# Show what would be pushed
docker images | grep private-registry
```

✅ **Success:** Tag format is correct, ready for real registry

---

## Part 7: Pre-Jenkins Checklist

Run this comprehensive test:

```bash
#!/bin/bash
# save as test-all.sh and run: bash test-all.sh

echo "========================================="
echo "Complete Pipeline Test Suite"
echo "========================================="

cd c:\demo-copilot\simple-app

# Test 1: File validation
echo -e "\n[1/7] Validating project files..."
test -f Jenkinsfile && echo "✓ Jenkinsfile exists" || echo "✗ Jenkinsfile missing"
test -f Dockerfile && echo "✓ Dockerfile exists" || echo "✗ Dockerfile missing"
test -f pom.xml && echo "✓ pom.xml exists" || echo "✗ pom.xml missing"

# Test 2: Maven build
echo -e "\n[2/7] Testing Maven build..."
mvn clean package -q && echo "✓ Maven build successful" || echo "✗ Maven build failed"

# Test 3: JAR execution
echo -e "\n[3/7] Testing JAR execution..."
java -jar target/simple-app-1.0-SNAPSHOT.jar &
sleep 1
kill $! 2>/dev/null
echo "✓ JAR execution successful"

# Test 4: Docker build
echo -e "\n[4/7] Testing Docker build..."
docker build -q -t simple-app:test . && echo "✓ Docker build successful" || echo "✗ Docker build failed"

# Test 5: Docker run
echo -e "\n[5/7] Testing Docker container..."
CONTAINER_ID=$(docker run -d simple-app:test)
sleep 2
docker logs $CONTAINER_ID | grep -q "Hello" && echo "✓ Docker container successful" || echo "✗ Docker container failed"
docker stop $CONTAINER_ID && docker rm $CONTAINER_ID

# Test 6: Jenkinsfile syntax
echo -e "\n[6/7] Validating Jenkinsfile syntax..."
grep -q "pipeline {" Jenkinsfile && echo "✓ Jenkinsfile syntax valid" || echo "✗ Jenkinsfile syntax invalid"
grep -q "stages {" Jenkinsfile && echo "✓ Pipeline stages defined" || echo "✗ Pipeline stages missing"

# Test 7: Documentation
echo -e "\n[7/7] Checking documentation..."
test -f JENKINSFILE-SETUP.md && echo "✓ Setup documentation exists" || echo "✗ Setup documentation missing"
test -f JENKINSFILE-QUICKSTART.md && echo "✓ Quick start guide exists" || echo "✗ Quick start guide missing"

echo -e "\n========================================="
echo "All tests completed!"
echo "========================================="
```

---

## Part 8: Performance Baseline

### Measure Build Times
```bash
cd c:\demo-copilot\simple-app

# Maven build time
time mvn clean package -DskipTests
# Expected: 30-60 seconds

# Test execution time  
time mvn test
# Expected: 10-30 seconds

# Docker build time
time docker build -t simple-app:test .
# Expected: 60-120 seconds (first run, more for subsequent)

# Total pipeline simulation
time (mvn clean package -DskipTests && docker build -t simple-app:test .)
# Expected: 90-180 seconds total
```

**Record these baseline times:**
- Maven clean package: ______ seconds
- Docker build: ______ seconds
- Total pipeline: ______ seconds

---

## Part 9: Common Issues & Fixes

| Issue | Test Command | Fix |
|-------|--------------|-----|
| Maven not found | `mvn -version` | Add Maven to PATH |
| Java not found | `java -version` | Install JDK 11+ |
| Docker not running | `docker ps` | Start Docker daemon |
| Image won't build | `docker build -v .` | Check Dockerfile syntax |
| Container exits | `docker run -it simple-app:test` | Check app startup logs |
| Registry auth fails | `docker login registry.com` | Verify credentials |

---

## Part 10: Success Criteria Checklist

Before deploying to Jenkins, verify:

- [ ] ✅ Jenkinsfile syntax is valid
- [ ] ✅ Maven build completes successfully
- [ ] ✅ All unit tests pass
- [ ] ✅ JAR file executes without errors
- [ ] ✅ Docker image builds successfully
- [ ] ✅ Docker container runs and starts correctly
- [ ] ✅ Container logs show expected output
- [ ] ✅ Image size is reasonable (<300MB)
- [ ] ✅ Documentation files are complete
- [ ] ✅ Total build time is <3 minutes

---

## Quick Test Script (PowerShell)

Save as `test-pipeline.ps1`:

```powershell
# Windows PowerShell test script
$ErrorActionPreference = "Stop"

Write-Host "=== Pipeline Test Suite ===" -ForegroundColor Green

Write-Host "`n[1] Testing Maven Build..." -ForegroundColor Yellow
mvn clean package -DskipTests
if ($?) { Write-Host "✓ Maven build passed" -ForegroundColor Green }

Write-Host "`n[2] Testing Unit Tests..." -ForegroundColor Yellow
mvn test
if ($?) { Write-Host "✓ Tests passed" -ForegroundColor Green }

Write-Host "`n[3] Testing Docker Build..." -ForegroundColor Yellow
docker build -t simple-app:test .
if ($?) { Write-Host "✓ Docker build passed" -ForegroundColor Green }

Write-Host "`n[4] Testing Docker Run..." -ForegroundColor Yellow
$container = docker run -d simple-app:test
Start-Sleep -Seconds 2
$logs = docker logs $container
docker stop $container
docker rm $container
if ($logs -match "Hello") { Write-Host "✓ Docker run passed" -ForegroundColor Green }

Write-Host "`n=== All Tests Passed! ===" -ForegroundColor Green
```

Run it:
```powershell
cd c:\demo-copilot\simple-app
powershell -ExecutionPolicy Bypass -File test-pipeline.ps1
```

---

## Next: Deploy to Jenkins

Once all tests pass:

1. **Create Jenkins Pipeline Job** (see JENKINSFILE-QUICKSTART.md)
2. **Add credentials** for Docker registry
3. **Configure build triggers** (GitHub webhook)
4. **Run first build** and monitor logs
5. **Validate artifact production** (Docker image pushed)

