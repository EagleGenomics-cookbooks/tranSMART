###############################################################################
# include_recipe 'build-essential::default'

log 'default started'

###############################################################################

magic_shell_environment 'TRANSMART_INSTALL_DIRECTORY' do
  value node['transmart']['installDirectory']
end

###############################################################################

log 'platform family ' + node['platform_family']

log 'platform version ' + node['platform_version']

case node['platform_family']
when 'debian'
  include_recipe 'tranSMART::debian'
when 'rhel'
  if node['platform_version'] == '6.5'
    include_recipe 'tranSMART::rhel65'
  else
    include_recipe 'tranSMART::rhel70'
  end
end

###############################################################################

log 'default finished!'

###############################################################################
###############################################################################
