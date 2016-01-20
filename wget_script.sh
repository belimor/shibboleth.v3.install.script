#!/bin/bash

wget http://shibboleth.net/downloads/identity-provider/3.2.0/shibboleth-identity-provider-3.2.0.tar.gz
wget http://download.eclipse.org/jetty/stable-9/dist/jetty-distribution-9.3.6.v20151106.tar.gz
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u71-b15/jdk-8u71-linux-x64.tar.gz
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce_policy/6/jce_policy-6.zip
unzip jce_policy-6.zip 
mv jce/local_policy.jar ./
mv jce/US_export_policy.jar ./
rm -r jce/
rm -r jce_policy-6.zip 

