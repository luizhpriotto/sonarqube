
pipeline {
    agent any
    stages {
        stage('checkout') {
    		steps {
        		retry(env.TRY_COUNT) {
				timeout(time: 45, unit: 'SECONDS') {
					checkout scm
				}
        		}	
    		}
	}
        stage('Example') {
            steps {
                echo 'Hello World'
            }
        }
	stage('Analise Codigo') {
         steps {
             sh 'echo Analise SonarQube'
             sh 'dotnet-sonarscanner begin /k:"Dotnet" /d:sonar.host.url="http://192.168.1.18:9000" /d:sonar.login="4ccc5098f12d471a80e9df8999fd3a70ad0296c4"'
             sh 'dotnet build'
             sh 'dotnet-sonarscanner end /d:sonar.login="4ccc5098f12d471a80e9df8999fd3a70ad0296c4"'           
          }
        }
    }
    post { 
        always { 
            echo 'I will always say Hello again!'
        }
    }
}
