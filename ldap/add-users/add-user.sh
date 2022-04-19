#!/bin/bash
echo "LDAP users to add:"
cat addUser.ldif

service_name="$(oc get svc ldap-service --no-headers -o custom-columns=POD:.metadata.name -n ldap)"
baseDomain="$(oc get dns cluster -o go-template --template='{{.spec.baseDomain}}' -n ldap)"
nodePort="$(oc get svc ldap-service -o jsonpath='{.spec.ports[?(@.port==389)].nodePort}' -n ldap)"

echo "Adding users to LDAP"
ldapadd -x -h "$service_name"."$baseDomain":"$nodePort" -W -D 'cn=admin,dc=ibm,dc=com' -f addUser.ldif
