log 'rhel 7.0 started'

###############################################################################
log 'Set tranSMART repository and add postgres RPM'

execute 'yum install -y http://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/pgdg-redhat93-9.3-1.noarch.rpm' do
  returns [0, 1]
end

cookbook_file 'thehyve_internal.repo' do
  path '/etc/yum.repos.d/thehyve_internal.repo'
  action :create
  owner 'root'
  group 'root'
  mode 0755
end

###############################################################################
log 'Install packages'

node['unixRhel'].each do |pkg|
  package pkg do
    action :install
  end
end

node['unixNonSpecific'].each do |pkg|
  package pkg do
    action :install
  end
end

###############################################################################
log 'Configure Postgres'

execute '/usr/pgsql-9.3/bin/postgresql93-setup initdb' do
end

cookbook_file 'pg_hba.conf_trusted' do
  path '/var/lib/pgsql/9.3/data/pg_hba.conf'
  action :create
  owner 'postgres'
  group 'postgres'
  mode 0600
end

###############################################################################
log 'Install and configure Tomcat 7'

bash 'Install_tomcat7' do
  user 'root'
  cwd '/usr/share/'
  code <<-EOH
    wget -O apache-tomcat-7.tar.gz http://archive.apache.org/dist/tomcat/tomcat-7/v#{node['tomcatVersion']}/bin/apache-tomcat-#{node['tomcatVersion']}.tar.gz
    tar xzf apache-tomcat-7.tar.gz
    mv apache-tomcat-#{node['tomcatVersion']} apache-tomcat-7
    groupadd tomcat7
    useradd -g tomcat7 -d /usr/share/apache-tomcat-7/tomcat tomcat7
    chown -Rf tomcat7.tomcat7 /usr/share/apache-tomcat-7/
  EOH
end

# copy file to ec2-user to be later copied to correct location once it would not be overwritten.
cookbook_file 'Config.groovy' do
  path "#{Chef::Config[:file_cache_path]}/Config.groovy"
  action :create
  owner 'tomcat7'
  group 'tomcat7'
  mode 0644
end

cookbook_file 'tomcat7' do
  path '/etc/init.d/tomcat7'
  action :create
  owner 'tomcat7'
  group 'tomcat7'
  mode 0755
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

cookbook_file 'vars' do
  path '/home/ec2-user/transmart-data/vars'
  action :create
  owner 'root'
  group 'root'
  mode 0755
end

###############################################################################
log 'Install tranSMART'

# needed for tomcat to run SOLR on right port
cookbook_file 'configGroovy.patch' do
  path "#{Chef::Config[:file_cache_path]}/configGroovy.patch"
  action :create
end

bash 'Install_tranSMART' do
  user 'root'
  cwd transmart_data
  code <<-EOH
    apachectl start
    env > enviromentVariablesStart
    chgrp -R postgres /home/ec2-user
    chmod g+rx /home/ec2-user
    export TAR_COMMAND=tar
    source vars

    systemctl enable postgresql-9.3
    systemctl start postgresql-9.3
    sudo -u postgres bash -c "source vars; PGSQL_BIN=/usr/bin/ PGDATABASE=template1 make -C ddl/postgres/GLOBAL tablespaces"
    make postgres
    bash -c "source vars; TSUSER_HOME=/usr/share/apache-tomcat-7/tomcat/ make -C config/ install"
    chown -Rf tomcat7.tomcat7 /usr/share/apache-tomcat-7/
    make -C solr/ start &
    echo 'USER=tomcat7' | sudo tee /etc/default/rserve
    bash -c 'echo "nohup /opt/R/bin/R  CMD Rserve --quiet --vanilla --RS-conf /etc/Rserve.conf&" > /tmp/rserve.sh' && chmod a+rx /tmp/rserve.sh
    runuser -l tomcat7 /tmp/rserve.sh

    service tomcat7 stop
    echo 'JAVA_OPTS="-Xmx4096M -XX:MaxPermSize=1024M"' | sudo tee /usr/share/apache-tomcat-7/bin/setenv.sh
    wget -P /usr/share/apache-tomcat-7/webapps/ https://ci.transmartfoundation.org/browse/DEPLOY-TRAPP/latestSuccessful/artifact/shared/transmart.war/transmart.war
    patch -b -N /usr/share/apache-tomcat-7/tomcat/.grails/transmartConfig/Config.groovy #{Chef::Config[:file_cache_path]}/configGroovy.patch
    chown tomcat7 /usr/share/apache-tomcat-7/tomcat/.grails/transmartConfig/Config.groovy
    service tomcat7 start

    make -C env/ data-integration
    make -C env/ update_etl
    env > enviromentVariablesEnd

    make -C samples/postgres load_clinical_GSE8581
    make -C samples/postgres load_ref_annotation_GSE8581
  EOH
end

log 'rhel Finished!'
###############################################################################
###############################################################################
