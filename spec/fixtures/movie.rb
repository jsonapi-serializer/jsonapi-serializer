class Movie
  attr_accessor(
    :id,
    :name,
    :year,
    :actor_or_user,
    :actors,
    :actor_ids,
    :polymorphics,
    :owner,
    :owner_id
  )

  def self.fake(id = nil)
    faked = new
    faked.id = id || SecureRandom.uuid
    faked.name = FFaker::Movie.title
    faked.year = FFaker::Vehicle.year
    faked.actors = []
    faked.actor_ids = []
    faked.polymorphics = []
    faked
  end

  def cache_key
    "#{id}_cache_key"
  end

  def url(obj = nil)
    @url ||= FFaker::Internet.http_url
    return @url if obj.nil?

    "#{@url}?#{obj.hash}"
  end

  def owner=(ownr)
    @owner = ownr
    @owner_id = ownr.uid
  end

  def actors=(acts)
    @actors = acts
    @actor_ids = actors.map do |actor|
      actor.movies << self
      actor.uid
    end
  end
end

class MovieSerializer
  include JSONAPI::Serializer

  set_type :movie

  attribute :released_in_year, &:year
  attributes :name
  attribute :release_year do |object, _params|
    object.year
  end

  link :self, :url

  belongs_to :owner, serializer: UserSerializer

  belongs_to :actor_or_user,
             id_method_name: :uid,
             polymorphic: {
               Actor => :actor,
               User => :user
             }

  has_many(
    :actors,
    meta: proc { |record, _| { count: record.actors.length } },
    links: {
      actors_self: :url,
      related: ->(obj) { obj.url(obj) }
    }
  )
  has_one(
    :creator,
    object_method_name: :owner,
    id_method_name: :uid,
    serializer: ->(object, _params) { UserSerializer if object.is_a?(User) }
  )
  has_many(
    :actors_and_users,
    id_method_name: :uid,
    polymorphic: {
      Actor => :actor,
      User => :user
    }
  ) do |obj|
    obj.polymorphics
  end

  has_many(
    :dynamic_actors_and_users,
    id_method_name: :uid,
    polymorphic: true
  ) do |obj|
    obj.polymorphics
  end

  has_many(
    :auto_detected_actors_and_users,
    id_method_name: :uid
  ) do |obj|
    obj.polymorphics
  end
end

module Cached
  class MovieSerializer < ::MovieSerializer
    cache_options(
      store: ActorSerializer.cache_store_instance,
      namespace: 'test'
    )

    has_one(
      :creator,
      id_method_name: :uid,
      serializer: :actor,
      # TODO: Remove this undocumented option.
      #   Delegate the caching to the serializer exclusively.
      cached: false
    ) do |obj|
      obj.owner
    end
  end
end
