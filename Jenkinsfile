pipeline {
    agent any
	tools {
		maven 'mvn'
	}

    stages {
        stage('Build the source code using maven') {
            steps {
                sh 'mvn clean package'
            }
        }

    }
}
