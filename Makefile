.PHONY: all
all: dirs cert registry-users copy-files network

.PHONY: dirs
dirs:
	mkdir -p /opt/traefik/certs
	chmod 755 /opt/traefik
	chmod 750 /opt/traefik/certs
	mkdir -p /opt/gitea
	mkdir -p /opt/minio/config
	mkdir -p /opt/minio/data
	mkdir -p /opt/gitea/data
	mkdir -p /opt/gitea/postgres
	mkdir -p /opt/registry/data
	mkdir -p /opt/registry/auth
	mkdir -p /opt/coredns

.PHONY: cert
cert:
	openssl req -x509 -nodes -subj '/C=DK/ST=ACMEprov/L=ACMEloc/O=ACMEcompany/OU=ACMEorg/CN=*.example.com' -days 365 -newkey rsa:2048 -keyout /opt/traefik/certs/cert.key -out /opt/traefik/certs/cert.crt
	#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /opt/traefik/certs/cert.key -out /opt/traefik/certs/cert.crt
	chmod 644 /opt/traefik/certs/cert.crt
	chmod 600 /opt/traefik/certs/cert.key
	openssl x509 -in /opt/traefik/certs/cert.crt -text -noout

.PHONY: show-cert
show-cert:
	echo | openssl s_client -showcerts -servername minio.example.com -connect minio.example.com:443 2>/dev/null | openssl x509 -inform pem -noout -text

.PHONY: copy-files
copy-files:
	cp traefik/traefik.toml traefik/traefik.config.toml /opt/traefik/
	cp core-dns/example-Corefile /opt/coredns/Corefile
	cp core-dns/example-domain-zone.db /opt/coredns/

.PHONY: network
network:
	docker network create web

.PHONY: registry-users
registry-users:
	docker run --entrypoint htpasswd registry:2 -Bbn testuser testpassword > /opt/registry/auth/htpasswd

.PHONY: trust-cert
trust-cert:
	mkdir -p '/etc/docker/certs.d/registry.example.com'
	cp cert.crt '/etc/docker/certs.d/registry.example.com/ca.crt'
	cp cert.crt /usr/local/share/ca-certificates/registry.example.com.crt
	update-ca-certificates
