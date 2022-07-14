# /config/initializers/hash.rb

class Hash
  def to_o
    JSON.parse to_json, object_class: OpenStruct
  end
end

Hash.class_eval do
  def to_struct
    Struct.new(*keys.map(&:to_sym)).new(*values)
  end
end

require 'bigdecimal'

# A monkey patch to fix ofx:
class BigDecimal
  def self.new(*arguments)
    BigDecimal(*arguments)
  end
end

# Integer.class_eval do
#   def to_sym
#     to_s.to_sym
#   end
# end
