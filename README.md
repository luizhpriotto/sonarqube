
Iniciando Sonarqube
```
docker-compose up -d
```
Efetuado testes utilizando Ubuntu 20.04
```
apt install multipass
multipass launch --cpus 2 --mem 4G --disk 15G --name sonarqube-test
multipass shell sonarqube-test
sudo su
sysctl -w vm.max_map_count=262144
apt install default-jre docker.io
wget https://get.jenkins.io/war-stable/2.289.1/jenkins.war
java -jar jenkins.war --httpPort=9090
```
Preparação da "VM"
```
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-5.0 unzip git default-jre nodejs
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip
unzip sonar-scanner-cli-4.6.2.2472-linux.zip -d /opt
export PATH=$PATH:/opt/sonar-scanner-4.6.2.2472-linux/bin
dotnet tool install --global dotnet-sonarscanner
```
Testando um projeto Dotnet e um Python
```
git  clone https://github.com/prefeiturasp/SME-Aplicativo-Aluno-API.git dotnet
cd dotnet
dotnet-sonarscanner begin /k:"Dotnet" /d:sonar.host.url="http://192.168.1.18:9000" /d:sonar.login="4ccc5098f12d471a80e9df8999fd3a70ad0296c4"
dotnet build
dotnet-sonarscanner end /d:sonar.login="4ccc5098f12d471a80e9df8999fd3a70ad0296c4"
cd ..
git clone https://github.com/prefeiturasp/SME-Imoveis-BackEnd.git python
cd python
sonar-scanner \
  -Dsonar.projectKey=Python \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://192.168.1.18:9000 \
  -Dsonar.login=b015ac84a610b6453cd81d6b6bf0271ac5c1748e
 ```
### Sonarqube

Iremos inciar um ambiente Jenkins para utilizar o serviço do Sonarqube a fim de validar seu funcionamento.

Caso decida iniciar o Sonarqube de testes utilizando a configuração de produção execute o restore do dump deste repositório.

Para um novo backup, acesse o ambiente atual do Sonarqube e execute o comando abaixo com os determinados ajustes:

```
docker exec -u postgres c211534024a2 pg_dump -Fc -U sonar sonar > /tmp/sonar-23-06-2021.dump
```
**Iniciar o Sonarqube**

Copie o arquivo docker-compose.yml para "/srv/sonarqube".

Acesse "/srv/sonarqube" e execute:

```
docker-compose up -d
```

Acesse http://localhost:9000/ login e senha padrão é admin/admin.

**Restore**

Para efetuar o restore da base de produção, pare o container apenas do Sonarqube, mantendo o postgres ativo e execute os comandos abaixo para limpar a base atual.

```
docker exec -it c211534024a2 /bin/bash
root@c211534024a2:/# su - postgres
postgres@c211534024a2:~$ psql -U sonar
sonar=# \connect sonar
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO sonar;
GRANT ALL ON SCHEMA public TO public;
```

Na sequencia efetue o restore do database:

```
docker exec -u postgres c211534024a2 pg_restore -Fc -U sonar -d sonar /tmp/restore/sonar-23-06-2021.dump
```
**Jenkins**

Iniciando o Jenkins:

```
apt install default-jre
wget https://get.jenkins.io/war-stable/2.289.1/jenkins.war
java -jar jenkins.war --httpPort=9090
```
Instale os plugins do Docker plugin, SonarQube Scanner for Jenkins, Git e Pipeline.

Com o fim da instalação, acesse a configuração do docker como node.

http://IP:9090/configureClouds/

Configure o acesso ao serviço do Docker.

Preparando uma imagem de container para executar os testes do SonarQube.
```
docker build -t dotnet .
```
Depois ajuste esta imagem no template de agentes do Docker, mesmo local onde foi configurado o acesso ao serviço do Docker.

Este container seŕa utilizado para efetuar os testes do SonarQube.

Configurando conexão com o Sonar:

Acesse "account" e depois "security", efetue a geração de um novo token:

Efetue a copia do Token para ser utilizado na configuração do plugin do Sonar no Jenkins. Marque a opção "Environment variables".

Configurando conexão com o Jenkins:

Acesse o Sonar em "Configuration" e "Webhooks".

http://IP:9090/sonarqube-webhook

A função **withSonarQubeEnv('SonarQube')** injeta as variaveis de conexão ao Sonar.
A função **waitForQualityGate abortPipeline: true** aguarda os resultados do Sonar e dependedo do resultado, aborta a esteira.

Pipeline:

```
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
```
