#
# Cookbook:: cb_dvo_logging
# Recipe:: default
#
# Copyright (c) 2017 Exmples All Rights Reserved.

case node['os']
when 'linux'
  include_recipe 'cb_dvo_logging::linux'
when 'windows'
  include_recipe 'cb_dvo_logging::windows'
else
  raise 'Cannot determine platform in default recipe.'
end
