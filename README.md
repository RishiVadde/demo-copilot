# Simple Java Maven Project

A complete Java Maven project with CI/CD pipeline automation, Docker containerization, and comprehensive testing guides.

## 🚀 Quick Start

```bash
# Build the project
mvn clean package

# Run the application
java -jar target/simple-app-1.0-SNAPSHOT.jar

# Expected output: "Hello from Maven!"
```

## 📚 Documentation Guide

Choose your starting point:

| Document | Purpose | Time |
|----------|---------|------|
| [TESTING-SUMMARY.md](TESTING-SUMMARY.md) | **START HERE** - Testing overview | 5 min |
| [TESTING-STEPS.md](TESTING-STEPS.md) | Visual step-by-step testing guide | 5 min |
| [TESTING-QUICK-START.md](TESTING-QUICK-START.md) | Quick reference and commands | 3 min |
| [TESTING-GUIDE.md](TESTING-GUIDE.md) | Comprehensive testing reference | 15 min |
| [JENKINSFILE-QUICKSTART.md](JENKINSFILE-QUICKSTART.md) | Jenkins setup in 5 minutes | 5 min |
| [JENKINSFILE-SETUP.md](JENKINSFILE-SETUP.md) | Detailed Jenkinsfile documentation | 20 min |

## Project Structure

```
simple-app/
├── pom.xml                           ← Maven configuration
├── Jenkinsfile                       ← CI/CD pipeline definition
├── Dockerfile                        ← Docker image configuration
│
├── 📚 Testing Documentation:
├── TESTING-SUMMARY.md               ← Start here for testing
├── TESTING-STEPS.md                 ← Visual testing guide
├── TESTING-QUICK-START.md           ← Quick command reference
├── TESTING-GUIDE.md                 ← Comprehensive guide
├── test-pipeline.ps1                ← Automated test script
│
├── 🔧 Setup Documentation:
├── JENKINSFILE-QUICKSTART.md        ← Jenkins quick setup
├── JENKINSFILE-SETUP.md             ← Jenkins detailed setup
│
├── src/
│   ├── main/
│   │   └── java/com/example/App.java         ← Application
│   └── test/
│       └── java/com/example/AppTest.java     ← Unit tests
│
└── target/                          ← Build artifacts (generated)
    └── simple-app-1.0-SNAPSHOT.jar  ← Executable JAR
```

## Prerequisites

- Java 11 or higher
- Maven 3.6.0 or higher
- Git (for version control)
- Docker (optional, for containerization)

## Building the Project

### Option 1: Maven Build Only
```bash
mvn clean package
```

### Option 2: Maven Build with Tests
```bash
mvn clean compile test package
```

### Option 3: Maven Build and Skip Tests (faster)
```bash
mvn clean package -DskipTests
```

## Running the Application

### Run JAR Directly
```bash
java -jar target/simple-app-1.0-SNAPSHOT.jar
```

### Run via Maven
```bash
mvn exec:java -Dexec.mainClass="com.example.App"
```

## Testing

### Run Unit Tests
```bash
mvn test
```

### View Test Results
```bash
# Windows
type target\surefire-reports\TEST-com.example.AppTest.xml

# Linux/Mac
cat target/surefire-reports/TEST-com.example.AppTest.xml
```

## Docker Support

### Build Docker Image
```bash
docker build -t simple-app:1.0.0 .
```

### Run Docker Container
```bash
docker run simple-app:1.0.0
```

### Multi-stage Build Benefits
- **Smaller image size** (~150MB vs 500MB)
- **Production ready** with JRE only
- **Health checks included**

## CI/CD Pipeline (Jenkins)

This project includes a complete Declarative Jenkinsfile with:

- ✅ Build stage (Maven compile/package)
- ✅ Test stage (Unit tests with retry logic)
- ✅ Code Quality analysis (SonarQube)
- ✅ Docker image build (multi-stage)
- ✅ Image vulnerability scanning
- ✅ Registry push (with authentication)
- ✅ Dev/Prod deployments (conditional)

See [JENKINSFILE-QUICKSTART.md](JENKINSFILE-QUICKSTART.md) to set up Jenkins in 5 minutes.

## Performance Benchmarks

| Operation | Time | Threshold |
|-----------|------|-----------|
| Maven clean compile | 15s | < 30s |
| Maven test | 10s | < 30s |
| Maven package | 20s | < 60s |
| Docker build (first) | 90s | < 180s |
| Docker build (cached) | 10s | < 30s |
| Full pipeline | ~150s | < 5 min |

## Testing the Pipeline Locally

Before deploying to Jenkins:

```bash
# Test 1: Maven build
mvn clean compile test package

# Test 2: JAR execution
java -jar target/simple-app-*.jar

# Test 3: Docker build (requires Docker)
docker build -t simple-app:test .

# Test 4: Docker execution
docker run simple-app:test

# Test 5: Jenkinsfile validation
# Copy to: https://www.jenkins.io/doc/book/pipeline/declarative/
```

## Development Workflow

1. **Modify code** in `src/main/java/com/example/`
2. **Update tests** in `src/test/java/com/example/`
3. **Run locally:** `mvn clean package`
4. **Push to Git:** `git push origin main`
5. **Jenkins builds automatically** via Jenkinsfile

## Troubleshooting
