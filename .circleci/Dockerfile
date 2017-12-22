FROM debian:jessie as itms_installer

ENV ITMS_VERSION "1.9.7"
USER root

WORKDIR /tmp

# Install iTMSTransporter
ADD https://github.com/janpio/fastlane-ubuntu-foo/raw/master/iTMSTransporter_installer_linux_$ITMS_VERSION.sh .
RUN chmod +rx ./iTMSTransporter_installer_linux_$ITMS_VERSION.sh \
	&& ./iTMSTransporter_installer_linux_$ITMS_VERSION.sh --target itms --noexec \
	&& cd itms \
	&& sed -e '15,43d' -i install_script.sh \
	&& apt-get update \
	&& apt-get install sudo \
	&& ./install_script.sh

FROM buildpack-deps:jessie as xar_builder

ENV XAR_VERSION "1.6.1"
USER root

WORKDIR /tmp

# Build xar
ADD https://github.com/downloads/mackyle/xar/xar-$XAR_VERSION.tar.gz .
RUN tar -xzf xar-$XAR_VERSION.tar.gz \
	&& mv xar-$XAR_VERSION xar \
	&& cd xar \
	&& ./autogen.sh --noconfigure \
	&& ./configure \
	&& make 


###############
# Final image #
###############
FROM circleci/ruby:2.3
MAINTAINER milch

ENV PATH $PATH:/usr/local/itms/bin

# Java versions to be installed
ENV JAVA_VERSION 8u131
ENV JAVA_DEBIAN_VERSION 8u131-b11-1~bpo8+1
ENV CA_CERTIFICATES_JAVA_VERSION 20161107~bpo8+1

# Needed for fastlane to work
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Required for iTMSTransporter to find Java
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre

COPY --from=itms_installer /usr/local/itms /usr/local/itms
COPY --from=xar_builder /tmp/xar /tmp/xar

USER root

# iTMSTransporter needs java installed
# We also have to install make to install xar
# And finally shellcheck
RUN echo 'deb http://deb.debian.org/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
RUN apt-get update \
	&& apt-get install --yes \
		openjdk-8-jre-headless="$JAVA_DEBIAN_VERSION" \
		ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
		make \
		shellcheck \
	&& rm -rf /var/lib/apt/lists/* \
	&& /var/lib/dpkg/info/ca-certificates-java.postinst configure

USER circleci

RUN cd /tmp/xar \
	&& sudo make install \
	&& sudo rm -rf /tmp/*
