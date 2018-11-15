#
# Cookbook:: cb_dvo_logging
# Recipe:: linux
#
## Copyright (c) 2017 Trek Bicycles, All Rights Reserved.

# MDO 2018-03-22: Removed custom ruby converge time checks and allowed Chef idempotence to do its thing instead.
node.run_state['developer_group'] = 'trekdevs'

# Added font installation due to known issue with openjdk version 1.8.0_181 which will cause installation failure
package 'dejavu-serif-fonts'

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

# Run logrotate hourly
execute 'Switch logrotate from daily to hourly' do
  command 'mv /etc/cron.daily/logrotate /etc/cron.hourly/logrotate'
  only_if { ::File.exist?('/etc/cron.daily/logrotate') && !::File.exist?('/etc/cron.hourly/logrotate') }
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

template '/etc/logrotate.d/azure' do
  source 'etc/logrotate.d/azure.erb'
end

unless node['sumologic']['server_type'].nil?
  directory 'server type specific sumologs' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs/#{node['sumologic']['server_type']}" }
    group lazy { node.run_state['developer_group'] }
    user 'root'
    user node['authorization']['user_name'] if %w(freegeoip solr).include?(node['sumologic']['server_type'])
    mode '02755'
  end

  template "/etc/logrotate.d/#{node['sumologic']['server_type']}" do
    source "/etc/logrotate.d/#{node['sumologic']['server_type']}.erb"
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

ephemeral_collector = false
unless %w(development testing staging production delivery).include?(node.chef_environment)
  ephemeral_collector = true
end

sumologic_collector '/opt/SumoCollector/' do
  collector_name node['hostname']
  clobber true
  ephemeral ephemeral_collector
  sumo_access_id node['dvo_user']['sumologic']['accessID']
  sumo_access_key node['dvo_user']['sumologic']['accessKey']
  sources '/opt/SumoCollector/config/sources.json'
  sensitive true
  not_if { File.exist?('/opt/SumoCollector/collector') }
end
