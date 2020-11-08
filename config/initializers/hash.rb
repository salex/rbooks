# /config/initializers/hash.rb

class Hash
  def to_o
    JSON.parse to_json, object_class: OpenStruct
  end
end