# Quick Start: Jenkinsfile Setup Guide

## 5-Minute Setup

### Step 1: Create Jenkins Job
1. Jenkins Dashboard → New Item
2. Enter name: `simple-app-pipeline`
3. Select "Pipeline"
4. Click OK

### Step 2: Configure Pipeline
```
General:
- Build triggers: GitHub hook trigger for GITScm polling
- GitHub project: https://github.com/your-org/simple-app

Pipeline:
- Definition: Pipeline script from SCM
- SCM: Git
  - Repository URL: https://github.com/your-org/simple-app.git
  - Credentials: [Select your GitHub credentials]
  - Branch: */main
  - Script Path: Jenkinsfile
```

### Step 3: Add Docker Registry Credentials
1. Manage Jenkins → Manage Credentials → System → Global credentials
2. Add Credentials:
   - Kind: Username with password
   - Username: `your-docker-user`
   - Password: `your-token-or-password`
   - ID: `docker-registry-credentials`
3. Click Create

### Step 4: Trigger Your First Build
```bash
git clone https://github.com/your-org/simple-app.git
cd simple-app
git push origin main  # Triggers the pipeline
```

### Step 5: Monitor Execution
Jenkins Dashboard → simple-app-pipeline → [Build #1] → Pipeline Steps

---

## Pre-Build Checklist

- [ ] Jenkins installed and running
- [ ] Docker installed on Jenkins agent
- [ ] Maven and Java 11 configured in Jenkins Global Tools
- [ ] Docker registry credentials added
- [ ] Git repository accessible
- [ ] Jenkinsfile checked into repo root
- [ ] Dockerfile present in repo root

---

## Troubleshooting Quick Links

| Error | Solution |
|-------|----------|
| "mvn: command not found" | Configure Maven 3.9.10 in Global Tool Configuration |
| "Docker daemon not found" | Run: `sudo usermod -aG docker jenkins` |
| "Authentication failed" | Check docker-registry-credentials in Jenkins |
| "permission denied" | Verify Jenkins user has read access to repo |

---

## Parameter Reference

| Parameter | Default | Purpose |
|-----------|---------|---------|
| DOCKER_REGISTRY | private-registry.example.com | Target Docker registry |
| IMAGE_TAG | latest | Docker image tag version |

---

## Common Customizations

### Skip SonarQube
Comment out or delete the "Code Quality" stage in Jenkinsfile

### Add Slack Notification
Add to `post` section:
```groovy
always {
    slackSend(channel: '#devops', message: "Build ${BUILD_NUMBER} - ${currentBuild.result}")
}
```

### Change Docker Image Name
Modify `environment` section:
```groovy
IMAGE_NAME = "${DOCKER_REGISTRY_URL}/your-custom-app-name"
```

### Add Environment-Specific Deployments
Duplicate Deploy stages and filter by branch/tag:
```groovy
stage('Deploy to Staging') {
    when { branch 'staging' }
    steps { /* staging deploy commands */ }
}
```

---

## File Structure Expected
```
simple-app/
├── Jenkinsfile                  ← CI/CD pipeline definition
├── JENKINSFILE-SETUP.md         ← Detailed documentation
├── JENKINSFILE-QUICKSTART.md    ← This file
├── Dockerfile                   ← Container image definition
├── pom.xml                      ← Maven configuration
└── src/
    ├── main/
    │   └── java/com/example/App.java
    └── test/
        └── java/com/example/AppTest.java
```

---

## Success Criteria for POC

✅ **Build Stage:** Compiles Java code successfully  
✅ **Test Stage:** Unit tests pass without errors  
✅ **Docker Stage:** Creates valid Docker image  
✅ **Push Stage:** Authenticates and pushes to registry  
✅ **Total Time:** Full pipeline completes in < 5 minutes  

---

## Next Phase Enhancements

After POC validation:
1. Add code coverage reports
2. Integrate security scanning (SAST)
3. Add performance testing
4. Implement blue-green deployment
5. Add approval gates for production

---

## Resources

- [Jenkinsfile Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Docker Registry API](https://docs.docker.com/registry/spec/api/)
- [Maven Settings](https://maven.apache.org/configure.html)
