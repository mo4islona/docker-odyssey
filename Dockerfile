FROM debian:bookworm-slim as builder

WORKDIR /tmp/

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    curl \
    lsb-release \
    ca-certificates \
    libssl-dev \
    gnupg \
    openssl

RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
       cmake \
       gcc \
       gdb \
       git \
       libpam-dev \
       libzstd-dev \
       zlib1g-dev \
       valgrind \
       libpq-dev \
       vim \
       postgresql-common \
       postgresql-server-dev-all \
    && git clone https://github.com/yandex/odyssey.git \
    && cd odyssey \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_DEBIAN=1 -DUSE_SCRAM=1 .. \
    && make

FROM debian:bookworm-slim

RUN set -ex \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        libssl-dev  \
        openssl  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY --from=builder /tmp/odyssey/build/sources/odyssey /usr/local/bin/

RUN mkdir /etc/odyssey

ADD conf/odyssey.conf conf/routing.conf /etc/odyssey/

EXPOSE 6432

ENTRYPOINT ["/usr/local/bin/odyssey", "/etc/odyssey/odyssey.conf"]
