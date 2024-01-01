#
# Cookbook:: cb_dvo_logging
# Recipe:: windows
#
# Copyright (c) 2017 ExmpleBicyles All Rights Reserved.

include_recipe 'chef-vault'

creds = chef_vault_item('infrastructure-vaults', 'sumologic')

directory node['sumologic']['sumo_json_path'] do
  recursive true
end

sumo_source_local_windows_event_log 'windows' do
  source_json_directory node['sumologic']['sumo_json_path']
  category "www.examples.com/#{node['hostname'].split('-')[1]}/windows"
  log_names %w(security,application)
end

ephemeral_collector = false
unless %w(development testing staging production delivery).include?(node.chef_environment)
  ephemeral_collector = true
end

sumologic_collector 'C:\sumo' do
  collector_name node['hostname']
  clobber true
  ephemeral ephemeral_collector
  sources "#{node['sumologic']['sumo_json_path']}/windows.json"
  sumo_access_id creds['accessid']
  sumo_access_key creds['accesskey']
  sensitive true
end
