require 'active_support/cache'
require 'jsonapi/serializer/instrumentation'

class Actor < User
  attr_accessor :movies, :movie_ids

  def self.fake(id = nil)
    faked = super(id)
    faked.movies = []
    faked.movie_ids = []
    faked
  end

  def cache_key
    "#{uid}_cache_key"
  end

  def movie_urls
    {
      movie_url: movies[0]&.url
    }
  end
end

class ActorSerializer < UserSerializer
  set_type :actor

  attribute :email, if: ->(_object, params) { params[:conditionals_off].nil? }

  has_many(
    :played_movies,
    serializer: :movie,
    links: :movie_urls,
    if: ->(_object, params) { params[:conditionals_off].nil? }
  ) do |object|
    object.movies
  end
end

class CamelCaseActorSerializer
  include JSONAPI::Serializer

  set_key_transform :camel

  set_id :uid
  set_type :user_actor
  attributes :first_name

  link :movie_url do |obj|
    obj.movie_urls.values[0]
  end

  has_many(
    :played_movies,
    serializer: :movie
  ) do |object|
    object.movies
  end
end

class BadMovieSerializerActorSerializer < ActorSerializer
  has_many :played_movies, serializer: :bad, object_method_name: :movies
end

module Cached
  class ActorSerializer < ::ActorSerializer
    # TODO: Fix this, the serializer gets cached on inherited classes...
    has_many :played_movies, serializer: :movie do |object|
      object.movies
    end

    cache_options(
      store: ActiveSupport::Cache::MemoryStore.new,
      namespace: 'test'
    )

    attribute :nest_batch do |object|
      BatchLoader.for(object).batch(replace_methods: false) do |objects, loader|
        objects.each do |obj|
          loader.call(obj, obj.uid)
        end
      end
    end
  end

  class WithParamNamespaceActorSerializer < ::ActorSerializer
    # TODO: Fix this, the serializer gets cached on inherited classes...
    has_many :played_movies, serializer: :movie do |object|
      object.movies
    end

    cache_options(
      store: ActiveSupport::Cache::MemoryStore.new,
      namespace: ->(record, params) { "#{params[:actor_gender]}" }
    )
  end
end

module Instrumented
  class ActorSerializer < ::ActorSerializer
    include ::JSONAPI::Serializer::Instrumentation
  end
end
