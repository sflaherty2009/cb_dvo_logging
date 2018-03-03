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
