FROM ubuntu:16.04

RUN apt-get update && apt install --no-install-recommends -y binutils build-essential pax-utils && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /development
WORKDIR /development

ENTRYPOINT ["make"]


