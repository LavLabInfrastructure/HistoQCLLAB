# Dockerfile for HistoQC.
# 
# This Dockerfile uses two stages. In the first, the project's python dependencies are
# installed. This requires a C compiler. In the second stage, the HistoQC directory and
# the python environment are copied over. We do not require a C compiler in the second
# stage, and so we can use a slimmer base image.

FROM python:3.8 AS builder
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/HistoQC
COPY . .
# Create virtual environment for this project. This makes it easier to copy the Python
# installation into the second stage of the build.
ENV PATH="/opt/HistoQC/venv/bin:$PATH"
RUN python -m venv venv \
    && python -m pip install --no-cache-dir setuptools wheel \
    && python -m pip install --no-cache-dir -r requirements.txt \
    && python -m pip install --no-cache-dir . \
    && pip install omero-py \
    # We force this so there is no error even if the dll does not exist.
    && rm -f libopenslide-0.dll

FROM python:3.8-slim
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/HistoQC
COPY --from=builder /opt/HistoQC/ .
ENV PATH="/opt/HistoQC/venv/bin:$PATH"
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
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
    && rm -rf /var/lib/apt/lists/* && \
    cd /tmp && git clone https://github.com/barrettMCW/openslideLLAB.git && \
    cd openslideLLAB && autoreconf -i && \
    ./configure && make && make install
ENV LD_LIBRARY_PATH="/usr/local/lib/"
