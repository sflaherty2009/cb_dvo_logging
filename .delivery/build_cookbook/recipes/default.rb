#
# Cookbook:: build_cookbook
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe 'delivery-truck::default'

node.default['terraform']['version'] = '0.11.7'
include_recipe 'terraform'
