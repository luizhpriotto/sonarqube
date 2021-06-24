FROM ubuntu:20.04
USER root
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget && wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https dotnet-sdk-5.0 default-jre nodejs wget unzip git && \
	wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip && \
	unzip sonar-scanner-cli-4.6.2.2472-linux.zip -d /opt
ENV PATH="/opt/sonar-scanner-4.6.2.2472-linux/bin:/root/.dotnet/tools:${PATH}"
RUN dotnet tool install --global dotnet-sonarscanner
