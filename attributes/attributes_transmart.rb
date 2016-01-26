# This needs running at compile time before we install build-essential
default['apt']['compile_time_update'] = true

# we need build essentials for ruby gems with c libraries to build themselves in compile time
default['build-essential']['compile_time'] = true

default['transmart']['packages'] = %w(make curl git groovy wget patch)

case node['platform_family']
when 'debian'
  default['transmart']['packages'].push('openjdk-7-jdk', 'php5-cli', 'php5-json', 'postgresql-9.3', 'apache2', 'tomcat7', 'libtcnative-1', 'language-pack-en')
when 'rhel'
  # 'postgresql93-server', 'postgresql93-contrib',
  default['transmart']['packages'].push('postgresql93-server', 'java-1.7.0-openjdk-devel', 'php55-cli-minimal', 'httpd')
end

# Apache tomcat 7 version
default['transmart']['tomcatVersion'] = '7.0.59'

default['transmart']['installDirectory'] = '/usr/local'

default['transmart']['data'] = node['transmart']['installDirectory'] + '/transmart-data'

#############################################################################
#############################################################################
