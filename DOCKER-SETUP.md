# Docker Configuration Guide

## Current Status

All Docker-related configurations have been **commented out** in the Jenkinsfile because Docker credentials are not currently available.

## What's Commented Out

The following sections can be uncommented when you have Docker registry credentials:

1. **Parameters Section** - Docker registry and image tag parameters
2. **Environment Variables** - Docker registry URL, image name, and credentials
3. **Build Docker Image Stage** - Multi-stage Docker build process
4. **Scan Image Stage** - Trivy vulnerability scanning
5. **Push to Registry Stage** - Docker login and push to private registry
6. **Deploy to Dev Stage** - Development environment deployment
7. **Deploy to Prod Stage** - Production environment deployment with approval
8. **Post Cleanup** - Docker image pruning

## How to Enable Docker Support

### Step 1: Get Docker Registry Credentials

You'll need:
- Registry URL (e.g., `docker.io`, `registry.example.com`, AWS ECR, GitLab Registry)
- Username
- Password or Token

### Step 2: Create Jenkins Credentials

1. Go to Jenkins Dashboard
2. Click **Manage Jenkins** → **Manage Credentials**
3. Click **System** → **Global credentials**
4. Click **Add Credentials**
5. Fill in:
   - **Kind:** Username with password
   - **Username:** Your registry username
   - **Password:** Your token/password
   - **ID:** `docker-registry-credentials`
6. Click **Create**

### Step 3: Uncomment Docker Sections in Jenkinsfile

Open `Jenkinsfile` and uncomment these sections:

#### Option A: Uncomment All Docker (Recommended)
```bash
# Remove '//' comment prefix from all Docker-related lines
sed -i 's|^        //||g' Jenkinsfile
```

#### Option B: Manually Uncomment (Safe)

Find and uncomment each section:

1. **Parameters** (~line 18-28)
   - Remove `//` from each line
   
2. **Environment** (~line 30-38)
   - Remove `//` from Docker environment variables

3. **Build Docker Image Stage** (~line 88-102)
   - Remove `//` from stage definition

4. **Scan Image Stage** (~line 104-117)
   - Remove `//` from stage definition

5. **Push to Registry Stage** (~line 119-140)
   - Remove `//` from stage definition

6. **Deploy to Dev Stage** (~line 142-157)
   - Remove `//` from stage definition

7. **Deploy to Prod Stage** (~line 159-179)
   - Remove `//` from stage definition

8. **Post Cleanup** (~line 198)
   - Remove `//` from docker prune command

### Step 4: Update Docker Registry URL

In the Jenkinsfile, update the default registry if needed:

```groovy
// Current default
defaultValue: 'private-registry.example.com'

// Change to your registry
// Examples:
// - 'docker.io' for Docker Hub
// - 'registry.gitlab.com' for GitLab
// - '123456789.dkr.ecr.us-east-1.amazonaws.com' for AWS ECR
// - 'registry.example.com' for self-hosted
```

### Step 5: Configure Maven Tool (if not done)

1. Go to **Manage Jenkins** → **Global Tool Configuration**
2. Add Maven 3.9.10
3. Add Java 11
4. Save

### Step 6: Test Pipeline

1. Create/Update Jenkins Pipeline job
2. Point to your Git repository
3. Click **Build Now**
4. Monitor console for Docker build steps

## Jenkinsfile Docker Stages (When Enabled)

```
Build → Test → [Build Docker Image] → [Scan Image] → [Push to Registry]
         ↓
    [Deploy to Dev] (if develop branch)
         ↓
    [Deploy to Prod] (if version tag + approval)
```

## Example Docker Registry Setup

### Docker Hub (docker.io)
```groovy
parameters {
    string(
        name: 'DOCKER_REGISTRY',
        defaultValue: 'docker.io',
        description: 'Docker registry URL'
    )
    string(
        name: 'IMAGE_TAG',
        defaultValue: 'latest',
        description: 'Docker image tag'
    )
}

environment {
    IMAGE_NAME = "${params.DOCKER_REGISTRY}/yourusername/simple-app"
}
```

### AWS ECR (Elastic Container Registry)
```groovy
parameters {
    string(
        name: 'DOCKER_REGISTRY',
        defaultValue: '123456789.dkr.ecr.us-east-1.amazonaws.com',
        description: 'AWS ECR registry'
    )
}
```

### GitLab Registry
```groovy
parameters {
    string(
        name: 'DOCKER_REGISTRY',
        defaultValue: 'registry.gitlab.com',
        description: 'GitLab registry'
    )
}
```

### Self-Hosted Registry
```groovy
parameters {
    string(
        name: 'DOCKER_REGISTRY',
        defaultValue: 'registry.company.com',
        description: 'Company registry'
    )
}
```

## Troubleshooting

### "docker: command not found"
- Ensure Docker is installed on Jenkins agent
- Configure Jenkins agent with Docker access

### "Authentication failed"
- Verify Docker credentials are correct in Jenkins
- Check credential ID matches `docker-registry-credentials`
- Test credentials: `docker login <registry> -u <user> -p <password>`

### "Image push failed"
- Verify registry URL is accessible
- Check network connectivity
- Ensure Jenkins agent can reach registry

### "Permission denied"
- Add Jenkins user to docker group: `sudo usermod -aG docker jenkins`
- Restart Jenkins: `sudo systemctl restart jenkins`

## Rollback: Disable Docker Again

If you need to disable Docker support:

```bash
# Comment out Docker sections again
sed -i 's|^        \(.*docker\)|        //\1|g' Jenkinsfile
```

## Next Steps

1. ✅ Get Docker registry credentials
2. ✅ Create Jenkins credentials
3. ✅ Uncomment Docker sections
4. ✅ Configure Maven/Java tools
5. ✅ Test pipeline

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Jenkins Docker Plugin](https://plugins.jenkins.io/docker/)
- [Docker Registry API](https://docs.docker.com/registry/spec/api/)
- [Docker Hub](https://hub.docker.com/)
- [AWS ECR](https://aws.amazon.com/ecr/)
- [GitLab Container Registry](https://docs.gitlab.com/ee/user/packages/container_registry/)
