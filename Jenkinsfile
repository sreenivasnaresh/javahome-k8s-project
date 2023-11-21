pipeline {
	agent any
	tools {
		
		maven 'mvn3'
	}
	stages {
		stage('Maven Build') {
			steps {
				sh 'mvn clean package'
			}
		}
		
		stage('Docker Build image') {
			steps {
				sh "docker build . -t amiyaranjansahoo/dockerapp:v1 "
			}
		}
		
		stage('Push to docker hub') {
			steps {
				withCredentials([string(credentialsId: 'dockerhub', variable: 'dockerpwd')]) {
					sh "docker login -u amiyaranjansahoo -p ${dockerpwd}"
					sh "docker push amiyaranjansahoo/dockerapp:v1"
				}
			}
		}
		
		
	}

}
