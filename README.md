The Ultimate DevSecOps CI/CD Pipeline with Maven, Docker, Owaspy, Trivy, Jenkins and Kubernetes.
application tools and arhitecture diagramdeployment outcome

![image](https://github.com/user-attachments/assets/56c9b9b3-472b-47b6-b701-b9a4560f791a)



![Uploading 2025-03-16 (3).png…]()




<img width="960" alt="2025-03-16 (1)" src="https://github.com/user-attachments/assets/13429617-16e7-4591-8397-240627791161" />




<img width="960" alt="2025-03-16 (2)" src="https://github.com/user-attachments/assets/00789615-4ca1-429a-9164-db276a1d4113" />



**Introduction**
In today's fast-paced software development world, security 
is paramount. This guide walks you through deploying an application using a complete DevSecOps CI/CD pipeline in Kubernetes, leveraging Jenkins Pipeline for automation. This pipeline integrates essential security checks, quality assurance, and continuous deployment using tools like SonarQube, OWASP Dependency Check, Trivy, and Docker Hub.

**Why These Tools?**
- Each tool in this pipeline serves a critical role:
- Jenkins - Automates the CI/CD pipeline.
- Maven - Manages dependencies and builds the project.
- SonarQube - Performs static code analysis for quality and security.
- OWASP Dependency Check - Scans for vulnerabilities in dependencies.
- Trivy - Scans container images for security issues.
- Docker Hub - Stores and manages container images.
- Kubernetes - Deploys and orchestrates the application securely.


- Github repo: https://github.com/etaoko333/Petshop-App.git

**Step 1: Setting Up Cloud Environment**
- Before installing tools, set up your cloud environment to host your application securely.
- Provision a Virtual Machine (VM) on AWS, Azure, or GCP:
- Choose a Linux-based OS (Ubuntu 22.04 recommended).
- Ensure the VM has at least 4GB RAM, 2 vCPUs, and 50GB disk space.
- Open ports 22 (SSH), 8080 (Jenkins), 443 (HTTPS), and 6443 (Kubernetes API Server).



**Install Docker on your VM:sudo apt update**
- sudo apt install docker.io -y
- sudo systemctl start docker
- sudo systemctl enable docker

- Install Kubernetes (kubectl):

`curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
Step 2: Install Jenkins
sudo apt update && sudo apt install openjdk-11-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'`

- sudo apt update && sudo apt install jenkins -y
- sudo systemctl start jenkins

- jenkins is runningBy default, Jenkins runs at port 8080, but as the application we will be using also runs on the same port, you will change the Jenkins port in the
- configuration file. First, add the 8090 port to the security group for Jenkins.
- After changing the security group. change the below file port number.
- cd /etc/default
- sudo vi jenkins  #change 8080 to 8090

- cd /lib/systemd/system
- sudo vi jenkins.service
- Replace the 8080 port in the Environment variable with 8090 and restart the jenkins server.
- replace the port from 8080 to 8090sudo systemctl daemon-reload
- sudo systemctl restart jenkins
- Access Jenkins at http://your-server-ip:8090.
- sudo cat /var/lib/jenkins/secrets/initialAdminPassword
- copy the above password in the unlock jenkins field.
- login into jenkinsInstall all the default plugins, We will install the tools plugin in the latter section of this blog. After giving the username and password select Next.
- install the default pluginsjenkins is readyInstall necessary plugins:

**Pipeline plugins**
- SonarQube Scanner
- Trivy Security Scanner
- Kubernetes CLI
- Email Extension
- Maven Intergration
- Pipeline stage view
- Ecliple Temurin
- Owaspy Dependecy

**Step 3: Sonarqube Installation**
SonarQube is an open-source platform for continuous inspection of code quality. It provides static code analysis to identify bugs, vulnerabilities, code smells (poor coding practices), and technical debt in the codebase. SonarQube supports multiple programming languages such as Java, JavaScript, Python, C#, and many others.

- SonarQube is widely used for:
- Code quality analysis: It scans code to detect issues like bugs, security vulnerabilities, and potential problems.
- Automated code reviews: By integrating SonarQube with your CI/CD pipeline, code reviews can be automated, ensuring quality before merging code into the main branch.
- Continuous Integration/Continuous Deployment (CI/CD): SonarQube can be integrated into CI/CD pipelines to provide feedback early in the development lifecycle.
- Technical debt management: It tracks and measures technical debt, helping teams manage and reduce it over time.

**Why Use SonarQube in a Pipeline?**
- Using SonarQube in a pipeline provides several advantages:
- Automated Code Quality Checks: By integrating SonarQube into a CI/CD pipeline, you ensure that code quality is checked every time code is pushed or pulled into the - repository. This helps in identifying problems early.
- Bugs and Vulnerabilities Detection: SonarQube performs static code analysis, detecting bugs, vulnerabilities, and code smells that could be missed during manual reviews. - This reduces the risk of shipping low-quality or insecure code to production.
- Technical Debt Reduction: By tracking technical debt, SonarQube helps the team understand and prioritize refactoring efforts, ensuring long-term maintainability of the codebase.
- Quality Gates: SonarQube allows the setup of "quality gates" - criteria that must be met before code can be deployed. This ensures that no code with critical issues gets - deployed to production.
- Metrics and Reporting: SonarQube generates detailed reports and provides metrics such as code coverage, duplication, complexity, and more. These reports offer insights - 
- into the quality and maintainability of your code.
- Enhanced Developer Collaboration: SonarQube provides developers with direct feedback on their code, fostering collaboration and continuous improvement within the development team

**Insalling SonarQube**
installing Docker for installing Sonarqube in the container
- sudo apt-get update
- sudo apt-get install docker.io -y
- grant the Ubuntu user the permission to access Docker
- sudo usermod -aG docker ubuntu
- newgrp docker
- sudo chmod 777 /var/run/docker.sock

-Starting Sonarqube container:
-docker run -d --name sonarqube-cont -p 9000:9000 sonarqube:lts-community

-This will:
- Run SonarQube in detached mode (-d).
- Expose SonarQube's web UI on port 9000 (-p 9000:9000).
- Expose an internal port 9092 for communication if necessary.
- Name the container sonarqube.

- After running the container, you can access SonarQube by navigating to http://localhost:9000 in your browser.
- pulling sonarqube image from dockeruse the docker ps command to check the status of the running container.
- sonarqube image latestLogin the SonarQube using the default credentials
- username: admin
- password: admin
- After Deafult login, You will be asked for the new SonarQube password. Give the password and click Save.SonarQube is all set let's install Trivy.
- set up the SonarQube to be integrated with Jenkins, Go to Server Url, and follow the below images.
- In the administration -> Users create a new token for jenkins usage.
- Copy the Unique credential for the token and go the the jenkins server URL. In the Jenkins Server URL, In Dashboard click manage Jenkins-> credentials and click on global.
- Click on the Add Credentials, and fill in the details of the token in the dialogue box.
- Choose kind as Secret Text and scope as Global. Put the copied unique code in the secret field, and add the ID and description to the token. Later this token will be used - to authenticate to SonarQube Server.
- Click on Create to create the Token.
- Now set up the SonarQube tool in the ManageJenkins -> Tools section and provide the SonarQube Url and Authentication token ID that we just created in jenkins Global Credentials.
- Set up the SonarQube scanner plugin installation in the Global Tools settings for easy SonarQube integration with Jenkins.
- Set up the Webhook connection with SonarQube.In Administration -> Configuration -> WebHooks.Webhooks in Sonarqube are used to tell the third Party(Jenkins) when the code analysis is complete.
- http://<JENKINS-IP:8090>/sonarqube-webhook
- Trivy Installation
- What is Trivy?
Trivy is an open-source vulnerability scanner developed by Aqua Security. It is used to scan container images, filesystems, Git repositories, and infrastructure-as-code (IaC) configurations for security vulnerabilities and misconfigurations.
**Why Use Trivy?**
- Security Vulnerability Detection - Identifies known CVEs (Common Vulnerabilities and Exposures) in container images, OS packages, and application dependencies.
- Lightweight and Fast - Trivy is efficient, performing scans quickly with minimal system resource usage.
- Developer-Friendly - Simple to install and use, making security checks an easy part of CI/CD pipelines.
- Comprehensive Scanning - Supports scanning for container images, Kubernetes manifests, Terraform files, and more.
- CI/CD Integration - Easily integrates with Jenkins, GitHub Actions, GitLab CI, and other DevOps tools.

**Importance of Trivy in DevOps**
- Ensures applications are secure before deployment.
- Prevents security vulnerabilities in containerized environments.
- Automates security scanning in CI/CD pipelines for continuous monitoring.
- Helps maintain compliance with security best practices.

- By using Trivy, teams can detect and fix vulnerabilities early, reducing the risk of security breaches in production.
 **Install Trivy on Jenkins Server.**
- vi trivy.sh
1sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y`
- Check the Trivy Version and Trivy is all set.

**Step 5: configure the installed jenkins plugins**
- Step 1: Go to Manage Jenkins in the Jenkins Dashboard.
- Step 2: Select Plugin from the option.
- Step 3: Select Available plugins search for Eclipse Temurin Installer and SonarQube Scanner, and click on Install. (without restart)
- Step 4: Set up Maven and jdk in the Global Tool section by choosing Tools in the Manage Jenkins.
- Step 5: Search for JDK and Maven boxes and fill the fields with the below details.
  
**Step 6: OWASP Dependency**
- What is OWASP and OWASP Dependency Check?
OWASP (Open Web Application Security Project) is a nonprofit organization focused on improving software security. It provides open-source tools, guidelines, and resources to help developers identify and mitigate security risks in web applications.
One of OWASP's tools is OWASP Dependency-Check, which is a security scanner that identifies vulnerable dependencies in a project. It detects libraries with known vulnerabilities by cross-referencing them with databases like the National Vulnerability Database (NVD).

**Why Use OWASP Dependency-Check?**
- Detects Known Vulnerabilities - Scans project dependencies for CVEs (Common Vulnerabilities and Exposures).
- Improves Software Security - Helps developers identify insecure libraries before deployment.
- Integrates with CI/CD Pipelines - Can be used in Jenkins, GitHub Actions, GitLab CI, and other automation tools.

- In the Dashboard -> ManageJenkins -> Plugins install the OWASP Dependency Check.
- After installing the plugin set up the tool for the OWASP dependency checker in the global tools section.(Dashboard -> Tools)
- Add the Dependency checker stage in the Jenkins file.

 **7: Setting Up Docker Plugins and Credentials**
Docker is an open-source platform that enables developers to build, package, and run applications in lightweight, portable containers. It simplifies application deployment by ensuring consistency across different environments, making it ideal for CI/CD pipelines and microservices architectures.

- step 1 Go to Dashboard -> Tools and search for Docker. Add the docker configuration details in the fields.
- docker tool installation on jenkinsstep 2: Navigate to Credentials Section
- Click on "Manage Jenkins" from the dashboard.
 Select "Manage Credentials".
- Choose "(global)" or a specific folder where you want to add credentials.
- Add New Credentials
- Click "Add Credentials" on the left panel.
- Select "Username with password" as the credential type.
- Enter:
- Username: Your Docker Hub or private registry username.
- Password: Your Docker Hub or private registry password.
- In the ID field, enter a unique identifier (e.g., docker-hub-credentials).
- Click "OK" to save.

**Step 8:Continuous Deployment Pipeline**
**Continuous Deployment Pipeline with Kubernetes**
A Continuous Deployment (CD) pipeline automates the process of deploying applications to production after they pass testing. This ensures faster releases, minimizes manual intervention, and improves software reliability.

**What is Kubernetes?**
Kubernetes (K8s) is an open-source container orchestration platform that automates the deployment, scaling, and management of containerized applications. Developed by Google and now maintained by the Cloud Native Computing Foundation (CNCF), Kubernetes is widely used for managing microservices and cloud-native applications.

**Why Use Kubernetes?**
- Automated Deployment & Scaling - Ensures high availability by automatically scaling applications based on demand.
- Self-Healing - Automatically restarts failed containers and reschedules them if a node crashes.
- Service Discovery & Load Balancing - Distributes traffic evenly across running containers.
- Declarative Configuration - Uses YAML/JSON manifests to define infrastructure and application deployment.
- Multi-Cloud & On-Premises Support - Runs on AWS (EKS), Google Cloud (GKE), Azure (AKS), or on-premises.
- Rolling Updates & Rollbacks - Allows seamless updates without downtime.
- Efficient Resource Utilization - Optimizes CPU and memory usage across nodes.

**Key Kubernetes Components**
- Pods - The smallest deployable unit, consisting of one or more containers.
- Nodes - Worker machines that run containerized applications.
- Deployments - Manage application updates and ensure the desired number of pods are running.
- Services - Enable communication between pods and external clients.
- ConfigMaps & Secrets - Manage configuration data and sensitive credentials securely.
- Ingress Controller - Handles external traffic routing to services using domain names.

**Using Kubernetes in a CI/CD Pipeline**
- When integrated into a Continuous Deployment (CD) pipeline, Kubernetes ensures seamless application delivery:
- Code is built and tested in Jenkins.
- Docker container is created and pushed to a registry (ECR, Docker Hub, etc.).
- Jenkins deploys the application to a Kubernetes cluster using kubectl, Helm, or ArgoCD.
- Kubernetes schedules and manages application pods automatically.

I have already used terraform infrastructure to set my EKS in AWS and generate my token.
- Step 1: Install the required kubernetes plugins:
- Step 2: Go to Dashboard -> Manage Jenkins -> Credentials -> Global and add the kubernetes cluster config file as the input for the kind secret file. Using this you can authenticate in the Api Server to run kubernetes command.
- Step 3: Use Pipeline Syntax to generate code for the kube config cli integration.
- Creating a Continous Integration Pipeline
- Creating a Continuous Integration (CI) pipeline automates code building, testing, and quality analysis, ensuring faster and more reliable software delivery.
 Step 1: Click on the New Item in the Jenkins Dashboard.
- Step 2: Enter the item name and select pipeline as the project type.
**
Create a Jenkins Pipeline Job.**
- Define the ****************Jenkinsfile:
- Full pipeline

`pipeline {
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
`
**pipeline was successfulConclusion**
By following this guide, you have successfully implemented a DevSecOps CI/CD pipeline with Jenkins, Kubernetes, Docker, and security scanning tools to ensure your application is secure, reliable, and continuously deployed. 🚀
🔹 Want more tutorials? Follow me for the latest updates!
