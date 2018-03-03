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
    when /Microsoft Windows Server 2016.*/
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

# Set storage available if not already
ruby_block 'Set storage class attributes' do
  block do
    case node['os']
    when 'linux'
      dir_check_standard = '/standard'
      dir_check_premium = '/premium'
    when 'windows'
      dir_check_standard = 'S'
      dir_check_premium = 'P'
    end

    node.normal['dvo']['storage']['standard_available'] = Dir.exist?(dir_check_standard)
    node.normal['dvo']['storage']['premium_available'] = Dir.exist?(dir_check_premium)
  end
  not_if { node.normal['dvo']['storage'].attribute?('standard_available') || node.normal['dvo']['storage'].attribute?('premium_available') }
end

# Set storage use for all appropriate attributes
ruby_block 'Check storage class availabilities' do
  block do
    # Library proc. Gets all unassigned storage classes and puts them in node.run-state['storage_class_attributes']
    # You might not want to look at it
    select_unassigned_storage_classes

    node.run_state['storage_class_attributes'].each do |_key, value|
      if value['storage_class'] != 'standard' && value['storage_class'] != 'premium'
        raise 'Invalid storage class requested.'
      end

      if value['storage_class'] == 'standard' && !node['dvo']['storage']['standard_available']
        raise 'Standard storage requested but not available. Ending chef-client run prematurely.'
      end
    end
  end
  not_if { node['dvo_user'].nil? }
  not_if { node['dvo'].nil? }
  not_if { storage_classes_set }
end

ruby_block 'Assign storage classes' do
  block do
    node.run_state['storage_class_attributes'].each do |key, value|
      if value['storage_class'] == 'premium' && !node['dvo']['storage']['premium_available']
        Chef::Log.warn('Premium storage requested but not available. Using standard instead.')
      end

      if value['storage_class'] == 'premium' && !node['dvo']['storage']['premium_available'] || value['storage_class'] == 'standard'
        key.inject(node.normal['dvo_user']) { |acc, elem| acc[elem] }['storage_class'] = 'standard'
        key.inject(node.normal['dvo_user']) { |acc, elem| acc[elem] }['windows_drive'] = 'S'
      else
        key.inject(node.normal['dvo_user']) { |acc, elem| acc[elem] }['storage_class'] = 'premium'
        key.inject(node.normal['dvo_user']) { |acc, elem| acc[elem] }['windows_drive'] = 'P'
      end
      key.inject(node.normal['dvo']['storage']) { |acc, elem| acc[elem] }['storage_class_set'] = true
    end
  end
  not_if { node.run_state['storage_class_attributes'].nil? }
end
