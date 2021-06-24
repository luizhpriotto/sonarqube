
Iniciando Sonarqube
```
docker-compose up -d
```
Efetuado testes utilizando Ubuntu 20.04
```
multipass launch --cpus 2 --mem 4G --disk 15G --name sonarqube-test
multipass shell sonarqube=test
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

