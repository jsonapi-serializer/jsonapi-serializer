class Bus < Vehicle
  attr_accessor :passenger_count

  def self.fake(id = nil)
    faked = new
    faked.id = id || SecureRandom.uuid
    faked.model = 'Nova Bus LFS'
    faked.year = 2014
    faked.passenger_count = 60
    faked
  end
end

class BusSerializer < VehicleSerializer
  attribute :passenger_count
end
