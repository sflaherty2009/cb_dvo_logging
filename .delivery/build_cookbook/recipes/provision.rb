#
# Cookbook:: build_cookbook
# Recipe:: provision
#
# Copyright:: 2018, Trek Bicycle Corporation, All Rights Reserved.
include_recipe 'delivery-truck::provision'
include_recipe 'cb_infra_acceptance' if workflow_stage?('acceptance')
