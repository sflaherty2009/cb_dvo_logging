#
# Cookbook:: build_cookbook
# Recipe:: tests_functional
#
# Copyright:: 2018, Exmple Corporation, All Rights Reserved.

vault_data = get_chef_vault_data

ruby_block 'load_sumologic_collectors' do
  block do
    response = JSON.parse(Chef::HTTP.new('https://api.us2.sumologic.com').get('/api/v1/collectors', 'AUTHORIZATION' => "Basic #{Base64.strict_encode64("#{vault_data['sumologic_accessid']}:#{vault_data['sumologic_accesskey']}")}", 'Accept' => 'application/json', 'Content-Type' => 'application/json'))
    node.run_state['logging_nodes'] = shell_out("knife search node 'chef_environment:acceptance-exmpl-exmpl-bikes-#{workflow_change_project}-master' --attribute name -c #{automate_knife_rb} | grep 'name:' | awk '{print $2}'").stdout.chomp.split(/\n/)
    node.run_state['sumo_collectors'] = []

    response['collectors'].each do |collector|
      node.run_state['sumo_collectors'] << collector['name'] if collector['alive']
    end
  end
end

ruby_block 'verify_sumologic_collectors' do
  block do
    found = false
    nodes_diff = node.run_state['logging_nodes'].dup

    node.run_state['sumo_collectors'].each do |collector|
      if (i = nodes_diff.index("#{collector}-cb_dvo_logging"))
        nodes_diff.delete_at(i)
      end
    end
    found = true if node.run_state['logging_nodes'].any? && nodes_diff.empty?

    node.run_state['error'] = 'Sumologic collector is not working.' unless found
  end
end

Chef.event_handler do
  on :run_completed do
    Chef::Log.warn(Chef.run_context.node.run_state['error']) if Chef.run_context.node.run_state['error']
    raise Chef.run_context.node.run_state['error'] if Chef.run_context.node.run_state['error']
  end
end
