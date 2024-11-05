FROM busybox:1-uclibc AS downloader

ENV ACE_STREAM_VERSION "3.2.3_ubuntu_18.04_x86_64_py3.8"

RUN mkdir /tmp/acestream
RUN wget -O - https://download.acestream.media/linux/acestream_${ACE_STREAM_VERSION}.tar.gz | tar -xz -C /tmp/acestream
RUN rm /tmp/acestream/acestream.conf

FROM python:3.13-slim-bookworm@sha256:751d8bece269ba9e672b3f2226050e7e6fb3f3da3408b5dcb5d415a054fcb061
LABEL org.opencontainers.image.source https://github.com/trexx/docker-acestream-engine

# renovate: datasource=github-releases depName=openSUSE/catatonit
ENV CATATONIT_VERSION="v0.2.0"
ADD https://github.com/openSUSE/catatonit/releases/download/${CATATONIT_VERSION}/catatonit.x86_64 /catatonit
RUN chmod +x /catatonit

COPY --from=downloader --link /tmp/acestream /app
WORKDIR /app
ENV LD_LIBRARY_PATH "/app/lib"

RUN pip install --no-cache-dir -r ./requirements.txt

EXPOSE 6878/tcp
ENTRYPOINT ["/catatonit", "--"]