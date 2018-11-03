#
# Cookbook:: build_cookbook
# Recipe:: provision
#
# Copyright:: 2018, Trek Bicycle Corporation, All Rights Reserved.
include_recipe 'delivery-truck::provision'

vault_data = get_chef_vault_data

ENV.update(
  'TF_VAR_admin_user'          => vault_data['admin_user'],
  'TF_VAR_admin_password'      => vault_data['admin_password'],
  'TF_VAR_cookbook_name'       => workflow_change_project,
  'ARM_SUBSCRIPTION_ID'        => '9db13c96-62ad-4945-9579-74aeed296e48',
  'ARM_CLIENT_ID'              => vault_data['client_id'],
  'ARM_CLIENT_SECRET'          => vault_data['client_secret'],
  'ARM_TENANT_ID'              => vault_data['tenant_id']
)

execute 'create necessary acceptance chef environment' do
  command "knife environment create acceptance-trek-trek-bikes-#{workflow_change_project}-master -d 'The acceptance environment' -c #{automate_knife_rb}"
  not_if "knife environment list -c #{automate_knife_rb} | grep acceptance-trek-trek-bikes-#{workflow_change_project}-master"
  only_if { workflow_stage?('acceptance') }
end

%w(main.tf provider.tf rg.tf variables.tf vm_linux.tf vm_windows.tf).each do |terraform_template|
  template terraform_template do
    source "terraform/#{terraform_template}.erb"
    path "#{delivery_workspace_repo}/#{terraform_template}"
    variables('workflow_cookbook_name': workflow_change_project)
    sensitive true
  end
end

delivery_terraform 'build acceptance nodes' do
  plan_dir delivery_workspace_repo
  only_if { workflow_stage?('acceptance') }
  action [ :init, :plan, :apply, :show ]
end
