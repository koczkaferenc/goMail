FROM alpine:latest
RUN apk add --no-cache \
    certbot \
    curl \
    bind-tools \
    sqlite \
    gawk \
    bash \
    openssl
WORKDIR /
COPY sysinit/sysinit.sh .
COPY sysinit/initdb.sql .
COPY sysinit/imapsync-mboxes.csv .
EXPOSE 80
ENTRYPOINT ["/sysinit.sh"]