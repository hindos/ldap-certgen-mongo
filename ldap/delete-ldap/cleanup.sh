#!/bin/bash

echo "Deleting deployment -> ldap"
oc delete deployment ldap -n ldap

echo "Deleting service -> ldap"
oc delete service ldap-service -n ldap

echo "Deleting image stream -> custom-ldap"
oc delete image stream custom-ldap -n ldap

echo "Deleting namespace -> ldap"
oc delete namespace ldap
