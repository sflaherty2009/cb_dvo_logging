#
# Cookbook:: cb_dvo_logging
# Recipe:: windows
#
# Copyright (c) 2017 Trek Bicyles All Rights Reserved.

directory node['sumologic']['sumo_json_path'] do
  recursive true
end

sumo_source_local_windows_event_log 'windows' do
  source_json_directory node['sumologic']['sumo_json_path']
  category "www.trekbikes.com/#{node['hostname'].split('-')[1]}/windows"
  log_names ['security', 'application']
end

sumologic_collector 'C:\sumo' do
  collector_name node['hostname']
  clobber true
  sources "#{node['sumologic']['sumo_json_path']}/windows.json"
  sumo_access_id node['dvo_user']['sumologic']['accessID']
  sumo_access_key node['dvo_user']['sumologic']['accessKey']
  sensitive true
end
