FROM buildpack-deps:jessie-curl

RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
	 apt-get update && apt-get install -y  \
		bzip2 \
		unzip \
		xz-utils \
		software-properties-common \
		dirmngr \
	&& rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8
RUN add-apt-repository "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" 

# RUN echo  "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" >> /etc/apt/sources.list

RUN apt-get update && \
	apt-get install -y oracle-java8-installer && \
	rm -rf /var/lib/apt/lists/*  && \
	rm -rf /var/cache/oracle-jdk8-installer

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

RUN ln -svT /usr/lib/jvm/java-8-oracle /docker-java-home
ENV JAVA_HOME /docker-java-home

RUN set -ex; \
	update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
	update-alternatives --query java | grep -q 'Status: manual'


