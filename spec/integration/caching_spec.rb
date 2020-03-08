require 'spec_helper'

RSpec.describe FastJsonapi::ObjectSerializer do
  let(:actor) do
    faked = Actor.fake
    movie = Movie.fake
    movie.owner = User.fake
    movie.actors = [faked]
    faked.movies = [movie]
    faked
  end
  let(:cache_store) { Cached::ActorSerializer.cache_store_instance }

  describe 'with caching' do
    it do
      expect(cache_store.delete(actor, namespace: 'test')).to be(false)

      Cached::ActorSerializer.new(
        [actor, actor], include: ['played_movies', 'played_movies.owner']
      ).serializable_hash

      expect(cache_store.delete(actor, namespace: 'test')).to be(true)
      expect(cache_store.delete(actor.movies[0], namespace: 'test')).to be(true)
      expect(
        cache_store.delete(actor.movies[0].owner, namespace: 'test')
      ).to be(false)
    end
  end
end
