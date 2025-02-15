FROM nginx:mainline AS builder

LABEL mantainer="hakwerk <github@hakwerk.com>"

# ARG NGINX_VERSION is already set in the nginx:mainline image

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update -qqq && \
    apt-get install --no-install-recommends -qqq --yes \
        build-essential \
        ca-certificates \
        curl \
        git \
        libaio \
        libpcre2-dev \
        libssl-dev \
        libxslt1-dev \
        linux-headers \
        zlib1g-dev \
    && apt-get -y autoclean

RUN CONFIGURE_ARGS=$(nginx -V 2>&1 | grep arguments | cut -d':' -f2) && \
    echo -n "$CONFIGURE_ARGS" > /tmp/cfgargs

RUN mkdir /tmp/dav && \
    git clone --recursive --depth=1 https://github.com/arut/nginx-dav-ext-module.git /tmp/dav && \
    echo -n " --with-http_dav_module --add-module=/tmp/dav" >> /tmp/cfgargs

RUN mkdir /tmp/headers && \
    git clone --recursive --depth=1 https://github.com/openresty/headers-more-nginx-module.git /tmp/headers &&\
    echo -n " --add-module=/tmp/headers" >> /tmp/cfgargs

RUN mkdir /tmp/fancy && \
    git clone --recursive --depth=1 https://github.com/aperezdc/ngx-fancyindex.git /tmp/fancy &&\
    echo -n " --add-module=/tmp/fancy" >> /tmp/cfgargs

RUN mkdir /tmp/nginx && \
    curl --retry 3 --fail --show-error --silent --location --output /tmp/nginx.tar.gz "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" &&\
    tar -C /tmp/nginx --strip-components 1 -xzf /tmp/nginx.tar.gz

WORKDIR /tmp/nginx

RUN CONFIGURE_ARGS=$(cat /tmp/cfgargs | sed -e "s/--with-cc-opt='.*' //") && \
    ./configure ${CONFIGURE_ARGS} \
        --with-cc-opt="-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-${NGINX_VERSION}/debian/debuild-base/nginx-${NGINX_VERSION}=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC" \
        --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' && \
    make -j$(nproc) && \
    strip -s objs/nginx

RUN echo "** original libs:" && ldd /usr/sbin/nginx && \
    echo "** new libs:" && ldd objs/nginx


FROM nginx:mainline

COPY --from=builder /tmp/nginx/objs/nginx /usr/sbin/nginx

