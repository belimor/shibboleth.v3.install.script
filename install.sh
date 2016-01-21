#!/bin/bash -x

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/opt/install/Install_log.out 2>&1

echo ""
echo "=====> Installiing Oracle Java 8"
sleep 3
mkdir -p /usr/lib/jvm/java
ln -s /usr/lib/jvm/java /usr/lib/jvm/oracle_jdk8
/bin/tar -zxvf /opt/install/jdk-8u71-linux-x64.tar.gz -C /usr/lib/jvm/oracle_jdk8 --strip-components=1

echo "export J2SDKDIR=/usr/lib/jvm/oracle_jdk8" > /etc/profile.d/oraclejdk.sh
echo "export J2REDIR=/usr/lib/jvm/oracle_jdk8/jre" >> /etc/profile.d/oraclejdk.sh
echo "export PATH=$PATH:/usr/lib/jvm/oracle_jdk8/bin:/usr/lib/jvm/oracle_jdk8/db/bin:/usr/lib/jvm/oracle_jdk8/jre/bin" >> /etc/profile.d/oraclejdk.sh
echo "export JAVA_HOME=/usr/lib/jvm/oracle_jdk8" >> /etc/profile.d/oraclejdk.sh
echo "export DERBY_HOME=/usr/lib/jvm/oracle_jdk8/dbw" >> /etc/profile.d/oraclejdk.sh
source /etc/profile.d/oraclejdk.sh

cp -fv /opt/install/local_policy.jar /usr/lib/jvm/oracle_jdk8/jre/lib/security/local_policy.jar
cp -fv /opt/install/US_export_policy.jar /usr/lib/jvm/oracle_jdk8/jre/lib/security/US_export_policy.jar

echo ""
echo "=====> Installing Jetty 9"
sleep 3
mkdir /opt/jetty
/bin/tar -zxvf /opt/install/jetty-distribution-9.3.6.v20151106.tar.gz -C /opt/jetty --strip-components=1
useradd -r -s /bin/false jetty
mv /opt/jetty/demo-base /opt/jetty/jetty-base

echo "export JETTY_BASE=/opt/jetty/jetty-base" >> /etc/profile.d/oraclejdk.sh
echo "export JETTY_HOME=/opt/jetty" >> /etc/profile.d/oraclejdk.sh
source /etc/profile.d/oraclejdk.sh

echo ""
echo "=====> Installing Shibboleth 3"
sleep 3
/bin/tar -zxvf /opt/install/shibboleth-identity-provider-3.2.0.tar.gz -C /opt/install
mkdir /opt/shibboleth-idp
echo | /opt/install/shibboleth-identity-provider-3.2.0/bin/install.sh -Didp.src.dir=/opt/install/shibboleth-identity-provider-3.2.0 -Didp.target.dir=/opt/shibboleth-idp -Didp.keystore.password=passwd123 -Didp.sealer.password=passwd456 -Didp.host.name=shibboleth.ad.cybera.ca -Didp.scope=ad.cybera.ca -Dentityid=https://shibbboleth.ad.cybera.ca/idp/shibboleth

sed -i '0,/# JETTY_HOME/{s/# JETTY_HOME/JETTY_HOME=\/opt\/jetty/}' /opt/jetty/bin/jetty.sh
sed -i '0,/# JETTY_HOME/{s/# JETTY_BASE/JETTY_BASE=\/opt\/jetty\/jetty-base/}' /opt/jetty/bin/jetty.sh
sed -i 's/sleep 4/sleep 20/g' /opt/jetty/bin/jetty.sh


cat > /opt/jetty/jetty-base/start.d/idp.ini <<EOF
jetty.host=0.0.0.0
jetty.https.port=443
jetty.backchannel.port=9443
jetty.backchannel.keystore.path=/opt/shibboleth-idp/credentials/idp-backchannel.p12
jetty.backchannel.keystore.password=passwd123
jetty.browser.keystore.password=paswd456
jetty.backchannel.keystore.type=PKCS12
jetty.browser.keystore.type=PKCS12
jetty.context.path=/idp
jetty.war.path=/opt/shibboleth-idp/war/idp.war
jetty.jaas.path=conf/authn/jaas.config
jetty.nonhttps.host=0.0.0.0
jetty.nonhttps.port=80
EOF

chown -R jetty:jetty /opt/jetty
chown -R jetty:jetty /opt/shibboleth-idp

ln -s /opt/jetty/bin/jetty.sh /etc/init.d/jetty
ln -s /opt/jetty/bin/jetty.sh /etc/init.d/jetty

