# Reference: https://github.com/jenkinsci/docker/blob/587b2856cd225bb152c4abeeaaa24934c75aa460/Dockerfile
#Reference: https://www.jenkins.io/doc/book/installing/docker/
#Adoptium Eclipse Temurin JDK 17
ARG JENKINS_RELEASE=lts-jdk17
FROM jenkins/jenkins:${JENKINS_RELEASE}
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN apt-get update \
    && apt-get install -y --no-install-recommends

RUN echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

#RUN apt-get install sudo && apt install -y lsb-core

RUN  apt-get install -y apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    dumb-init \
    git \
    inotify-tools \
    npm \
    jq \
    gnupg \
    gpg \
    tini \
    unzip \
    tar \
    wget

RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
    https://download.docker.com/linux/debian/gpg

RUN apt-get update && apt-get install -y docker-ce-cli

RUN apt-get update && apt-get install -y maven
#Install ANT
RUN mkdir -p /opt/ant
RUN wget https://downloads.apache.org/ant/binaries/apache-ant-1.10.12-bin.tar.gz -P /opt/ant
RUN tar -xvzf /opt/ant/apache-ant-1.10.12-bin.tar.gz -C /opt/ant/
RUN rm -f /opt/ant/apache-ant-1.9.8-bin.tar.gz

#Set JAVA_HOME path in Docker container for Jenkins
ENV JAVA_HOME=/opt/java/openjdk
#Update Path
ENV PATH="${PATH}:${HOME}/bin:${JAVA_HOME}/bin"

#Set Ant Home in Docker container for Jenkins
ENV ANT_HOME=/opt/ant/apache-ant-1.10.12
#Set Ant Params in Docker for Jenkins
ENV ANT_OPTS="-Xms256M -Xmx512M"
#Update Path
ENV PATH="${PATH}:${HOME}/bin:${ANT_HOME}/bin"

#Install GRADLE
ENV GRADLE_VERSION=7.5.1
ENV GRADLE_USER_HOME /.gradle
ENV GRADLE_HOME=/opt/gradle

RUN set -o errexit -o nounset \
	&& echo "Downloading Gradle" \
	&& curl -Lo gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
	&& echo "Testing Gradle installation" \
	&& gradle --version

# .gradle and .android are a cache folders
RUN mkdir -p ${GRADLE_USER_HOME}/caches /.android \
	&& chmod -R 777 ${GRADLE_USER_HOME} \
	&& chmod 777 /.android

ENV MAVEN_OPTS="-Dmaven.wagon.provider.http=httpclient -Dmaven.artifact.threads=8 -Dhttp.tcp.nodelay=false -Xmx4096m -Xms1024m"

#Install and setup NodeJs
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.8 docker-workflow:521.v1a_a_dd2073b_2e"