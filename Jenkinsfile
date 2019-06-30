pipeline {
    environment {
            registry = "ankitschopra/umsl"
            registryCredential = 'dockerhub'
            dockerImage = ''
          }
    agent any
    stages {

        stage('Test') {
            steps {
                sh 'echo "Running Test"'
                sh './mvnw verify'
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
                        sh './mvnw -Pprod clean verify sonar:sonar'
                    }
                }

        stage('Deploy ECS') {
                    steps {
                        sh "echo Deploy"
                    }
                }
    }
}
