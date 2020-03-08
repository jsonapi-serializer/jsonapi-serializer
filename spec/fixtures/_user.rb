class User
  attr_accessor :uid, :first_name, :last_name, :email

  def self.fake(id = nil)
    faked = new
    faked.uid = id || SecureRandom.uuid
    faked.first_name = FFaker::Name.first_name
    faked.last_name = FFaker::Name.last_name
    faked.email = FFaker::Internet.email
    faked
  end
end

class NoSerializerUser < User
end

class UserSerializer
  include FastJsonapi::ObjectSerializer

  set_id :uid
  attributes :first_name, :last_name, :email

  meta do |obj|
    {
      email_length: obj.email.size
    }
  end
end
