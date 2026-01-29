pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
    
    // DOCKER PARAMETERS - COMMENTED OUT (uncomment when Docker credentials are available)
    // parameters {
    //     string(
    //         name: 'DOCKER_REGISTRY',
    //         defaultValue: 'private-registry.example.com',
    //         description: 'Private Docker registry URL'
    //     )
    //     string(
    //         name: 'IMAGE_TAG',
    //         defaultValue: 'latest',
    //         description: 'Docker image tag (e.g., latest, 1.0.0, ${BUILD_NUMBER})'
    //     )
    // }
    
    environment {
        MAVEN_HOME = tool 'Maven'
        JAVA_HOME = tool 'JDK'
        PATH = "${MAVEN_HOME}/bin:${JAVA_HOME}/bin:${PATH}"
        // DOCKER ENVIRONMENT - COMMENTED OUT (uncomment when Docker credentials are available)
        // DOCKER_REGISTRY_URL = "${params.DOCKER_REGISTRY}"
        // IMAGE_NAME = "${DOCKER_REGISTRY_URL}/simple-app"
        // IMAGE_TAG = "${params.IMAGE_TAG}"
        // REGISTRY_CREDENTIALS = credentials('docker-registry-credentials')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out source code...'
                checkout scm
                sh 'git log --oneline -1'
            }
        }
        
        stage('Build') {
            steps {
                echo '🔨 Building Java Maven project...'
                sh '''
                    mvn clean package \
                        -DskipTests \
                        -Drevision=${BUILD_NUMBER} \
                        -Dchangelist= \
                        -Dsha1=
                '''
            }
        }
        
        stage('Test') {
            steps {
                echo '✅ Running unit tests...'
                sh 'mvn test -Dsurefire.rerunFailingTestsCount=2'
            }
        }
        
        stage('Code Quality') {
            when {
                branch 'main'
            }
            steps {
                echo '🔍 Analyzing code quality (SonarQube)...'
                sh '''
                    mvn sonar:sonar \
                        -Dsonar.projectKey=simple-app \
                        -Dsonar.sources=src/main/java \
                        -Dsonar.host.url=${SONARQUBE_HOST_URL} \
                        -Dsonar.login=${SONARQUBE_TOKEN} || echo "SonarQube analysis skipped"
                '''
            }
        }
        
        // stage('Build Docker Image') - COMMENTED OUT (uncomment when Docker credentials are available)
        // stage('Build Docker Image') {
        //     steps {
        //         echo '🐳 Building Docker image...'
        //         sh '''
        //             docker build \
        //                 -t ${IMAGE_NAME}:${IMAGE_TAG} \
        //                 -t ${IMAGE_NAME}:latest \
        //                 -f Dockerfile \
        //                 --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
        //                 --build-arg GIT_COMMIT=${GIT_COMMIT} \
        //                 .
        //         '''
        //     }
        // }
        
        // stage('Scan Image') - COMMENTED OUT (uncomment when Docker credentials are available)
        // stage('Scan Image') {
        //     steps {
        //         echo '🔐 Scanning Docker image for vulnerabilities...'
        //         sh '''
        //             docker run --rm \
        //                 -v /var/run/docker.sock:/var/run/docker.sock \
        //                 aquasec/trivy:latest image \
        //                 --severity HIGH,CRITICAL \
        //                 ${IMAGE_NAME}:${IMAGE_TAG} || echo "Image scan completed with warnings"
        //         '''
        //     }
        // }
        
        // stage('Push to Registry') - COMMENTED OUT (uncomment when Docker credentials are available)
        // stage('Push to Registry') {
        //     when {
        //         anyOf {
        //             branch 'main'
        //             branch 'develop'
        //             tag "v*"
        //         }
        //     }
        //     steps {
        //         echo '📤 Pushing image to private registry...'
        //         sh '''
        //             echo ${REGISTRY_CREDENTIALS_PSW} | docker login \
        //                 -u ${REGISTRY_CREDENTIALS_USR} \
        //                 --password-stdin ${DOCKER_REGISTRY_URL}
        //             
        //             docker push ${IMAGE_NAME}:${IMAGE_TAG}
        //             docker push ${IMAGE_NAME}:latest
        //             
        //             docker logout ${DOCKER_REGISTRY_URL}
        //         '''
        //     }
        // }
        
        // stage('Deploy to Dev') - COMMENTED OUT (uncomment when Docker credentials are available)
        // stage('Deploy to Dev') {
        //     when {
        //         branch 'develop'
        //     }
        //     steps {
        //         echo '🚀 Deploying to Development environment...'
        //         sh '''
        //             echo "Deployment commands:"
        //             echo "1. Update Kubernetes deployment: kubectl set image..."
        //             echo "2. Or update Docker Compose service"
        //             echo "3. Or redeploy via Helm chart"
        //             echo "Placeholder - configure for your infrastructure"
        //         '''
        //     }
        // }
        
        // stage('Deploy to Prod') - COMMENTED OUT (uncomment when Docker credentials are available)
        // stage('Deploy to Prod') {
        //     when {
        //         tag "v*"
        //     }
        //     input {
        //         message "Deploy to Production?"
        //         ok "Deploy"
        //     }
        //     steps {
        //         echo '🌍 Deploying to Production environment...'
        //         sh '''
        //             echo "Production deployment steps:"
        //             echo "1. Blue-Green deployment check"
        //             echo "2. Health checks"
        //             echo "3. Rollback plan verification"
        //             echo "Placeholder - configure for your infrastructure"
        //         '''
        //     }
        // }
    }
    
    post {
        always {
            node('any') {
                echo '🧹 Cleaning up...'
                // sh 'docker image prune -f || true'  // COMMENTED OUT - Docker not available
                junit '**/target/surefire-reports/TEST-*.xml'
                archiveArtifacts artifacts: 'target/**/*.jar', allowEmptyArchive: true
            }
        }
        success {
            node('any') {
                echo '✅ Pipeline succeeded!'
                sh '''
                    echo "Build Summary:"
                    echo "- Build Number: ${BUILD_NUMBER}"
                    echo "- Git Commit: ${GIT_COMMIT}"
                    echo "- Image: ${IMAGE_NAME}:${IMAGE_TAG}"
                '''
            }
        }
        failure {
            node('any') {
                echo '❌ Pipeline failed!'
                sh 'echo "Check logs for details"'
            }
        }
        unstable {
            echo '⚠️ Pipeline is unstable!'
        }
        cleanup {
            node('any') {
                deleteDir()
            }
        }
    }
}
