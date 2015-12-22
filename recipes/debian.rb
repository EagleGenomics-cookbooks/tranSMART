log 'debian started'

###############################################################################
log 'Set tranSMART repository'

apt_repository 'hyve_internal' do
  uri 'http://apt.thehyve.net/internal/'
  distribution 'trusty'
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key '3375DA21'
end

###############################################################################
log 'Fix debian bug by adding locale file'

cookbook_file 'locale' do
  path '/etc/default/locale'
  action :create
  owner 'root'
  group 'root'
  mode 0755
end

###############################################################################
log 'Install packages'

include_recipe 'apt'

node['transmart']['unixNonSpecific'].each do |pkg|
  package pkg do
    action :install
  end
end

node['transmart']['unixDebian'].each do |pkg|
  package pkg do
    action :install
  end
end

##########################################################
# here for use by serverspec

magic_shell_environment 'TRANSMART_INSTALL_DIRECTORY' do
  value node['transmart']['installDirectory']
end

###############################################################################

log 'Get tranSMART from Git'

transmart_data = node['transmart']['installDirectory'] + '/transmart-data'

include_recipe 'git'

git transmart_data do
  repository 'https://github.com/transmart/transmart-data.git'
  revision 'master'
  action :checkout
end

###############################################################################

log 'Install tranSMART'

bash 'Install_tranSMART' do
  user 'root'
  code <<-EOH
    sudo -u tomcat7 tee /etc/tomcat7/Catalina/localhost/solr.xml <<EOD
<?xml version="1.0" encoding="utf-8"?>
<Context docBase="#{transmart_data}/solr/webapps/solr.war" crossContext="true">
  <Environment name="solr/home" type="java.lang.String" value="#{transmart_data}/solr/solr" override="true"/>
</Context>
  EOH
end

bash 'Install_tranSMART' do
  user 'root'
  cwd transmart_data
  code <<-EOH
    env > environmentVariablesStart
    export TAR_COMMAND=tar
    php env/vars-ubuntu.php > vars
    source vars
    sudo -u postgres bash -c "source vars; PGSQL_BIN=/usr/bin/ PGDATABASE=template1 make -C ddl/postgres/GLOBAL tablespaces"
    make postgres
    bash -c "source vars; TSUSER_HOME=/usr/share/tomcat7/ make -C config/ install"

    make -C solr solr_home
    chown -R tomcat7 solr/solr

    # Not sure these 2 lines are needed anymore
    TS_DATA=`pwd`
    WEB_INF=/var/lib/tomcat7/webapps/solr/WEB-INF/

    service tomcat7 start &>> tomcat7.log
    cat /var/log/tomcat7/catalina.out >> tomcat7.log
    service tomcat7 stop &>> tomcat7.log

    sudo -u tomcat7 cp solr/lib/ext/* /var/lib/tomcat7/webapps/solr/WEB-INF/lib/
    sudo -u tomcat7 mkdir /var/lib/tomcat7/webapps/solr/WEB-INF/classes
    sudo -u tomcat7 cp solr/resources/log4j.properties /var/lib/tomcat7/webapps/solr/WEB-INF/classes

    echo 'USER=tomcat7' | sudo tee /etc/default/rserve
    service rserve start

    echo 'JAVA_OPTS="-Xmx4096M -XX:MaxPermSize=1024M"' | sudo tee /usr/share/tomcat7/bin/setenv.sh
    wget -P /var/lib/tomcat7/webapps/ https://ci.transmartfoundation.org/browse/DEPLOY-TRAPP/latestSuccessful/artifact/shared/transmart.war/transmart.war
    mkdir -p /usr/share/tomcat7/.grails
    chmod -R g+w /usr/share/tomcat7/.grails
    chgrp -R tomcat7 /usr/share/tomcat7/.grails
    service tomcat7 start &>> tomcat7.log

    make -C env/ data-integration
    make -C env/ update_etl

    make -C samples/postgres load_clinical_GSE8581
    make -C samples/postgres load_ref_annotation_GSE8581
    make -C samples/postgres load_expression_GSE8581

    env > environmentVariablesEnd
  EOH
end

log 'debian Finished!'
###############################################################################
###############################################################################
