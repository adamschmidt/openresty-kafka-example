FROM centos:7

RUN yum update -y && yum clean all

RUN yum install -y \
    nc \
    tar \
    unzip \
    wget \
    net-tools \
    libreadline-devel \
    libncurses5-devel \
    pcre-devel \
    openssl-devel \
    libuuid \
    perl \
    git \
    && yum clean all

RUN yum groupinstall -y 'Development Tools'

ENV OPENRESTY_VERSION 1.13.6.2

RUN wget -P /tmp -q https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && \
    cd /opt && tar zxf /tmp/openresty-${OPENRESTY_VERSION}.tar.gz && rm /tmp/openresty-${OPENRESTY_VERSION}.tar.gz && \
    cd openresty-${OPENRESTY_VERSION} && \
    ./configure -j2 --with-pcre-jit --with-ipv6 && \
    make -j2 && make install

RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

EXPOSE 80 443

COPY files /

RUN mkdir /opt/lua && cd /opt/lua && \
    git clone https://github.com/doujiang24/lua-resty-kafka.git && \
    git clone https://github.com/bungle/lua-resty-uuid.git
