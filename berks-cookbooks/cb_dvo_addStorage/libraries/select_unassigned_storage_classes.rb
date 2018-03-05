def select_unassigned_storage_class_attributes(dvo, dvo_user)
  temp_dvo = {}
  if dvo.key?('storage')
    temp_dvo = deep_traverse(dvo['storage']) { |path, value| p [path, value] }
  end

  temp_dvo_user = deep_traverse(dvo_user) { |path, value| p [path, value] }

  storage_class_attributes = {}

  temp_dvo_user.each do |key, value|
    key_last = key.last
    key_rest = key[0...-1]
    if key_last == 'storage_class'
      if key != []
        if !temp_dvo.key?(key_rest) || (temp_dvo[key_rest].key?('storage_class_set') && !temp_dvo[key_rest]['storage_class_set'])
          storage_class_attributes[key] = value
        end
      elsif !temp_dvo.key?(['storage_class_set']) || !temp_dvo[['storage_class_set']]
        storage_class_attributes[key] = value
      end
    end
  end
  storage_class_attributes
end
