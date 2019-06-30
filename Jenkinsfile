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
                sh 'echo "Building Docker Image"'
                sh './mvnw -Pprod verify jib:dockerBuild'
                sh "docker tag umsl:latest ankitschopra/umsl:$BUILD_NUMBER"
                sh "docker push ankitschopra/umsl:$BUILD_NUMBER"
            }
        }
        stage('Deploy ECS') {
                    steps {
                        sh "echo Deploy"
                    }
                }
    }
}
