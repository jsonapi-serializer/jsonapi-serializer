require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:actor) do
    faked = Cached::Actor.fake
    movie = Cached::Movie.fake
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
        [actor, actor],
        include: ['played_movies', 'played_movies.owner']
      ).serializable_hash

      expect(cache_store.delete(actor, namespace: 'test')).to be(true)
      expect(
        cache_store.delete(actor.movies[0], namespace: 'test')
      ).to be(true)
      expect(
        cache_store.delete(actor.movies[0].owner, namespace: 'test')
      ).to be(false)
    end

    context 'without relationships' do
      let(:user) { User.fake }

      let(:serialized) do
        Cached::UserSerializer.new(user).serializable_hash.as_json
      end

      it do
        expect(serialized['data']).not_to have_key('relationships')
      end
    end
  end

  describe 'with caching and different fieldsets' do
    context 'when fieldset is provided' do
      it 'includes the fieldset in the namespace' do
        expect(cache_store.delete(actor, namespace: 'test')).to be(false)

        Cached::ActorSerializer.new(
          [actor], fields: { cached_actor: %i[first_name] }
        ).serializable_hash

        # Expect cached keys to match the passed fieldset
        cached_actor = cache_store.read(
          actor, namespace: 'test-fieldset:first_name'
        )

        expect(cached_actor[:attributes].keys).to eq(%i[first_name])

        Cached::ActorSerializer.new([actor]).serializable_hash

        # Expect cached keys to match all valid actor fields (no fieldset)
        cached_actor = cache_store.read(actor, namespace: 'test')

        expect(cached_actor[:attributes].keys)
          .to eq(%i[first_name last_name email])

        expect(
          cache_store.delete(actor, namespace: 'test-fieldset:first_name')
        ).to be(true)
      end
    end

    context 'when long fieldset is provided' do
      let(:actor_keys) do
        %i[first_name last_name more_fields yet_more_fields so_very_many_fields]
      end
      let(:digest_key) { Digest::SHA1.hexdigest(actor_keys.join('_')) }

      it 'includes the hashed fieldset in the namespace' do
        Cached::ActorSerializer.new(
          [actor], fields: { cached_actor: actor_keys }
        ).serializable_hash

        cached_actor = cache_store.read(
          actor, namespace: "test-fieldset:#{digest_key}"
        )

        expect(cached_actor[:attributes].keys).to eq(%i[first_name last_name])
      end
    end
  end
end
