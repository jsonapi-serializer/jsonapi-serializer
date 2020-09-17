class Truck < Vehicle
  attr_accessor :load

  def self.fake(id = nil)
    faked = new
    faked.id = id || SecureRandom.uuid
    faked.model = 'Ford F150'
    faked.year = 2000
    faked
  end
end
