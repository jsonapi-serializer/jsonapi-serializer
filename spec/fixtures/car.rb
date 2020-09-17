class Car < Vehicle
  attr_accessor :purchased_at

  def self.fake(id = nil)
    faked = new
    faked.id = id || SecureRandom.uuid
    faked.model = 'Toyota Corolla'
    faked.year = 1987
    faked.purchased_at = Time.new(2018, 1, 1)
    faked
  end
end

class CarSerializer < VehicleSerializer
  attribute :purchased_at
end
