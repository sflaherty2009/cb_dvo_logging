def select_unassigned_storage_classes
  temp_dvo = {}
  if node['dvo'].key?('storage')
    temp_dvo = node['dvo']['storage'].deep_traverse { |path, value| p [path, value] }
  end

  temp_dvo_user = node['dvo_user'].deep_traverse { |path, value| p [path, value] }

  node.run_state['storage_class_attributes'] = {}

  temp_dvo_user.each do |key, value|
    if value.is_a?(Hash) && value.key?('storage_class') && (!temp_dvo.key?(key) || (temp_dvo[key].key?('storage_class_set') && !temp_dvo[key]['storage_class_set']))
      node.run_state['storage_class_attributes'][key] = value
    end
  end
end
