FROM busybox:1-uclibc AS downloader

ENV ACE_STREAM_VERSION "3.2.3_ubuntu_18.04_x86_64_py3.8"

RUN mkdir /tmp/acestream
RUN wget -O - https://download.acestream.media/linux/acestream_${ACE_STREAM_VERSION}.tar.gz | tar -xz -C /tmp/acestream
RUN rm /tmp/acestream/acestream.conf

FROM python:3.8-slim-bookworm@sha256:a51755c25dcd620a3dfea51b18668769c80368762d7616ca6a46354837e9a108
LABEL org.opencontainers.image.source https://github.com/trexx/docker-acestream-engine

# renovate: datasource=github-releases depName=krallin/tini
ENV TINI_VERSION "v0.19.0"
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini-static
RUN chmod +x /tini-static

COPY --from=downloader --link /tmp/acestream /app
WORKDIR /app
ENV LD_LIBRARY_PATH "/app/lib"

RUN pip install --no-cache-dir -r ./requirements.txt

EXPOSE 6878/tcp
