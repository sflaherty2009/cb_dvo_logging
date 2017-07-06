#
# Cookbook:: cb_dvo_logging
# Recipe:: linux
#
## Copyright (c) 2017 Trek Bikes, Ray Crawford, All Rights Reserved.

# For local testing and such

if node['dvo']['cloud_service_provider']['name'] == 'local'
  admin_users = %w(rcrawford nlocke adexter)
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

  # These acrobatics are not necessary to set the group which is all we need.
  # admin_group = 'azg-devops-admins'
  # developer_group = 'trekdevs'

  # else

  # admin_group = 'trekweb\\azg-devops-admins'
  # developer_group = 'trekdevs'

end

developer_group = 'trekdevs'

directories = %w(/opt /opt/sumologs /mnt /mnt/resource /mnt/resource/sumologs)

if node['dvo_user']['use'] =~ /\bhybris\S*WebServer\b/
  directories << '/mnt/resource/sumologs/apache'
end

if node['dvo_user']['use'] =~ /\bhybris\b/
  directories << '/mnt/resource/sumologs/hybris'
end

directories.each do |path|
  directory path do
    group developer_group
    user 'root'
    mode '02755'
  end
end

%w(apache hybris).each do |directory|
  if lazy { File.directory?('/mnt/resource/sumologs/' + directory) } # rubocop:disable Style/Next
    link '/opt/sumologs/' + directory do
      to '/mnt/resource/sumologs/' + directory
      link_type :symbolic
    end
  end
end

remote_file "SumoLogic Collector Version #{node['sumologic']['version']}" do
  source node['sumologic']['url']
  path "#{Chef::Config[:file_cache_path]}/sumocollector.rpm"
  owner 'root'
  group 'root'
  mode '0600'
  checksum node['sumologic']['checksum']
  action :create
end

rpm_package 'sumocollector' do
  source "#{Chef::Config[:file_cache_path]}/sumocollector.rpm"
  action :upgrade
end

service 'collector' do
  action [:enable, :restart]
end

template '/opt/SumoCollector/config/user.properties' do
  source 'user.properties.erb'
  owner 'root'
  notifies :restart, 'service[collector]', :immediately
end

template '/opt/SumoCollector/config/sources.json' do
  source 'sources.json.erb'
  owner 'root'
  notifies :restart, 'service[collector]', :immediately
end
