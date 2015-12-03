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

node['unixNonSpecific'].each do |pkg|
  package pkg do
    action :install
  end
end

node['unixDebian'].each do |pkg|
  package pkg do
    action :install
  end
end

###############################################################################

log 'Get tranSMART from Git'

transmart_data = ENV['PWD'] + '/transmart-data'

include_recipe 'git'

git transmart_data  do
  repository 'https://github.com/transmart/transmart-data.git'
  revision 'master'
  action :checkout
end

###############################################################################

log 'Install tranSMART'

# needed for tomcat to run SOLR on right port
cookbook_file 'configGroovy.patch' do
  source 'configGroovy.patch'
  path "#{Chef::Config[:file_cache_path]}/configGroovy.patch"
  action :create
end

cookbook_file 'solr.xml' do
  path '/etc/tomcat7/Catalina/localhost/solr.xml'
  source 'solr.xml'
  owner 'tomcat7'
  group 'tomcat7'
  mode '0755'
  action :create
end

bash 'Install_tranSMART' do
  user 'root'
  cwd transmart_data
  code <<-EOH
    env > enviromentVariablesStart
    export TAR_COMMAND=tar
    php env/vars-ubuntu.php > vars
    source vars
    sudo -u postgres bash -c "source vars; PGSQL_BIN=/usr/bin/ PGDATABASE=template1 make -C ddl/postgres/GLOBAL tablespaces"
    make postgres
    bash -c "source vars; TSUSER_HOME=/usr/share/tomcat7/ make -C config/ install"

    make -C solr solr_home
    chown -R tomcat7 solr/solr

    TS_DATA=`pwd`
    WEB_INF=/var/lib/tomcat7/webapps/solr/WEB-INF/
    service tomcat7 start &>> tomcat7.log
    cat /var/log/tomcat7/catalina.out >> tomcat7.log
    service tomcat7 stop &>> tomcat7.log

    sudo -u tomcat7 cp /home/ubuntu/transmart-data/solr/lib/ext/* /var/lib/tomcat7/webapps/solr/WEB-INF/lib/
    sudo -u tomcat7 mkdir /var/lib/tomcat7/webapps/solr/WEB-INF/classes
    sudo -u tomcat7 cp /home/ubuntu/transmart-data/solr/resources/log4j.properties /var/lib/tomcat7/webapps/solr/WEB-INF/classes

    echo 'USER=tomcat7' | sudo tee /etc/default/rserve
    service rserve start 

    #service tomcat7 stop &>> tomcat7.log
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

   env > enviromentVariablesEnd
  EOH
end

log 'debian Finished!'
###############################################################################
###############################################################################
