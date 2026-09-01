pipeline {
    agent any

    environment {
        IMAGE_NAME = 'imageforge'
        CONTAINER_NAME = 'imageforge'
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
                    python3 -m pip install --upgrade pip
                    pip3 install -r app/requirements.txt
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                sh '''
                    python3 -m pytest -v
                '''
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
                    docker rm -f ${CONTAINER_NAME} || true

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
    }

    post {
        always {
            sh '''
                docker rm -f ${CONTAINER_NAME} 2>/dev/null || true
            '''
        }

        success {
            echo 'ImageForge CI pipeline completed successfully.'
        }

        failure {
            echo 'ImageForge CI pipeline failed.'
        }
    }
}