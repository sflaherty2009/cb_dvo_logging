def storage_classes_set
  val = true
  temp_dvo = {}
  if node['dvo'].key?('storage')
    temp_dvo = node['dvo']['storage'].deep_traverse { |path, value| p [path, value] }
  end

  node['dvo_user'].deep_traverse { |path, value| p [path, value] }.each do |key, value|
    if value.is_a?(Hash) && value.key?('storage_class') && (!temp_dvo.key?(key) || (temp_dvo[key].key?('storage_class_set') && !temp_dvo[key]['storage_class_set']))
      val = false
    end
  end
  val
end
