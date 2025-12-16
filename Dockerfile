FROM debian:trixie AS ts3server-prep

RUN apt-get update && apt-get install -y \
    curl \
    cmake \
    build-essential \
    git \
    python3

ARG BOX64_VERSION=0.3.8

RUN cd /tmp && \ 
    git clone --depth=1 --branch v${BOX64_VERSION} https://github.com/ptitSeb/box64.git; \
    cd box64; \
    echo "" > postinst; \
    mkdir build; \
    cd build; \
    cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=Release; \
    make -j$(nproc); \
    cpack ;\
    mv box64-*.deb /tmp/box64.deb; 

ENV DEBIAN_FRONTEND=noninteractive

RUN cd /tmp && \
    dpkg --add-architecture amd64; \
    apt-get update; \
    apt-get install -y libmariadb-dev:amd64 libssl-dev:amd64; \
    cd /usr/lib/x86_64-linux-gnu/; \
    ln -s libmariadb.so.3 libmariadb.so.2; 

# # use new image and copy 
FROM debian:trixie-slim

RUN mkdir -p /usr/lib/x86_64-linux-gnu

COPY --from=ts3server-prep /tmp/box64.deb /tmp/box64.deb
COPY --from=ts3server-prep /usr/lib/x86_64-linux-gnu/libssl* /usr/lib/x86_64-linux-gnu
COPY --from=ts3server-prep /usr/lib/x86_64-linux-gnu/libmariadb* /usr/lib/x86_64-linux-gnu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y ca-certificates wget lbzip2 libssl3 locales

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8  

RUN set -eux; \
    groupadd -g 9987 ts3server; \
    useradd -u 9987 -d /var/ts3server -g ts3server ts3server; \
    install -d -o ts3server -g ts3server -m 775 /var/ts3server /var/run/ts3server /opt/ts3server


ARG TEAMSPEAK_URL=https://files.teamspeak-services.com/releases/server/3.13.7/teamspeak3-server_linux_amd64-3.13.7.tar.bz2

RUN set -eux; \
    wget "${TEAMSPEAK_URL}" -O server.tar.bz2; \
    mkdir -p /opt/ts3server; \
    tar -xf server.tar.bz2 --strip-components=1 -C /opt/ts3server; \
    rm server.tar.bz2; \
    chown -R ts3server:ts3server /opt/ts3server; 

RUN dpkg -i /tmp/box64.deb; \
    rm /tmp/box64.deb;

ENV PATH="${PATH}:/opt/ts3server"
ENV BOX64_EMULATED_LIBS=libmariadb.so.2:libcrypto.so.3

USER ts3server:ts3server

# setup directory where user data is stored
VOLUME /var/ts3server/
WORKDIR /var/ts3server/

#  9987 default voice
# 10011 server query
# 30033 file transport
EXPOSE 9987/udp 10011 30033 

COPY entrypoint.sh /opt/ts3server

ENTRYPOINT [ "entrypoint.sh" ]
CMD [ "ts3server" ]
