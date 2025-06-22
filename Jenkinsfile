pipeline {
    agent any

    environment {
        AWS_REGION            = 'us-east-1'
        AWS_ACCOUNT_ID        = '395305481503'
        ECR_REPOSITORY_NAME   = 'mine-ecr'
        EKS_CLUSTER_NAME      = 'my-minecraft-cluster'
        K8S_DEPLOYMENT_NAME   = 'minecraft-deployment'
        K8S_CONTAINER_NAME    = 'minecraft-server'
        AWS_CREDS_ID          = 'aws-cred'
        
        IMAGE_TAG             = "build-${BUILD_NUMBER}"
        ECR_REGISTRY_URL      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_IMAGE_URL         = "${ECR_REGISTRY_URL}/${ECR_REPOSITORY_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('2. Build Docker Image') {
            steps {
                sh "docker build -t ${ECR_REPOSITORY_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('3. Push to Amazon ECR') {
            steps {
                // Saara logic is script block ke andar hona chahiye
                script {
                    withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_REGION}") {
                        def ecrLoginCommand = "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY_URL}"
                        sh ecrLoginCommand
                        sh "docker tag ${ECR_REPOSITORY_NAME}:${IMAGE_TAG} ${ECR_IMAGE_URL}"
                        sh "docker push ${ECR_IMAGE_URL}"
                    }
                }
            }
        }
        stage('4. Deploy to Amazon EKS (DEBUGGING)') {
            steps {
                script {
                    echo "--- DEBUGGING START ---"
                    echo "Current directory mein saari files check kar raha hoon:"
                    
                    // Yeh command saari files aur folders ko detail mein list karegi
                    sh 'ls -la' 

                    echo "--- DEBUGGING END ---"

                    // Asli deployment ko abhi ke liye rok diya gaya hai
                    /* withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_REGION}") {
                        sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"
                        sh "sed -i 's|image:.*|image: ${ECR_IMAGE_URL}|g' deployment.yaml"
                        sh 'kubectl apply -f deployment.yaml'
                        sh 'kubectl apply -f service.yaml'
                    }
                    */
                }
            }
        }
        stage('5. Deploy to Amazon EKS') {
            steps {
                // Yahan bhi saara logic script block ke andar hai
                script {
                    withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_REGION}") {
                        sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"
                        sh "sed -i 's|image:.*|image: ${ECR_IMAGE_URL}|g' deploy.yml"
                        sh 'kubectl apply -f deploy.yml'
                        sh 'kubectl apply -f service.yml'
                        sh 'kubectl apply -f hpa.yml'
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
