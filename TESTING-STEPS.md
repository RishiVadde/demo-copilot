# 🧪 Complete Testing Guide

## Quick Overview

```
Your Testing Path:
┌─────────────────┐
│  Maven Build    │ ✅ TEST
├─────────────────┤
│  Run Tests      │ ✅ TEST
├─────────────────┤
│  Docker Build   │ ⚠️  Optional
├─────────────────┤
│  Docker Run     │ ⚠️  Optional
├─────────────────┤
│  Jenkinsfile    │ ✅ VALIDATE
├─────────────────┤
│  Ready for      │ ✅ READY
│  Jenkins        │
└─────────────────┘
```

---

## 📋 Test Checklist

Run these tests in order:

### Test 1: Maven Clean Compile
```bash
mvn clean compile
```
**Time:** 30 seconds
**Expected:** Compilation succeeds, no errors

### Test 2: Maven Run Tests
```bash
mvn test
```
**Time:** 20 seconds
**Expected:** 1 test runs, 0 failures

### Test 3: Maven Package
```bash
mvn package
```
**Time:** 45 seconds
**Expected:** JAR file created in `target/`

### Test 4: Execute JAR
```bash
java -jar target/simple-app-1.0-SNAPSHOT.jar
```
**Time:** 2 seconds
**Expected:** Output: "Hello from Maven!"

### Test 5: Docker Build (Optional)
```bash
docker build -t simple-app:test .
```
**Time:** 60-120 seconds
**Expected:** Image created successfully

### Test 6: Docker Run (Optional)
```bash
docker run simple-app:test
```
**Time:** 5 seconds
**Expected:** Output: "Hello from Maven!"

### Test 7: Jenkinsfile Validation
```
Online: https://www.jenkins.io/doc/book/pipeline/declarative/
```
**Time:** 1 minute
**Expected:** "Successfully validated"

---

## 🚀 Full Test Run (All Steps)

Copy and run this complete sequence:

```bash
#!/bin/bash
cd c:\demo-copilot\simple-app

echo "🧪 Starting complete test suite..."
echo ""

# Test 1: Maven clean
echo "[1/7] Maven clean..."
mvn clean -q && echo "✓ PASS" || echo "✗ FAIL"

# Test 2: Maven compile
echo "[2/7] Maven compile..."
mvn compile -q && echo "✓ PASS" || echo "✗ FAIL"

# Test 3: Maven test
echo "[3/7] Maven test..."
mvn test -q && echo "✓ PASS" || echo "✗ FAIL"

# Test 4: Maven package
echo "[4/7] Maven package..."
mvn package -DskipTests -q && echo "✓ PASS" || echo "✗ FAIL"

# Test 5: JAR execution
echo "[5/7] JAR execution..."
java -jar target/simple-app-*.jar && echo "✓ PASS" || echo "✗ FAIL"

# Test 6: Docker build (if available)
echo "[6/7] Docker build..."
if command -v docker &> /dev/null; then
    docker build -t simple-app:test -q . && echo "✓ PASS" || echo "✗ FAIL"
else
    echo "⊘ SKIP (Docker not installed)"
fi

# Test 7: Jenkinsfile validation
echo "[7/7] Jenkinsfile validation..."
if grep -q "pipeline {" Jenkinsfile && grep -q "stages {" Jenkinsfile; then
    echo "✓ PASS"
else
    echo "✗ FAIL"
fi

echo ""
echo "🎉 Test suite complete!"
```

---

## 📊 Expected Output Summary

### Maven Build Output
```
[INFO] Scanning for projects...
[INFO] ---------< com.example:simple-app >---------
[INFO] Building Simple App 1.0-SNAPSHOT
[INFO] -------[ jar ]--------
...
[INFO] --- compiler:3.8.1:compile @ simple-app ---
[INFO] Changes detected - recompiling the module
[INFO] Compiling 1 source file...
[INFO] 
[INFO] --- resources:3.3.1:resources @ simple-app ---
[INFO] skip non existing resourceDirectory
[INFO] 
[INFO] --- surefire:3.2.5:test @ simple-app ---
[INFO] Running com.example.AppTest
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
[INFO] 
[INFO] --- jar:3.2.0:jar @ simple-app ---
[INFO] Building jar: target/simple-app-1.0-SNAPSHOT.jar
[INFO] --------
[INFO] BUILD SUCCESS
```

### JAR Execution Output
```
Hello from Maven!
```

### Docker Build Output
```
[+] Building 45.3s (11/11) FINISHED
 => [builder 1/4] FROM maven:3.9-eclipse-temurin-11
 => [builder 2/4] WORKDIR /app
 => [builder 3/4] COPY pom.xml .
 => [builder 4/4] COPY src ./src
 => [stage-1 5/8] FROM eclipse-temurin:11-jre-alpine
 => [stage-1 6/8] INSTALL curl
 => [stage-1 7/8] COPY --from=builder /app/target/simple-app-*.jar app.jar
 => [stage-1 8/8] ENTRYPOINT ["java", "-jar", "app.jar"]
 => exporting to image
 => naming to docker.io/library/simple-app:test
```

---

## ⏱️ Performance Baseline

| Test | Duration | Threshold |
|------|----------|-----------|
| Maven clean | 2s | < 5s |
| Maven compile | 15s | < 30s |
| Maven test | 10s | < 30s |
| Maven package | 20s | < 60s |
| JAR execution | 1s | < 5s |
| Docker build (first) | 90s | < 180s |
| Docker build (cached) | 10s | < 30s |
| **Total** | **~150s** | **< 5 minutes** |

---

## 🔍 Detailed Test Results

### After running full test suite, you should see:

```
✓ Maven clean          [2s]
✓ Maven compile       [15s]
✓ Maven test         [10s]
✓ Maven package      [20s]
✓ JAR execution       [1s]
✓ Docker build       [90s]  (if Docker installed)
✓ Jenkinsfile syntax  [<1s]

TOTAL TIME:           ~150 seconds
SUCCESS RATE:         100% (7/7 tests passed)
STATUS:               ✅ READY FOR JENKINS
```

---

## 🛠️ Troubleshooting

### If Maven build fails:
```bash
# Clean Maven cache
mvn clean -U

# Run with debug output
mvn clean compile -X

# Check Java version
java -version
```

### If tests fail:
```bash
# Run specific test
mvn test -Dtest=AppTest

# View detailed test reports
cat target/surefire-reports/TEST-com.example.AppTest.xml
```

### If Docker build fails:
```bash
# Check Docker daemon
docker ps

# Build with verbose output
docker build -v -t simple-app:test .

# Check Dockerfile syntax
docker build --progress=plain .
```

### If Jenkinsfile validation fails:
```bash
# Check syntax with text editor
# Look for:
# - Missing braces: pipeline { }
# - Quoted stage names: stage('Build') { }
# - Agent declaration: agent any
```

---

## ✅ Go/No-Go Checklist

Before deploying to Jenkins, verify ALL:

- [ ] Maven clean compiles without errors
- [ ] All tests pass (1 test runs, 0 failures)
- [ ] JAR file is created
- [ ] JAR executes and produces output
- [ ] Docker image builds (if Docker available)
- [ ] Docker container runs (if Docker available)
- [ ] Jenkinsfile passes syntax validation
- [ ] All documentation files exist
- [ ] Total build time < 5 minutes
- [ ] No environment-specific hardcoding

---

## 🎯 Next: Jenkins Deployment

Once all tests pass with ✅:

**1. Create Jenkins Job**
- Type: Pipeline
- SCM: Git repository URL
- Script path: Jenkinsfile

**2. Add Credentials**
- Type: Docker Registry (Username + Password)
- ID: `docker-registry-credentials`

**3. Configure Tools**
- Maven 3.9.10
- Java 11

**4. Build**
- Click "Build Now"
- Monitor console output
- Check artifact production

---

## 📚 Test Documentation Files

Your project now includes:

1. **[TESTING-GUIDE.md](TESTING-GUIDE.md)** - Comprehensive testing guide with 10 parts
2. **[TESTING-QUICK-START.md](TESTING-QUICK-START.md)** - Quick reference and commands
3. **[THIS FILE](TESTING-STEPS.md)** - Visual step-by-step guide

---

## 🎓 Learning Resources

- [Maven Build Lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html)
- [JUnit 4 Testing](https://junit.org/junit4/)
- [Docker Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Jenkinsfile Reference](https://www.jenkins.io/doc/book/pipeline/syntax/)

---

## 💡 Pro Tips

1. **Run tests locally before pushing** to catch issues early
2. **Use Maven skip tests for faster builds** during development: `mvn clean package -DskipTests`
3. **Docker images are large** - use multi-stage builds to minimize size
4. **Test in containers** to catch environment issues before production
5. **Save baseline metrics** to track performance improvements

---

## Ready? 🚀

All tests passing? Congratulations!

Your project is ready for Jenkins deployment. Follow the quick start guide to set up your CI/CD pipeline.

**Happy testing!**
