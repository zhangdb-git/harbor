FROM photon:3.0

RUN tdnf install -y sudo rpm >> /dev/null \
    && tdnf clean all \
    && groupadd -r -g 10000 scanner \
    && useradd --no-log-init -m -r -g 10000 -u 10000 scanner


COPY install_cert.sh /home/scanner/install_cert.sh
COPY entrypoint.sh /home/scanner/entrypoint.sh
COPY trivy /usr/local/bin/trivy
COPY scanner-trivy /home/scanner/bin/scanner-trivy


RUN chown -R scanner:scanner /etc/pki/tls/certs \
    && chown scanner:scanner /home/scanner/entrypoint.sh && chmod u+x /home/scanner/entrypoint.sh \
    && chown scanner:scanner /usr/local/bin/trivy && chmod u+x /usr/local/bin/trivy \
    && chown scanner:scanner /home/scanner/bin/scanner-trivy && chmod u+x /home/scanner/bin/scanner-trivy \
    && chown scanner:scanner /home/scanner/install_cert.sh && chmod u+x /home/scanner/install_cert.sh

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl --fail -s http://127.0.0.1:8080/probe/healthy || curl -k --fail -s https://127.0.0.1:8443/probe/healthy || exit 1

ENV TRIVY_VERSION=v0.6.0

USER scanner

ENTRYPOINT ["/home/scanner/entrypoint.sh"]
