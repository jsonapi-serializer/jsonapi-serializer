Debut = Struct.new(:id, :location)

class DebutSerializer
  include JSONAPI::Serializer

  attributes :location
end
