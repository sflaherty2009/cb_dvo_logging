#
# Cookbook:: cb_dvo_logging
# Recipe:: linux
#
## Copyright (c) 2017 Trek Bikes, Ray Crawford, All Rights Reserved.

# For local testing and such

include_recipe 'cb_dvo_addStorage'

if node['dvo']['cloud_service_provider']['name'] == 'local'

  # Temporary to debug issue since databag breaks localAccounts in kitchen vagrant:
  if node['dvo_user']['ALM_service'].eql? 'solr'
    # Create solr user across all hosts
    group 'solr' do
      gid 8983
      action :create
    end

    user 'solr' do
      comment 'host solr account to enable export from solr containers'
      uid 8983
      gid 8983
      home '/home/solr'
    end
  end

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

# MDO 2018-03-22: Removed custom ruby converge time checks and allowed Chef idempotence to do its thing instead.
#                 This meant duplicating a bunch of guard logic, but it still seems more Chefy.

developer_group = 'trekdevs'

directory '/<storageSelection>/sumologs' do
  path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs" }
  group developer_group
  user 'root'
  mode '02755'
  only_if { !shell_out('getent group trekdevs').error? }
end

link '/opt/sumologs' do
  to lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs" }
  only_if { !shell_out('getent group trekdevs').error? }
end

# RAC 3/20/18
# REALLY bad coding, but we needed a different case for Solr than the other two.
# There are two recos.  First, create hybris and apache users on the VMs in cb_dvo_localAccounts
# and then use the user based upon the directory name...  in the case of Apache and Hybris, this
# is no big deal because both of those containers run as root and will have access to write
# to those paths.  Second, log files should ALWAYS be on standard storage...  this cookbook
# should be refactored to eliminate this complexity of storage selection (i.e., always
# put it on /standard/sumologs).  Tech Debt story DVO-2931 was opened to address this in
# a future sprint.
if node['dvo_user']['use'] =~ /\bhybris\S*WebServer\b/
  directory '/<storageSelection>/sumologs/apache' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs/apache" }
    group developer_group
    user 'root'
    mode '02755'
    only_if { !shell_out('getent group trekdevs').error? }
  end
end

if node['dvo_user']['use'] =~ /\bhybris\b/
  directory '/<storageSelection>/sumologs/hybris' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs/hybris" }
    group developer_group
    user 'root'
    mode '02755'
    only_if { !shell_out('getent group trekdevs').error? }
  end
end

if node['dvo_user']['use'] =~ /\bsolr\b/
  directory '/<storageSelection>/sumologs/solr' do
    path lazy { "/#{node['dvo_user']['sumologic']['storage_class']}/sumologs/solr" }
    group developer_group
    user 'solr'
    mode '02755'
    only_if { !shell_out('getent group trekdevs').error? }
  end
end

remote_file 'SumoLogic Collector' do
  source node['dvo_user']['sumologic']['url']
  path "#{Chef::Config[:file_cache_path]}/sumocollector.rpm"
  owner 'root'
  group 'root'
  mode '0600'
  only_if { !shell_out('getent group trekdevs').error? }
end

rpm_package 'sumocollector' do
  source "#{Chef::Config[:file_cache_path]}/sumocollector.rpm"
  action :upgrade
  notifies :restart, 'service[collector]', :delayed
  only_if { !shell_out('getent group trekdevs').error? }
end

template '/opt/SumoCollector/config/user.properties' do
  source 'user.properties.erb'
  owner 'root'
  notifies :restart, 'service[collector]', :delayed
  only_if { ::Dir.exist?('/opt/SumoCollector/config') }
end

template '/opt/SumoCollector/config/sources.json' do
  source 'sources.json.erb'
  owner 'root'
  notifies :restart, 'service[collector]', :delayed
  only_if { ::Dir.exist?('/opt/SumoCollector/config') }
end

service 'collector' do
  action [:enable]
  notifies :restart, 'service[collector]', :delayed
  only_if { ::Dir.exist?('/opt/SumoCollector/config') }
end
