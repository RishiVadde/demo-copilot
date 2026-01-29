pipeline {
    agent none
    
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
        stage('Pipeline') {
            agent any
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
            }
            post {
                always {
                    echo '🧹 Cleaning up...'
                    junit '**/target/surefire-reports/TEST-*.xml', allowEmptyResults: true
                    archiveArtifacts artifacts: 'target/**/*.jar', allowEmptyArchive: true
                }
                success {
                    echo '✅ Pipeline succeeded!'
                    sh '''
                        echo "Build Summary:"
                        echo "- Build Number: ${BUILD_NUMBER}"
                        echo "- Git Commit: ${GIT_COMMIT}"
                    '''
                }
                failure {
                    echo '❌ Pipeline failed!'
                    sh 'echo "Check logs for details"'
                }
                unstable {
                    echo '⚠️ Pipeline is unstable!'
                }
                cleanup {
                    deleteDir()
                }
            }
        }
    }
}
