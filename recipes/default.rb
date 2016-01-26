###############################################################################
# include_recipe 'build-essential::default'

log 'default started'

log 'platform family ' + node['platform_family']

log 'platform version ' + node['platform_version']

###############################################################################

magic_shell_environment 'TRANSMART_INSTALL_DIRECTORY' do
  value node['transmart']['installDirectory']
end

###############################################################################

log 'Install supporting packages'

include_recipe 'apt'

node['transmart']['packages'].each do |pkg|
  package pkg do
    action :install
	:upgrade
  end
end

###############################################################################

log 'Get tranSMART from Git'

transmart_data = node['transmart']['installDirectory'] + '/transmart-data'

include_recipe 'git'

git node['transmart']['data'] do
  repository 'https://github.com/transmart/transmart-data.git'
  revision 'master'
  action :checkout
end

###############################################################################

case node['platform_family']
when 'debian'
  include_recipe 'tranSMART::debian'
when 'rhel'
  # if node['platform_version'] == '6.5'
  # include_recipe 'tranSMART::rhel65'
  # else
  # include_recipe 'tranSMART::rhel70'
  # end
end

###############################################################################

log 'default finished!'

###############################################################################
###############################################################################
