#
# Cookbook:: cb_dvo_logging
# Recipe:: default
#
# Copyright (c) 2017 Trek Bikes, Ray Crawford, All Rights Reserved.

Chef::Log.warn "Mandatory attribute: cloud service provider name = #{node['cloud']['provider']}"
Chef::Log.warn "Mandatory attribute: ALM Environment = #{node['dvo_user']['ALM_environment']}"
Chef::Log.warn "Mandatory attribute: VM use = #{node['dvo_user']['use']}"

case node['os']
when 'linux'
  include_recipe 'cb_dvo_logging::linux'
when 'windows'
  include_recipe 'cb_dvo_logging::windows'
else
  raise 'Cannot determine platform in default recipe.'
end
