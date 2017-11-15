#
# Cookbook:: cb_dvo_addStorage
# Recipe:: default
#
# Copyright (c) 2017 Ray Crawford,
# Trek Bicycle Corporation, All Rights Reserved.
#

case node['os']
when 'linux'
  if Dir.exist?('/standard') || Dir.exist?('/premium')
    Chef::Log.info('###=>INFO: Not mounting drives; /standard or /premium already exist.')
  else
    case node['platform']
    when 'centos'
      case node['platform_version']
      when /^7\..*/
        Chef::Log.info("###=>INFO: Configuring drives for #{node['platform']} #{node['platform_version']}.")
        include_recipe 'cb_dvo_addStorage::linux'
      when /^6\..*/
        Chef::Log.info("###=>INFO: Configuring drives for #{node['platform']} #{node['platform_version']}.")
        include_recipe 'cb_dvo_addStorage::linux'
      else
        log "###=>FATAL: No support for #{node['platform']} #{node['platform_version']}" do
          level :fatal
        end
      end
    else
      log "###=>FATAL: No #{node['platform']} #{node['platform_version']} support" do
        level :fatal
      end
      raise "No #{node['platform_family']} support"
    end
  end
when 'windows'
  if Dir.exist?('P:') || Dir.exist?('S:')
    Chef::Log.info('###=>INFO: Not mounting drives; S: or P: already exist.')
  else
    case node['kernel']['name']
    when /Microsoft Windows Server 2012 R2.*/
      Chef::Log.info('###=>INFO: Setting up drives attached to a Windows 2012 R2 VM.')
      include_recipe 'cb_dvo_addStorage::windows2012r2'
    when /Microsoft Windows Server 2016 R2.*/
      Chef::Log.info('###=>INFO: Setting up drives attached to a Windows 2016 R2 VM.')
      include_recipe 'cb_dvo_addStorage::windows2012r2'
    else
      Chef::Log.fatal("###=>FATAL: Windows kernel #{node['kernel']['name']} unknown.")
      raise "Windows kernel #{node['kernel']['name']} unknown"
    end
  end
else
  raise "no #{node['platform_family']} support"
end
