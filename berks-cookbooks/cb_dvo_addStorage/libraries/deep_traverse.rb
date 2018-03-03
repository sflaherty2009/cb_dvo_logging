# Extend the hash class with a method to traverse all key/value pairs
class Hash
  def deep_traverse
    stack = map { |k, v| [[k], v] }
    retobj = {}
    until stack.empty?
      key, value = stack.pop
      retobj[key] = value
      value.each { |k, v| stack.push [key.dup << k, v] } if value.is_a? Hash
    end
    retobj
  end
end
