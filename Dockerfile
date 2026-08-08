ARG TARGETPLATFORM=linux/amd64
FROM --platform=${TARGETPLATFORM} ubuntu:22.04

# Evita que apt pida confirmaciones interactivas durante el build
ENV DEBIAN_FRONTEND=noninteractive

# 1. Actualizar e instalar la arquitectura i386 + todas las dependencias necesarias
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        curl \
        git \
        make \
        unzip \
        wget \
        wine \
        wine32:i386 \
    && rm -rf /var/lib/apt/lists/*

# Install Pasmo
RUN wget https://pasmo.speccy.org/bin/pasmo-0.5.5.tar.gz \
    && tar -xvzf pasmo-0.5.5.tar.gz \
    && cd pasmo-0.5.5 && ./configure && make && make install \
    && cd ..

# Install libdsk
RUN wget https://www.seasip.info/Unix/LibDsk/libdsk-1.5.22.tar.gz \
    && tar -xvzf libdsk-1.5.22.tar.gz \
    && cd libdsk-1.5.22 && ./configure && make && make install \
    && cd ..

# Install mkp3fs, specform and tapget utilities
RUN wget http://www.seasip.info/ZX/taptools-1.0.8.tar.gz \
    && tar -xvzf taptools-1.0.8.tar.gz \
    && cd taptools-1.0.8 && ./configure && make && make install \
    && cd ..

# Install apack compressor
RUN wget http://www.smspower.org/maxim/uploads/SMSSoftware/aplib12.zip \
    && unzip aplib12.zip -d /opt/aplib \
    && echo '#!/bin/sh' > /usr/local/bin/apack \
    && echo 'WINEDEBUG=-all wine /opt/aplib/appack.exe c "$1" "$2"' >> /usr/local/bin/apack \
    && chmod +x /usr/local/bin/apack \
    && rm aplib12.zip

# Install zmakebas
RUN git clone https://github.com/z00m128/zmakebas \
    && cd zmakebas && make && make install \
    && cd ..

# Install hdfmonkey
RUN git clone https://github.com/gasman/hdfmonkey \
    && cd hdfmonkey && autoheader && aclocal && autoconf && automake -a && ./configure && make && make install \
    && cd ..

# Install dskgen
RUN git clone https://github.com/AugustoRuiz/dskgen \
    && cd dskgen && make -f Makefile.others && cp bin/dskgen /usr/local/bin/dskgen \
    && cd ..

# 1. Copiar únicamente los archivos necesarios para compilar las herramientas
COPY tools/fill16k.c /tmp/fill16k.c
COPY src/gentap.src/ /tmp/gentap.src/

# 2. Compilar e instalar los binarios en el sistema
RUN gcc /tmp/fill16k.c -o /usr/local/bin/fill16k \
    && gcc /tmp/gentap.src/*.c -o /usr/local/bin/gentap \
    && chmod +x /usr/local/bin/fill16k /usr/local/bin/gentap \
    && rm -rf /tmp/fill16k.c /tmp/gentap.src

# Opcional: asegurador para ejecuciones que busquen ./gentap en PATH
RUN ln -s /usr/local/bin/gentap /usr/bin/gentap

# Update library load config
RUN ldconfig

# Create directory for source code

RUN mkdir /src

WORKDIR /src/src

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "bash"]
CMD ["-i"]

# Usage: docker run -v $(pwd):/src -it ianna
# cd src/src
# make