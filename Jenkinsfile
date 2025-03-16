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
                git 'https://github.com/etaoko333/Pipeline-pet-store.git'
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
                        sh "docker build -t sholly333/petshop:${BUILD_TAG} ."
                        sh "docker push sholly333/petshop:${BUILD_TAG}"
                    }
                }
            }
        }
        stage('Image Scanning using Trivy') {
            steps {
                sh "trivy image sholly333/petshop:${BUILD_TAG} > trivy.txt"
            }
        }
        stage('QA Testing Stage') {
            steps {
                sh 'docker rm -f qacontainer'
                sh 'docker run -d --name qacontainer -p 80:80 sholly333/petshop:latest'
                sleep time: 60, unit: 'SECONDS'
                retry(10) {
                    sh 'curl --silent http://3.110.124.24:80/jpetstore/ | grep JPetStore'
                }
            }
        }
    }
}
stage('K8s-Deploy') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'devopsola-cluster', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://C237C0103DF0D7B349ED061646E2EF7E.gr7.us-west-1.eks.amazonaws.com') {
                    sh "kubectl apply -f deployment-service.yml"
                    sleep 20
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'devopsola-cluster', contextName: '', credentialsId: 'k8-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://C237C0103DF0D7B349ED061646E2EF7E.gr7.us-west-1.eks.amazonaws.com') {
                    sh "kubectl get pods"
                    sh "kubectl get service"
                }
            }
        }
    } //
