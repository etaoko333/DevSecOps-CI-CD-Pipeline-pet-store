pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout SCM') {
            steps {
                git 'https://github.com/etaoko333/Petshop-App.git'
            }
        }
        stage('Compiling Maven Code') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Maven Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Analysis using SonarQube') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh ''' 
                    $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Petshop \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=Petshop
                    '''
                }
            }
        }
        stage('SonarQube Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('Building WAR file using Maven') {
            steps {
                sh 'mvn clean install -DskipTests=true'
            }
        }
        stage('OWASP Dependency Checking') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format XML', odcInstallation: 'dependency-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Building and Pushing to Docker Hub') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t sholly333/tomcat-jpetstore:${BUILD_TAG} ."
                        sh "docker push sholly333/tomcat-jpetstore:${BUILD_TAG}"
                    }
                }
            }
        }
        stage('Image Scanning using Trivy') {
            steps {
                sh "trivy image sholly333/tomcat-jpetstore:${BUILD_TAG} > trivy.txt"
            }
        }
        stage('K8s-Deploy') {
            steps {
                withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: 'devopsola-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'petshop-app', serverUrl: 'https://6521CDD4D3810B9D5BC7BA558F523321.gr7.us-west-1.eks.amazonaws.com']]) {
                    sh "kubectl apply -f deployment"
                    sleep 20
                }
            }
        }
        stage('Verify Deployment') {
            steps {
                withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: 'devopsola-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'petshop-app', serverUrl: 'https://6521CDD4D3810B9D5BC7BA558F523321.gr7.us-west-1.eks.amazonaws.com']]) {
                    sh "kubectl get pods"
                    sh "kubectl get service"
                }
            }
        }
    }
}
