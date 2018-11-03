#
# Cookbook:: build_cookbook
# Recipe:: functional
#
# Copyright:: 2018, Trek Bicycle Corporation, All Rights Reserved.
include_recipe 'delivery-truck::functional'

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

ruby_block 'check_sumologic_collector' do
  block do
    response = JSON.parse(Chef::HTTP.new('https://api.us2.sumologic.com').get('/api/v1/collectors', 'AUTHORIZATION' => "Basic #{Base64.strict_encode64("#{vault_data['sumologic_accessid']}:#{vault_data['sumologic_accesskey']}")}", 'Accept' => 'application/json', 'Content-Type' => 'application/json'))

    found = false
    response['collectors'].each do |collector|
      found = true if collector['name'] == 'azl-chef-deli' && collector['alive']
    end

    raise 'Sumologic collector is not working.' unless found
  end
end

%w(main.tf provider.tf rg.tf variables.tf vm_linux.tf vm_windows.tf).each do |terraform_template|
  template terraform_template do
    source "terraform/#{terraform_template}.erb"
    path "#{delivery_workspace_repo}/#{terraform_template}"
    variables('workflow_cookbook_name': workflow_change_project)
    sensitive true
  end
end

delivery_terraform 'deprovision acceptance nodes' do
  plan_dir delivery_workspace_repo
  only_if { workflow_stage?('acceptance') }
  action [ :init, :destroy ]
end
