pipeline {
    agent any
    stages {
        stage('Build the source code using maven') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Docker build'){
            steps{
                sh 'docker build -t first-image/java-app:1.0 .'
            }
        }

    }
}
