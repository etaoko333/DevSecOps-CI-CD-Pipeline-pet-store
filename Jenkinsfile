pipeline{
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages{
        stage ('Cleaning Workspace'){
            steps{
                cleanWs()
            }
        }
        stage ('checkout SCM') {
            steps {
                git 'https://github.com/etaoko333/Pipeline-pet-store.git'
            }
        }
        stage ('Compiling Maven Code') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage ('maven Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage("analysis using SonarQube "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Petshop \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=Petshop '''
                }
            }
        }
        stage("SonarQube quality gate"){
            steps {
                script {
                  waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
           }
        }
        stage ('Building war file using Maven'){
            steps{
                sh 'mvn clean install -DskipTests=true'
            }
        }
        stage("OWASP Dependency Checking"){
            steps{
                dependencyCheck additionalArguments: '--scan ./ --format XML ', odcInstallation: 'dependency-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage ('Building and pushing to docker hub'){
            steps{
                script{
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh "docker build -t sholly333/petshop:${BUILD_TAG} ."
                        sh "docker push sholly333/petshop:${BUILD_TAG}"
                   }
                }
            }
        }
        stage("Image Scanning using TRIVY"){
            steps{
                sh "trivy image sholly333/petshop:${BUILD_TAG} > trivy.txt"
            }
        }
                stage('QA testing Stage'){
            steps{
                sh 'docker rm -f qacontainer'
                sh 'docker run -d --name qacontainer -p 80:80 sholly333/petshop:latest'
                sleep time: 60, unit: 'SECONDS'
                retry(10){
                
                sh 'curl --silent http://3.110.124.24:80/jpetstore/ | grep JPetStore'
                }
                //testing curl
                
            }
            post {
                failure {
                    emailext attachLog: true,
                    subject: "'${currentBuild.result}'",
                    body: "Project: ${env.JOB_NAME}<br/>" +
                        "Build Number: ${env.BUILD_NUMBER}<br/>" +
                        "URL: ${env.BUILD_URL}<br/>"+
                        "<h1>QA Testing Failed</h1>",
                    to: 'qateam@gmail.com',
                    attachmentsPattern: 'trivy.txt'
                }
            }
        }
        stage("Trigger CD(Deployment)"){
            steps{
                  // Trigger the deployment pipeline and wait for it to complete
                  build job: 'DevSecOps-CD', wait: true
             }             
         }

    }
    post {
     always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "<h1> CI/CD Pipeline ran successfully"+
                "URL: ${env.BUILD_URL}<br/>",
            to: 'priyansh12t@gmail.com',  // Developer or manager Email
            attachmentsPattern: 'trivy.txt'
            
        }
    }

}
