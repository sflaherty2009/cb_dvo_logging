#
# Cookbook:: cb_dvo_logging
# Recipe:: linux
#
## Copyright (c) 2017 Trek Bikes, Ray Crawford, All Rights Reserved.

# The following are created in other cookbooks/installs
# | user      | UID  | GID  |
#  -----------------------------------------
# | na        |  na  | 1104 | sumologic_collector group; created by install

# For local testing and such

if node['dvo']['cloud_service_provider']['name'] == 'local'
  admin_users = %w(rcrawford nlocke deasland sflaherty)
  developer_users = %w(developer)
  all_users = admin_users + developer_users
  admin = %w(local_admin)

  group 'trekdevs' do
    action :create
    append true
  end

  group 'azg-devops-admins' do
    action :create
    append true
  end

  (all_users + admin).each do |this_user|
    user this_user do
      action :create
      password '$6$TgsTcMcJ$M2BujOwmS.uaotvwuEq.xvGDjtWRO0mxD7tu.er5uZ7yG.7.r4hL.vkSSS5Y3CrjN21bqLs5qZxGtjZyfBPtQ1'
      if developer_users.include? this_user
        group 'trekdevs'
      elsif admin_users.include? this_user
        group 'azg-devops-admins'
      end
    end
  end

  %w(/premium /standard /opt).each do |this_directory|
    directory this_directory do
      owner 'root'
      group 'root'
      mode '0755'
      action :create
    end
  end

end

# Guard in case Sumologic has already been set up
# This is also provides a way to upgrade SumoLogic;
#  just delete the link and it should recreate it
#  & upgrade if one exists
# MDO 2017-12-02: added execution time guard on trekdevs group
#  and added logic to allow for execution time guard on /opt/sumologs
#  in case needed in the future

ruby_block 'Check for group run condition' do
  block do
    node.run_state['trekdevs_exists'] = !shell_out('getent group trekdevs').error?
  end
end

unless File.exist?('/opt/sumologs')
  developer_group = 'trekdevs'

  directory '/storage/sumologs' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs" }
    group developer_group
    user 'root'
    mode '02755'
    only_if { node.run_state['trekdevs_exists'] }
  end

  link '/opt/sumologs' do
    to lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs" }
    only_if { node.run_state['trekdevs_exists'] }
  end

  directories = %w(sumologs)

  if node['dvo_user']['use'] =~ /\bhybris\S*WebServer\b/
    directories << "#{directories[0]}/apache"
  end

  if node['dvo_user']['use'] =~ /\bhybris\b/
    directories << "#{directories[0]}/hybris"
  end

  if node['dvo_user']['use'] =~ /\bsolr\b/
    directory "#{directories[0]}/solr" do
      group developer_group
      user 'solr'
      mode '02755'
      only_if { node.run_state['trekdevs_exists'] }
    end
  end

  directories.each do |path|
    directory path do
      path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/#{path}" }
      group developer_group
      user 'root'
      mode '02755'
      only_if { node.run_state['trekdevs_exists'] }
    end
  end

  remote_file 'SumoLogic Collector' do
    source node['dvo_user']['sumologic']['url']
    path "#{Chef::Config[:file_cache_path]}/sumocollector.rpm"
    owner 'root'
    group 'root'
    mode '0600'
    only_if { node.run_state['trekdevs_exists'] }
  end

  rpm_package 'sumocollector' do
    source "#{Chef::Config[:file_cache_path]}/sumocollector.rpm"
    action :upgrade
    notifies :restart, 'service[collector]', :delayed
    only_if { node.run_state['trekdevs_exists'] }
  end
end

# This is not in 'unless' because we want to check for
#  template updates despite whether SumoLogic was just
#  installed or not.
ruby_block 'Check for dir run condition' do
  block do
    node.run_state['opt_sumologs_exists'] = ::File.exist?('/opt/sumologs')
  end
end

template '/opt/SumoCollector/config/user.properties' do
  source 'user.properties.erb'
  owner 'root'
  notifies :restart, 'service[collector]', :delayed
  only_if { node.run_state['opt_sumologs_exists'] }
end

template '/opt/SumoCollector/config/sources.json' do
  source 'sources.json.erb'
  owner 'root'
  notifies :restart, 'service[collector]', :delayed
  only_if { node.run_state['opt_sumologs_exists'] }
end

service 'collector' do
  action [:enable, :start]
  only_if { node.run_state['opt_sumologs_exists'] }
end
