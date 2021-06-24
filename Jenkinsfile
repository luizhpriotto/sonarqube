
pipeline {
    agent{
        node{
	    label 'dotnet'
	}
    }
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
        stage('Hostname') {
            steps {
                sh 'hostname'
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
	stage('Quality Gate"){
            timeout(time: 1, unit: 'HOURS') {
	        def qg = waitForQualityGate()
		    if (qg.status != 'SUCCESS') {
		        error "Pipeline aborted due to quality gate failure: ${qg.status}"
		    }
	    }
        }
    }
    post { 
        always { 
            echo 'I will always say Hello again!'
        }
    }
}
