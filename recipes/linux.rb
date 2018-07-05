#
# Cookbook:: cb_dvo_logging
# Recipe:: linux
#
## Copyright (c) 2017 Trek Bicycles, All Rights Reserved.

# MDO 2018-03-22: Removed custom ruby converge time checks and allowed Chef idempotence to do its thing instead.

node.run_state['developer_group'] = 'trekdevs'

ruby_block 'Check developer group existence' do
  block do
    node.run_state['developer_group'] = 'root'
  end
  only_if { shell_out("getent group #{node.run_state['developer_group']}").error? }
end

ruby_block 'Assign developer group ID if missing from Etc' do
  block do
    node.run_state['developer_group'] = shell_out("getent group #{node.run_state['developer_group']} | awk -F: '{print $3}'").stdout.chomp.to_i
  end
  not_if do
    begin
      ::Etc.getgrnam(node.run_state['developer_group'])
    rescue ArgumentError
      nil
    end
  end
end

directory '/<storageSelection>/sumologs' do
  path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs" }
  group lazy { node.run_state['developer_group'] }
  user 'root'
  mode '02755'
end

link '/opt/sumologs' do
  to lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs" }
  not_if { ::Dir.exist?('/opt/sumologs') && !::File.symlink?('/opt/sumologs') }
end

if node['hostname'].include? 'web'
  directory '/<storageSelection>/sumologs/apache' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs/apache" }
    group lazy { node.run_state['developer_group'] }
    user 'root'
    mode '02755'
  end
end

if node['hostname'].include? 'hyb'
  directory '/<storageSelection>/sumologs/hybris' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs/hybris" }
    group lazy { node.run_state['developer_group'] }
    user 'root'
    mode '02755'
  end
end

if node['hostname'].include? 'slr'
  directory '/<storageSelection>/sumologs/solr' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs/solr" }
    group lazy { node.run_state['developer_group'] }
    user 'solr'
    mode '02755'
  end
end

if node['hostname'].include? 'geo'
  directory '/<storageSelection>/sumologs/freeGeoIP' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs/freeGeoIP" }
    group lazy { node.run_state['developer_group'] }
    user 'freegeoip'
    mode '02755'
  end
end

directory '/opt/SumoCollector/config' do
  recursive true
  action :create
end

template '/opt/SumoCollector/config/sources.json' do
  source 'sources.json.erb'
  owner 'root'
  variables(
    environment: node['hostname'].split('-')[1]
  )
end

sumologic_collector '/opt/SumoCollector/' do
  collector_name node['hostname']
  clobber true 
  sumo_access_id node['dvo_user']['sumologic']['accessID']
  sumo_access_key node['dvo_user']['sumologic']['accessKey']
  sources '/opt/SumoCollector/config/sources.json'
  sensitive true
end
