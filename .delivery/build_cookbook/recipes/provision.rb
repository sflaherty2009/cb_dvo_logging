#
# Cookbook Name:: build_cookbook
# Recipe:: provision
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe 'delivery-truck::provision'

vault_data = get_chef_vault_data

ENV.update(
  'TF_VAR_admin_user'          => vault_data['admin_user'],
  'TF_VAR_admin_password'      => vault_data['admin_password'],
  'TF_VAR_client_id'           => vault_data['client_id'],
  'TF_VAR_client_secret'       => vault_data['client_secret'],
  'TF_VAR_tenant_id'           => vault_data['tenant_id'],
  'TF_VAR_cookbook_name'       => workflow_change_project,
)

execute 'create necessary acceptance chef environment' do
  command "knife environment create acceptance-trek-trek-bikes-#{workflow_change_project}-master -d 'The acceptance environment' -c #{automate_knife_rb} -VV"
  not_if "knife environment list -c #{automate_knife_rb} | grep acceptance-trek-trek-bikes-#{workflow_change_project}-master"
  only_if { workflow_stage?('acceptance') }
end

delivery_terraform 'build acceptance node' do
  plan_dir "#{delivery_workspace_repo}/.delivery/build_cookbook/files/default/terraform"
  only_if { workflow_stage?('acceptance') }
end
