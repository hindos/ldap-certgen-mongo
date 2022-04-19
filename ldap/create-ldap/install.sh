#!/bin/bash
echo "CREATING LDAP NAMESPACE"
oc create namespace ldap

echo "CREATING LDAP SERVICE ACCOUNTS AND PERMISSIONS"
oc create serviceaccount ldapaccount -n ldap
oc adm policy add-scc-to-user privileged system:serviceaccount:ldap:ldapaccount
oc adm policy add-scc-to-user anyuid system:serviceaccount:ldap:ldapaccount

echo "CREATING LDAP IMAGE STREAM"
oc create -f ldap-image-stream.yaml -n ldap

echo "Building image locally"
image_registry_route="$(oc get routes -n openshift-image-registry -o custom-columns=:.spec.host --no-headers)"
docker login "$image_registry_route" -u oc -p "$(oc whoami -t)"
docker build -t "$image_registry_route"/ldap/custom-ldap:2.0 .
docker push "$image_registry_route"/ldap/custom-ldap:2.0

echo "DEPLOY LDAP SERVER"
oc create -f ldap-deployment.yaml -n ldap

echo "DEPLOY LDAP SERVICE"
oc create -f ldap-service.yaml -n ldap

echo "LDAP SERVICE SHOULD BE AVAILABLE ON ldap-service.ldap PORT 389 and 636"

echo "Connection credentials"

service_name="$(oc get svc ldap-service --no-headers -o custom-columns=POD:.metadata.name -n ldap)"
baseDomain="$(oc get dns cluster -o go-template --template='{{.spec.baseDomain}}' -n ldap)"
nodePort="$(oc get svc ldap-service -o jsonpath='{.spec.ports[?(@.port==389)].nodePort}' -n ldap)"

echo "$service_name"."$baseDomain":"$nodePort"

echo bindDn "cn=admin,dc=ibm,dc=com"
echo password "admin"

echo "To list all ldap users"
echo "ldapsearch -x -h $service_name.$baseDomain:$nodePort -b dc=ibm,dc=com -D 'cn=admin,dc=ibm,dc=com' -w admin"
#  Base Domain