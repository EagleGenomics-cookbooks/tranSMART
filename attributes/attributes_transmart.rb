# This needs running at compile time before we install build-essential
default['apt']['compile_time_update'] = true

# we need build essentials for ruby gems with c libraries to build themselves in compile time
default['build-essential']['compile_time'] = true

default['transmart']['unixNonSpecific'] = ['transmart-r', 'make', 'curl', 'git', 'groovy', 'wget', 'patch']

default['transmart']['unixDebian'] = ['openjdk-7-jdk', 'php5-cli', 'php5-json', 'postgresql-9.3', 'apache2', 'tomcat7', 'libtcnative-1', 'language-pack-en']

# 'postgresql93-server', 'postgresql93-contrib',
default['transmart']['unixRhel'] = ['postgresql93-server', 'java-1.7.0-openjdk-devel', 'php55-cli-minimal', 'httpd']

# Apache tomcat 7 version
default['transmart']['tomcatVersion'] = '7.0.59'

default['transmart']['installDirectory'] = '/usr/local'
# default['installDirectory'] = '/apps'

# default['transmartDirectory'] = default['installDirectory'] + '/transmart-data'

#############################################################################
#############################################################################
