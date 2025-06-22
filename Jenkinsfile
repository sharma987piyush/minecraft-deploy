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
                echo 'checkout the code....'
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "building docker image: ${ECR_REPOSITORY}:${IMAGE_TAG}"
                    sh "docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    echo "login in ecr..."
                    withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_REGION}") {
                        def ecrLoginCommand = "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                        sh ecrLoginCommand
                    }

                    echo "tag the image..."
                    sh "docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

                    echo "push image to ecr..."
                    sh "docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    echo "connecting eks..."
                    withAWS(credentials: "${AWS_CREDS_ID}", region: "${AWS_REGION}") {
                        sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"
                    }

                    echo "upadting deployment with new image..."
                    sh "kubectl set image deployment/minecraft-deployment minecraft-server=${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

                    echo "Deployment complete!"
                }
            }
        }
    }
}
