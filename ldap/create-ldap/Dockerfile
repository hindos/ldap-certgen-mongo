FROM osixia/openldap:1.3.0

RUN mkdir -p /container/service/slapd/assets/config/bootstrap/ldif
COPY bootstrap.ldif /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif

RUN cat /container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif
