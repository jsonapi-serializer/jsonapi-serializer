class Vehicle
  attr_accessor :id, :model, :year

  def type
    self.class.name.downcase
  end
end

class VehicleSerializer
  include JSONAPI::Serializer
  attributes :model, :year
end
