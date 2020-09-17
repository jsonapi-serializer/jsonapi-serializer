class Comment
  attr_accessor :uid, :body

  def self.fake(id = nil)
    faked = new
    faked.uid = id || SecureRandom.uuid
    faked.body = FFaker::Lorem.paragraph

    faked
  end
end

class CommentSerializer
  include JSONAPI::Serializer

  set_id :uid
  attributes :body
end
