.PHONY: all clean

all: ${ORG}-ca ${ORG}-mq-server ${ORG}-ace-server ${ORG}-client ${ORG}-datapower-server ${ORG}-jwt-generator

${ORG}-ca: ORGANISATION_UNIT = ${ORGANISATION_UNIT_CA}
${ORG}-ca: ${ORG}-ca.key ${ORG}-ca.crt ${ORG}-ca.jks

${ORG}-mq-server: ORGANISATION_UNIT = ${ORGANISATION_UNIT_MQ}
${ORG}-mq-server: ${ORG}-mq-server.key ${ORG}-mq-server.crt

${ORG}-ace-server: ORGANISATION_UNIT = ${ORGANISATION_UNIT_ACE}
${ORG}-ace-server: ${ORG}-ace-server.key ${ORG}-ace-server.crt ${ORG}-ace-server.jks ${ORG}-ace-server.kdb 

${ORG}-client: ORGANISATION_UNIT = ${ORGANISATION_UNIT_CLIENT}
${ORG}-client: ${ORG}-client.key ${ORG}-client.crt ${ORG}-client.jks

${ORG}-datapower-server: ORGANISATION_UNIT = ${ORGANISATION_UNIT_DATAPOWER}
${ORG}-datapower-server: ${ORG}-datapower-server.key ${ORG}-datapower-server.crt

${ORG}-jwt-generator: ORGANISATION_UNIT = JWT-GENERATOR
${ORG}-jwt-generator: ${ORG}-jwt-generator.key ${ORG}-jwt-generator.crt

clean:
	rm -f ${ORG}-mq-server.key ${ORG}-mq-server.crt
	rm -f ${ORG}-ace-server.key ${ORG}-ace-server.crt ${ORG}-ace-server.p12 ${ORG}-ace-server.jks ${ORG}-ace-server.kdb ${ORG}-ace-server.sth
	rm -f ${ORG}-client.key ${ORG}-client.crt ${ORG}-client.jks
	rm -f ${ORG}-datapower-server.key ${ORG}-datapower-server.crt
	rm -f ${ORG}-jwt-generator.key ${ORG}-jwt-generator.crt
	rm -f ${ORG}-ca.key ${ORG}-ca.crt ${ORG}-ca.jks ${ORG}-ca.srl

${ORG}-ca.key:
	openssl genrsa \
		-des3 \
		-passout pass:passw0rd \
		-out ${ORG}-ca.key 4096

${ORG}-ca.crt: ${ORG}-ca.key
	openssl req \
		-x509 \
		-new \
		-sha256 \
		-key ${ORG}-ca.key \
		-passin pass:passw0rd \
		-days 365 \
		-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANISATION}/OU=${ORGANISATION_UNIT}/CN=${COMMON_NAME}" \
		-out ${ORG}-ca.crt

${ORG}-ca.jks: ${ORG}-ca.crt
	rm -f ${ORG}-ca.jks
	keytool -keystore ${ORG}-ca.jks \
		-deststorepass passw0rd \
		-storetype jks \
		-importcert \
		-file ${ORG}-ca.crt \
		-alias ca-certificate \
		-noprompt

${ORG}-ace-server.kdb: ${ORG}-ca.crt ${ORG}-ace-server.p12
	rm -f ${ORG}-ace-server.kdb
	rm -f ${ORG}-ace-server.rdb
	rm -f ${ORG}-ace-server.sth
	rm -f ${ORG}-ace-server.crl
	
	runmqakm -keydb \
		-create -db ${ORG}-ace-server.kdb \
		-pw passw0rd \
		-type cms \
		-expire 365 \
		-stash

	runmqakm -cert \
		-add -label mqserver \
		-db ${ORG}-ace-server.kdb \
		-pw passw0rd \
		-trust enable \
		-file ${ORG}-ca.crt

	runmqckm -cert \
		-import -file ${ORG}-ace-server.p12 \
		-pw passw0rd \
		-type pkcs12 \
		-target ${ORG}-ace-server.kdb \
		-target_pw passw0rd \
		-target_type cms \
		-label ${ORG}-ace-server-pkcs12 \
		-new_label aceclient

	rm -f ${ORG}-ace-server.rdb
	rm -f ${ORG}-ace-server.crl


%.key:
	openssl genrsa -out $@ 2048

%.csr: %.key
	openssl req \
		-new \
		-sha256 \
		-key $< \
		-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANISATION}/OU=${ORGANISATION_UNIT}/CN=${COMMON_NAME}" \
		-sha256 \
		-out $@

%.crt: %.csr ${ORG}-ca.crt ${ORG}-ca.key
	openssl x509 \
		-req \
		-sha256 \
		-in $< \
		-extfile san.ext \
		-CA ${ORG}-ca.crt \
		-CAkey ${ORG}-ca.key \
		-CAcreateserial \
		-passin pass:passw0rd \
		-days 365 \
		-sha256 \
		-out $@

%.p12: %.crt %.key
	openssl pkcs12 -export \
		-in $(basename $@).crt \
		-inkey $(basename $@).key \
		-out $@ \
		-passout pass:passw0rd \
		-name $(basename $@)-pkcs12

%.jks: %.p12
	rm -f $@
	keytool -importkeystore \
		-deststorepass passw0rd \
		-destkeypass passw0rd \
		-destkeystore $@ \
		-srckeystore $(basename $@).p12 \
		-srcstoretype PKCS12 \
		-srcstorepass passw0rd \
		-alias $(basename $@)-pkcs12
