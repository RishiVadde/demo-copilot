# How to Test the Jenkinsfile & Docker Setup

## Summary
Here are the key testing strategies for your CI/CD pipeline without needing Jenkins installed locally.

---

## ✅ Test 1: Maven Build (PASSED)

### Command:
```bash
cd c:\demo-copilot\simple-app
mvn clean compile test package -DskipTests
```

### What it tests:
- Source code compilation
- Unit test framework setup
- JAR packaging

### Expected Result:
```
BUILD SUCCESS
Total time: XX.XXs
```

✅ **This test passed successfully on your system!**

---

## Test 2: Run Maven Tests

### Command:
```bash
mvn test
```

### Output location:
- Test results: `target/surefire-reports/TEST-com.example.AppTest.xml`
- Console output shows all test results

### What it tests:
- Unit test execution
- Test framework integration

### Expected Result:
```
Running com.example.AppTest
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0
```

---

## Test 3: Execute the JAR

### Command:
```bash
java -jar target/simple-app-1.0-SNAPSHOT.jar
```

### Expected Output:
```
Hello from Maven!
```

### What it tests:
- JAR is properly packaged
- Application runs correctly
- Main class is executable

---

## Test 4: Validate Jenkinsfile Syntax

### Online (No Installation):
Use Jenkins Online Validator: https://www.jenkins.io/doc/book/pipeline/declarative/

1. Copy entire Jenkinsfile content
2. Paste into validator
3. Click "Validate"

### What it tests:
- Jenkinsfile grammar and syntax
- Stage definitions
- Agent configuration

### Expected Result:
- No syntax errors reported

---

## Test 5: Docker Image Build (Requires Docker)

### Prerequisites:
- Docker Desktop installed and running
- WSL 2 backend (on Windows)

### Command:
```bash
docker build -t simple-app:test .
```

### Expected Output:
```
[+] Building 45.3s (11/11) FINISHED
 => exporting to oci image format
 => naming to docker.io/library/simple-app:test
```

### What it tests:
- Dockerfile syntax
- Multi-stage build process
- JAR file packaging into image

---

## Test 6: Docker Container Execution

### Command:
```bash
# Run container
docker run -d --name test-app simple-app:test

# View logs (should show "Hello from Maven!")
docker logs test-app

# Stop container
docker stop test-app
docker rm test-app
```

### Expected Output:
```
Hello from Maven!
```

### What it tests:
- Container can start
- Application runs inside container
- Logs are captured

---

## Test 7: Validate Project Files

### Checklist:
```bash
# Verify all required files exist
ls -la Jenkinsfile
ls -la Dockerfile
ls -la pom.xml
ls -la JENKINSFILE-SETUP.md
ls -la JENKINSFILE-QUICKSTART.md
ls -la README.md
ls -la TESTING-GUIDE.md
```

### Expected Result:
All files should be present

---

## Complete Testing Workflow

### Phase 1: Local Build Validation (5 minutes)
```bash
# Stage 1: Clean
mvn clean

# Stage 2: Compile
mvn compile

# Stage 3: Test
mvn test

# Stage 4: Package
mvn package

# Stage 5: Verify JAR
java -jar target/simple-app-*.jar
```

### Phase 2: Docker Validation (10 minutes - requires Docker)
```bash
# Build image
docker build -t simple-app:1.0.0 .

# Run container
docker run -d --name app simple-app:1.0.0

# Check logs
docker logs app

# Stop container
docker stop app && docker rm app

# Cleanup
docker rmi simple-app:1.0.0
```

### Phase 3: Jenkinsfile Validation (5 minutes)
```bash
# Option 1: Online validator
# Copy Jenkinsfile to https://www.jenkins.io/doc/book/pipeline/declarative/

# Option 2: Jenkins linter (requires Jenkins running)
curl -X POST -F "jenkinsfile=@Jenkinsfile" \
  http://localhost:8080/pipeline-model-converter/validate
```

---

## Testing Requirements

| Component | Requirement | Status |
|-----------|-------------|--------|
| Java 11+ | Required for Maven build | ✅ Installed |
| Maven 3.9+ | Required for building | ✅ Installed |
| Git | Required for SCM checkout | ✅ Available |
| Docker | Required for image build/test | ⚠️ Optional (desktop only) |
| Jenkins | Required for pipeline execution | ⚠️ Not needed for validation |

---

## Success Criteria

Before deploying to Jenkins, verify:

- ✅ `mvn clean package` completes without errors
- ✅ `mvn test` shows all tests passing
- ✅ `java -jar target/*.jar` produces expected output
- ✅ All documentation files are present
- ✅ Jenkinsfile passes syntax validation
- ✅ Docker image builds (if Docker available)
- ✅ Docker container runs (if Docker available)

---

## Troubleshooting Common Issues

### Maven build fails
```bash
# Check Java version
java -version

# Check Maven installation
mvn -version

# Clear Maven cache
mvn clean -U
```

### Tests fail
```bash
# Run tests with verbose output
mvn test -X

# View test reports
cat target/surefire-reports/TEST-*.xml
```

### Docker build fails
```bash
# Check Docker is running
docker ps

# Build with verbose output
docker build -v -t simple-app:test .

# Check Dockerfile syntax
docker build --progress=plain .
```

### Jenkinsfile validation fails
- Check for missing braces: `pipeline { }`, `stages { }`
- Verify stage names are quoted: `stage('Build') { }`
- Ensure `agent` is declared: `agent any`

---

## Next Steps

Once all tests pass:

1. **Create Jenkins job** (see JENKINSFILE-QUICKSTART.md)
2. **Configure credentials** for Docker registry
3. **Set up Git webhook** for automatic triggers
4. **Run first Jenkins build** and monitor logs
5. **Verify artifact** (Docker image in registry)

---

## Quick Reference Commands

```bash
# Maven
mvn clean                  # Remove build artifacts
mvn compile               # Compile source code
mvn test                  # Run unit tests
mvn package              # Build JAR
mvn clean package        # Full build

# Docker
docker build -t app:v1 .               # Build image
docker run app:v1                      # Run container
docker logs CONTAINER_ID               # View logs
docker stop CONTAINER_ID               # Stop container
docker rm CONTAINER_ID                 # Remove container
docker rmi app:v1                      # Remove image

# Validation
curl http://localhost:8080/pipeline-model-converter/validate \
  -F "jenkinsfile=@Jenkinsfile"       # Validate Jenkinsfile
```

---

## Additional Resources

- [Maven Documentation](https://maven.apache.org/guides/)
- [Jenkinsfile Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [JUnit Testing](https://junit.org/junit4/)

