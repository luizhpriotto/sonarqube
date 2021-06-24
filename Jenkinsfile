
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
    }
    post { 
        always { 
            echo 'I will always say Hello again!'
        }
    }
}
