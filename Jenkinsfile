pipeline {
    agent any
    
    environment {
        AWS_REGION        = 'us-east-1'
        ECR_REGISTRY      = '395305481503.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY    = 'mine-ecr'
        IMAGE_TAG         = "build-${BUILD_NUMBER}"
        EKS_CLUSTER_NAME  = 'my-minecraft-cluster'
        AWS_CREDS_ID      = 'aws-cred'
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_REGION}") {
                        def ecrLoginCommand = "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                        sh ecrLoginCommand
                        sh "docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                        sh "docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_REGION}") {
                        sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"
                        sh "kubectl set image deployment/minecraft-deployment minecraft-server=${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                    }
                }
            }
        }
    }
}
