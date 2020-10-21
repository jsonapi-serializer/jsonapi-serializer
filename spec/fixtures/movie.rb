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

  attributes :name
  attribute :release_year do |object|
    object.year
  end

  link :self, :url, if: ->(object, _params) { object.is_a?(Movie) }

  belongs_to :owner, serializer: UserSerializer

  belongs_to(
    :actor_or_user,
    serializers: {
      Actor => ActorSerializer,
      User => UserSerializer
    }
  )

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
    serializer: ->(object, _params) { UserSerializer if object.is_a?(User) }
  ) do |object|
    object.owner
  end
  has_many(
    :actors_and_users,
    serializers: {
      Actor => ActorSerializer,
      User => UserSerializer
    }
  ) do |obj|
    obj.polymorphics
  end

  has_many(:dynamic_actors_and_users) do |obj|
    obj.polymorphics
  end

  has_many(:auto_detected_actors_and_users) do |obj|
    obj.polymorphics
  end
end

module Cached
  class Movie < ::Movie; end

  class MovieSerializer < ::MovieSerializer
    set_type :cached_movie

    cache_options(
      store: ActorSerializer.cache_store_instance,
      namespace: 'test'
    )

    has_one(:creator, serializer: :cached_actor) do |obj|
      obj.owner
    end
  end
end
