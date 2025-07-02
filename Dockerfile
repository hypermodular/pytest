FROM coredns/coredns:latest

# Dodaj docker-gen binarkę
RUN apk add --no-cache curl bash
RUN curl -L https://github.com/jwilder/docker-gen/releases/download/v0.7.6/docker-gen-linux-amd64-0.7.6.tar.gz | tar -xz -C /usr/local/bin docker-gen

COPY Corefile /Corefile
COPY Corefile.tmpl /etc/docker-gen/templates/Corefile.tmpl

CMD bash -c "docker-gen -watch -only-published /etc/docker-gen/templates/Corefile.tmpl /hosts & coredns -conf /Corefile"
