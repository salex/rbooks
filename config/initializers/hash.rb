# /config/initializers/hash.rb

class Hash
  def to_o
    JSON.parse to_json, object_class: OpenStruct
  end
end

require 'bigdecimal'

# A monkey patch to fix ofx:
class BigDecimal
  def self.new(*arguments)
    BigDecimal(*arguments)
  end
end
