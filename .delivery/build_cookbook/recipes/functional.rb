#
# Cookbook Name:: build_cookbook
# Recipe:: functional
#
# Copyright:: 2017, The Authors, All Rights Reserved.
include_recipe 'delivery-truck::functional'

ruby_block 'check_sumologic_collector' do
  block do
    response = JSON.parse(Chef::HTTP.new('https://api.us2.sumologic.com').get('/api/v1/collectors',{'AUTHORIZATION' => "Basic #{ Base64.strict_encode64("#{vault_data['sumologic_accessid']}:#{vault_data['sumologic_accesskey']}")}", 'Accept' => 'application/json', 'Content-Type' => 'application/json' }))

    found = false
    response['collectors'].each do |collector|
      if collector['name'] == 'azl-chef-deli' then
        if collector['alive'] then
          found = true
        end
      end
    end

    unless found then
      raise 'Sumologic collector is not working.'
    end
  end
end
