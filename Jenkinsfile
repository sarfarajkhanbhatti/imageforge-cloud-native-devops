pipeline {
    agent any

    environment {
        IMAGE_NAME      = 'imageforge'
        CONTAINER_NAME  = 'imageforge'
        AWS_REGION      = 'us-east-1'
        ECR_REPOSITORY  = 'imageforge'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    python3 -m venv .venv
                    .venv/bin/python -m pip install --upgrade pip
                    .venv/bin/pip install -r app/requirements.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    .venv/bin/python -m pytest -v
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest
                '''
            }
        }

        stage('Docker Test') {
            steps {
                sh '''
                    docker rm -f ${CONTAINER_NAME} 2>/dev/null || true

                    docker run -d \
                        --name ${CONTAINER_NAME} \
                        -p 5000:5000 \
                        ${IMAGE_NAME}:${BUILD_NUMBER}

                    sleep 5

                    curl --fail http://localhost:5000/health

                    docker rm -f ${CONTAINER_NAME}
                '''
            }
        }

        stage('AWS Identity Check') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-imageforge']
                ]) {
                    sh '''
                        echo "Checking AWS identity..."

                        aws sts get-caller-identity

                        echo "AWS authentication successful."
                    '''
                }
            }
        }

        stage('ECR Login') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-imageforge']
                ]) {
                    sh '''
                        AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account \
                            --output text)

                        ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                        echo "Logging in to ECR..."

                        aws ecr get-login-password \
                            --region "${AWS_REGION}" | \
                        docker login \
                            --username AWS \
                            --password-stdin "${ECR_REGISTRY}"
                    '''
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-imageforge']
                ]) {
                    sh '''
                        AWS_ACCOUNT_ID=$(aws sts get-caller-identity \
                            --query Account \
                            --output text)

                        ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

                        ECR_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}"

                        echo "Tagging Docker image..."

                        docker tag \
                            "${IMAGE_NAME}:${BUILD_NUMBER}" \
                            "${ECR_IMAGE}:${BUILD_NUMBER}"

                        docker tag \
                            "${IMAGE_NAME}:${BUILD_NUMBER}" \
                            "${ECR_IMAGE}:latest"

                        echo "Pushing build ${BUILD_NUMBER} to ECR..."

                        docker push \
                            "${ECR_IMAGE}:${BUILD_NUMBER}"

                        echo "Pushing latest image to ECR..."

                        docker push \
                            "${ECR_IMAGE}:latest"

                        echo "ECR push completed successfully."
                    '''
                }
            }
        }
    }

    post {

        always {
            sh '''
                docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
            '''
        }

        success {
            echo 'ImageForge CI/CD build completed successfully.'
        }

        failure {
            echo 'ImageForge CI/CD pipeline failed.'
        }
    }
}