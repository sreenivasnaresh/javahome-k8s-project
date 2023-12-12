pipeline {
    agent any
    options {
        buildDiscarder logRotator(daysToKeepStr: '2', numToKeepStr: '2')
    }

    stages {
        // stage('Build the source code using maven') {
        //     steps {
        //         sh 'mvn clean package'
        //     }
        // }
        stage('Docker build'){
            steps{
                sh 'docker build --tag vsnaresh/java-app:1.3 .'
            }
        }
        stage('Docker push'){
              steps{
                //   sshagent(['docker']) {
                //     sh 'ssh ubuntu@172.31.43.150 docker run -d -p 8095:8095 --name vsnaresh/java-app java-app:1.1'
                // }
                  withCredentials([usernamePassword(credentialsId: 'docker-cred', passwordVariable: 'pwd', usernameVariable: 'uName')]) {
                    sh "docker login -u ${uName} -p ${pwd}"
                    sh "docker push vsnaresh/java-app:1.3"
                  }
              }
        }

    }
}
