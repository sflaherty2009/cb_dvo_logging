#
# Cookbook:: build_cookbook
# Recipe:: functional
#
# Copyright:: 2018, Trek Bicycle Corporation, All Rights Reserved.
include_recipe 'delivery-truck::functional'
include_recipe '::tests_functional' if workflow_stage?('acceptance')
#include_recipe 'cb_dvo_terraform::acceptance' if workflow_stage?('acceptance')
