FROM centos:7
MAINTAINER Marco Palladino, marco@mashape.com

ENV KONG_VERSION 0.9.8
ENV PROJECT_WORKPLACE /opt/kong

RUN mkdir -p $PROJECT_WORKPLACE/build
COPY . $PROJECT_WORKPLACE/build

RUN yum install -y netcat openssl libpcre3 dnsmasq procps perl git curl make pkg-config unzip libpcre3-dev
RUN export PATH=$PATH:/usr/local/bin:/usr/local/openresty/bin

# install kong (first install any version of Kong for its dependencies, then override with our own Kong build)
RUN yum install -y wget https://github.com/Mashape/kong/releases/download/$KONG_VERSION/kong-$KONG_VERSION.el7.noarch.rpm
WORKDIR $PROJECT_WORKPLACE/build
RUN make install
RUN yum clean all

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 && \
    chmod +x /usr/local/bin/dumb-init

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 7946
CMD ["kong", "start"]
