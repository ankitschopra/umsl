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
                sh "echo Test"
            }
        }

        stage('Build') {
            steps {
                sh 'echo "Building Docker Image - Skipping build to make it faster"'
                sh 'echo "./mvnw -Pprod verify jib:dockerBuild"'
                sh "docker tag umsl:latest ankitchopra2508/umsl:$BUILD_NUMBER"
                sh "docker login -u ankitchopra2508 -p connection"
                sh "docker push ankitchopra2508/umsl:$BUILD_NUMBER"
            }
        }
        stage('Deploy ECS') {
                    steps {
                        sh "echo Deploy"
                    }
                }
    }
}
