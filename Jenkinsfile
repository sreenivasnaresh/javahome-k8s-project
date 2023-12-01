pipeline {
    agent any
	tools {
		maven 'mvn'
	}

    stages {
        stage('Build the package') {
            steps {
                sh 'mvn clean package'
            }
        }
		
		stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
		
		stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
