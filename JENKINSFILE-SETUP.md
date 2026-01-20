# Jenkinsfile Pipeline Documentation

## Overview

This Declarative Jenkins pipeline automates the CI/CD process for a Java Maven application, including building, testing, containerization, and deployment.

## Pipeline Stages

### 1. **Checkout** 📥
- Pulls source code from version control (Git)
- Displays the latest commit hash
- **Duration:** ~5-10 seconds

### 2. **Build** 🔨
- Compiles Maven project with `mvn clean package`
- Skips tests for faster feedback
- **Duration:** ~30-60 seconds (first run may be longer)
- **Output:** JAR file in `target/` directory

### 3. **Test** ✅
- Runs unit tests with `mvn test`
- Reruns failed tests up to 2 times for flaky test handling
- Publishes test reports
- **Duration:** ~20-30 seconds
- **Artifacts:** JUnit XML reports in `target/surefire-reports/`

### 4. **Code Quality** 🔍
- Runs SonarQube analysis (main branch only)
- Analyzes code for bugs, vulnerabilities, and code smells
- Optional: fails build if quality gate is not met
- **Duration:** ~1-2 minutes

### 5. **Build Docker Image** 🐳
- Creates multi-stage Docker image
- Tags image with build number and "latest"
- Includes build metadata (BUILD_NUMBER, GIT_COMMIT)
- **Duration:** ~30-60 seconds

### 6. **Scan Image** 🔐
- Scans Docker image for vulnerabilities using Trivy
- Reports HIGH and CRITICAL severity issues
- Non-blocking stage (warnings don't fail the build)
- **Duration:** ~20-40 seconds

### 7. **Push to Registry** 📤
- Logs into private Docker registry
- Pushes image with specific tag and "latest" tag
- Only runs on: main branch, develop branch, or version tags (v*)
- Cleans up credentials after push
- **Duration:** ~30-60 seconds (depends on image size and network)

### 8. **Deploy to Dev** 🚀
- Triggers when pushing to develop branch
- Placeholder for Dev environment deployment
- Options: Kubernetes, Docker Compose, Helm, etc.

### 9. **Deploy to Prod** 🌍
- Triggers when pushing a version tag (e.g., v1.0.0)
- **Requires manual approval via input step**
- Placeholder for Production deployment with safety checks

## Configuration Requirements

### Jenkins Plugins
Install these plugins in Jenkins:
- Pipeline
- Git
- Docker
- Docker Pipeline
- JUnit
- SonarQube Scanner (optional)
- Kubernetes (if using K8s deployments)

### Jenkins Credentials
Create these credentials in Jenkins:
1. **docker-registry-credentials** (Username/Password)
   - Username: Docker registry username
   - Password: Docker registry password/token

2. **sonarqube-token** (Secret text) - Optional
   - Token for SonarQube authentication

### Jenkins Tools Configuration
Configure in Jenkins Global Tool Configuration:
1. Maven 3.9.10
2. Java (JDK) 11

### Environment Variables (Jenkins)
Set these in Jenkins pipeline job or globally:
- `SONARQUBE_HOST_URL` - SonarQube server URL (optional)
- `SONARQUBE_TOKEN` - SonarQube API token (optional)

### Docker Registry Setup
```bash
# Private registry examples:
# - AWS ECR: 123456789.dkr.ecr.us-east-1.amazonaws.com
# - Docker Hub (private): docker.io
# - Self-hosted: registry.company.com
# - GitLab Registry: registry.gitlab.com
```

## Usage

### Basic Run
```bash
# Create a new Jenkins pipeline job:
1. Pipeline > New Item > Pipeline
2. Name: simple-app-pipeline
3. Pipeline section:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: https://github.com/your-org/simple-app.git
   - Branch: */main
4. Save and Build
```

### Build with Parameters
```bash
# In Jenkins UI, select "Build with Parameters":
- DOCKER_REGISTRY: private-registry.example.com
- IMAGE_TAG: 1.0.0 (or use ${BUILD_NUMBER})
```

### Manual Git Trigger
```bash
git tag v1.0.0
git push origin v1.0.0
# This triggers the full pipeline including Production deployment prompt
```

## Pipeline Execution Flow

```
┌──────────────┐
│   Checkout   │
└──────┬───────┘
       ↓
┌──────────────┐
│    Build     │
└──────┬───────┘
       ↓
┌──────────────┐
│     Test     │
└──────┬───────┘
       ↓
┌──────────────────────┐
│  Code Quality (main) │ ← Conditional
└──────┬───────────────┘
       ↓
┌───────────────────────┐
│ Build Docker Image    │
└──────┬────────────────┘
       ↓
┌──────────────────┐
│  Scan Image      │
└──────┬───────────┘
       ↓
┌────────────────────────────┐
│ Push to Registry (branch)   │ ← Conditional
└──────┬─────────────────────┘
       ↓
┌─────────────────────────┐
│ Deploy to Dev (develop) │ ← Conditional
└──────┬──────────────────┘
       ↓
┌────────────────────────────────┐
│ Deploy to Prod (tag) + Approval│ ← Conditional + Input
└────────────────────────────────┘
```

## Docker Image Details

### Multi-Stage Build Benefits
- **Builder Stage:** Uses Maven + JDK for compilation
- **Runtime Stage:** Uses lightweight Alpine JRE
- **Result:** Small, optimized image (~150-200MB vs 500+MB with single stage)

### Image Metadata
```dockerfile
LABEL build.number="123" \
      git.commit="abc123def456" \
      maintainer="DevOps Team"
```

### Health Check
```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3
```

## Customization

### Change Docker Registry
Edit the `environment` section in Jenkinsfile:
```groovy
DOCKER_REGISTRY_URL = "your-registry.com"
```

### Modify Build Stages
Edit the `stages` section for your specific needs:
- Add Slack notifications
- Add email alerts
- Integrate with ArgoCD for GitOps
- Add security scanning (Snyk, Aqua, etc.)

### Adjust Timeouts
```groovy
options {
    timeout(time: 1, unit: 'HOURS')  // Change to 30 minutes for faster failure detection
}
```

### Modify Deployment Logic
Update `stage('Deploy to Prod')` with your deployment method:
```groovy
// Kubernetes example:
sh '''
    kubectl set image deployment/simple-app \
        simple-app=${IMAGE_NAME}:${IMAGE_TAG} \
        -n production
'''

// Or Docker Compose example:
sh '''
    docker-compose -f docker-compose.prod.yml \
        pull simple-app:${IMAGE_TAG} && \
    docker-compose -f docker-compose.prod.yml up -d
'''
```

## Monitoring & Troubleshooting

### View Pipeline Execution
1. Jenkins Dashboard → Pipeline Job
2. Click build number
3. View "Pipeline Steps" graph
4. Click stages for detailed logs

### Common Issues

**Issue:** Docker daemon not found
```bash
# Solution: Ensure Docker is installed and Jenkins user has access
sudo usermod -aG docker jenkins
```

**Issue:** Registry authentication fails
```bash
# Solution: Verify credentials are correctly set in Jenkins
# Test with: docker login -u user registry.com
```

**Issue:** SonarQube analysis skipped
```bash
# Solution: Set SONARQUBE_HOST_URL and SONARQUBE_TOKEN environment variables
```

**Issue:** Health check fails
```bash
# Solution: Adjust application port or remove health check for non-web apps
```

## Time Savings Analysis

### Manual vs Automated

| Task | Manual | Automated (Jenkinsfile) | Savings |
|------|--------|-------------------------|---------|
| Compile | 2 min | 1 min | 50% |
| Test | 1 min | 1 min | 0% |
| Build Docker Image | 3 min | 1 min | 67% |
| Registry Push | 2 min | 1 min | 50% |
| Deploy | 5 min | 1 min (auto) | 80% |
| **Total Per Build** | **13 min** | **5 min** | **62% ⏱️** |

### Additional Benefits
- **Error Reduction:** Automated builds eliminate manual mistakes
- **Consistency:** Every build follows same steps
- **Audit Trail:** Complete history of deployments
- **Parallel Execution:** Multiple stages can run concurrently with optimization
- **Team Productivity:** Developers focus on code, not deployment

## Next Steps

1. Update Jenkins credentials with your registry details
2. Configure Git webhook to trigger pipeline on push
3. Customize deployment stages for your infrastructure
4. Add additional stages (SAST, DAST, performance testing)
5. Integrate with monitoring and alerting systems

## References

- [Jenkins Declarative Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [SonarQube Integration](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)
