# Dockerfile for HistoQC.
# 
# This Dockerfile uses two stages. In the first, the project's python dependencies are
# installed. This requires a C compiler. In the second stage, the HistoQC directory and
# the python environment are copied over. We do not require a C compiler in the second
# stage, and so we can use a slimmer base image.

FROM python:3.8 AS builder
ARG DEBIAN_FRONTEND=noninteractive

# download build items
RUN apt-get update \
    && apt-get install -y \
        git \
        unzip \
        curl \
        autotools-dev \
        autoconf \
        automake \
        make \
        libtool \
        zlib1g-dev \
        libc6-dev \
        libcairo2-dev \
        libgdk-pixbuf-2.0-dev \
        libglib2.0-dev \
        libjpeg62-turbo \
        libopenjp2-7-dev \
        libjpeg-dev \
        libpng-dev \
        libsqlite3-dev \
        libtiff5-dev \
        libxml2-dev \
        pkg-config \
        libtk8.6 \
    && rm -rf /var/lib/apt/lists/*  

# dumb init for process management
RUN mkdir /pipe && curl -L -o /pipe/dumb-init \
    https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 && \
    chmod +x /pipe/dumb-init

# glencoe bioformats converters
RUN cd / && curl -L -o bf2raw.zip https://github.com/glencoesoftware/bioformats2raw/releases/download/v0.5.0rc2/bioformats2raw-0.5.0-rc2.zip && \
    curl -L -o raw2ometiff.zip https://github.com/glencoesoftware/raw2ometiff/releases/download/v0.3.1rc1/raw2ometiff-0.3.1-rc1.zip && \
    unzip -qod /pipe "bf2raw.zip" && \
     unzip -qod /pipe "raw2ometiff.zip" && rm *.zip

# compile an openslide library with huron drivers
RUN cd /tmp && git clone https://github.com/barrettMCW/openslideLLAB.git && \
    cd openslideLLAB && autoreconf -i && \
    ./configure && make && make install

# copy our local hqc files over
WORKDIR /opt/HistoQC
COPY . .
RUN mv pipe/* /pipe

# Create virtual environment for this project. This makes it easier to copy the Python
# installation into the second stage of the build.
ENV PATH="/opt/HistoQC/venv/bin:$PATH"
RUN python -m venv venv \
    && python -m pip install --no-cache-dir setuptools wheel \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir . \
    # We force this so there is no error even if the dll does not exist.
    && rm -f libopenslide-0.dll 

#
## SLIMMIN TIME
#
FROM python:3.8-slim
ARG DEBIAN_FRONTEND=noninteractive

#install unmodified runtime libraries
RUN apt-get update \
    && apt-get install -y --no-install-recommends\
    default-jre-headless \
    libopenslide0 \
    libblosc1 \
    zip \
    inotify-tools \
    ssmtp \
    mailutils && \
    rm -rf /var/lib/apt/lists/*

#install openslide
COPY --from=builder /usr/local/lib/libopenslide* /usr/local/lib/
ENV LD_LIBRARY_PATH="/usr/local/lib/"

# get our hqc back
WORKDIR /opt/HistoQC
COPY --from=builder /opt/HistoQC/ .
ENV PATH="/opt/HistoQC/venv/bin:$PATH"

# get our scripts back 
COPY --from=builder /pipe/* /docker/

# bash pipeline constructor
ENTRYPOINT [ "/docker/entrypoint.sh" ]