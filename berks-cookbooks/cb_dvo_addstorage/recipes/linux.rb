#
# Cookbook:: cb_dvo_addStorage
# Recipe:: linux
#
# Copyright (c) 2017 Ray Crawford,
# Trek Bicycle Corporation, All Rights Reserved.
#

cookbook_file '/root/addDrives.bash' do
  source 'addDrives.bash'
  mode '0700'
  owner 'root'
  group 'root'
  notifies :run, 'execute[addDrives]', :immediately
end

execute 'addDrives' do
  command '/root/addDrives.bash'
end

ruby_block 'Set storage class attributes' do
  block do
    node.normal['dvo']['storage']['standard_available'] = Dir.exist?('/standard')
    node.normal['dvo']['storage']['premium_available'] = Dir.exist?('/premium')
  end
  not_if { node.normal['dvo']['storage'].attribute?('standard_available') || node.normal['dvo']['storage'].attribute?('premium_available') }
end
