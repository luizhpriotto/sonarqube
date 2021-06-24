
pipeline {
    agent{
        node{
	    label 'dotnet'
	}
    }
    stages {
        stage('Hostname') {
            steps {
                sh 'hostname'
            }
        }
	stage('Analise Codigo') {
            steps {
	        withSonarQubeEnv('SonarQube'){
                    sh 'echo Analise SonarQube'
                    sh 'dotnet-sonarscanner begin /k:"Dotnet"'
                    sh 'dotnet build'
                    sh 'dotnet-sonarscanner end'
                }
            }
        }
	stage('Quality Gate'){
	    steps{
	        timeout(time: 1, unit: 'HOURS') {
		    waitForQualityGate abortPipeline: true	
		}
            }
        }
    }
}
