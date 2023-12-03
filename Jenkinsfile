pipeline {
    agent any
    options {
        buildDiscarder logRotator(daysToKeepStr: '2', numToKeepStr: '2')
    }

    stages {
        stage('Build the source code using maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Docker build'){
            steps{
                sh 'docker buildx build -t java-app:1.0 .'
            }
        }

    }
}
