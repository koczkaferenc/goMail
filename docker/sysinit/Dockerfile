FROM alpine:latest
RUN apk add --no-cache \
    certbot \
    curl \
    bind-tools \
    sqlite \
    gawk \
    bash 
WORKDIR /
COPY sysinit/sysinit.sh .
COPY sysinit/initdb.sql .
EXPOSE 80
ENTRYPOINT ["/sysinit.sh"]