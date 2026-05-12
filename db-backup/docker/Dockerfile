FROM mariadb:10.3

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    mariadb-backup \
    supervisor \
    bash \
    tar \
    gzip \
    coreutils \
    openssh-client \
    sshpass \
    lftp \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /backup /backup/meta /scripts /etc/supervisor/conf.d

COPY scripts/ /scripts/
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod 755 /scripts/*
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]