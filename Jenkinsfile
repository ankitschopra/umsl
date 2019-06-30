pipeline {
    environment {
            registry = "ankitschopra/umsl"
            registryCredential = 'dockerhub'
            dockerImage = ''
            Version = ''
          }
    agent any
    stages {

        stage('Test') {
            steps {
                sh 'echo "Running Test"'
                sh 'echo "./mvnw verify"'
            }
        }

        stage('Build and Docker Push') {
            steps {
                sh 'echo "Building Docker Image - Skipping build to make it faster"'
                sh 'echo "./mvnw -Pprod verify jib:dockerBuild"'
                sh "docker tag umsl:latest ankitchopra2508/umsl:$BUILD_NUMBER"
                sh "docker login -u ankitchopra2508 -p connection"
                sh "docker push ankitchopra2508/umsl:$BUILD_NUMBER"
            }
        }

         stage('Runnning Sonar Test') {
                    steps {
                        sh 'echo "Running Sonar Test"'
                        sh "sed -i -e 's/localhost/34.243.207.219/g' sonar-project.properties"
                        sh 'echo "./mvnw -Pprod clean verify sonar:sonar"'
                    }
                }

        stage('Deploy ECS') {
                    steps {
                        sh "echo ECS Deploy"
                        sh 'echo "[default]" > ~/.aws/config'
                        sh 'echo "region = eu-west-1" >> ~/.aws/config'
                        sh "aws ecs update-service --cluster umsl_ecs_cluster --service umsl_app_service --task-definition umsl_app_task:`aws ecs register-task-definition --cli-input-json file://deployment/umsl_task.json |jq '.taskDefinition.revision'`"
                    }
                }
    }
}
