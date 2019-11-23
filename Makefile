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

.PHONY: cert
cert:
	openssl req -x509 -nodes -subj '/C=DK/ST=ACMEprov/L=ACMEloc/O=ACMEcompany/OU=ACMEorg/CN=minio.example.com' -days 365 -newkey rsa:2048 -keyout /opt/traefik/certs/cert.key -out /opt/traefik/certs/cert.crt
	#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /opt/traefik/certs/cert.key -out /opt/traefik/certs/cert.crt
	chmod 644 /opt/traefik/certs/cert.crt
	chmod 600 /opt/traefik/certs/cert.key
	openssl x509 -in /opt/traefik/certs/cert.crt -text -noout

.PHONY: show-cert
show-cert:
	echo | openssl s_client -showcerts -servername minio.example.com -connect minio.example.com:443 2>/dev/null | openssl x509 -inform pem -noout -text

.PHONY: copy-files
copy-files:
	cp traefik/traefik.toml /opt/traefik/

.PHONY: network
net:
	docker network create web
