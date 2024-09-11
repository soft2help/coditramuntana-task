def to_array(value)
  value.is_a?(Array) ? value : [value.to_s]
end
