#
# Cookbook:: build_cookbook
# Recipe:: tests_functional
#
# Copyright:: 2018, Trek Bicycle Corporation, All Rights Reserved.

vault_data = get_chef_vault_data

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
