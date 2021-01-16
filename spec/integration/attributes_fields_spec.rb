require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:actor) do
    act = Actor.fake
    act.movies = [Movie.fake]
    act
  end
  let(:params) { {} }
  let(:serialized) do
    ActorSerializer.new(actor, params).serializable_hash.as_json
  end

  describe 'attributes' do
    it do
      expect(serialized['data']).to have_id(actor.uid)
      expect(serialized['data']).to have_type('actor')

      expect(serialized['data'])
        .to have_jsonapi_attributes('first_name', 'last_name', 'email').exactly
      expect(serialized['data']).to have_attribute('first_name')
        .with_value(actor.first_name)
      expect(serialized['data']).to have_attribute('last_name')
        .with_value(actor.last_name)
      expect(serialized['data']).to have_attribute('email')
        .with_value(actor.email)
    end

    context 'with nil identifier' do
      before { actor.uid = nil }

      it { expect(serialized['data']).to have_id(nil) }
    end

    context 'with `if` conditions' do
      let(:params) { { params: { conditionals_off: 'yes' } } }

      it do
        expect(serialized['data']).not_to have_attribute('email')
      end
    end

    context 'with include and fields' do
      let(:params) do
        {
          include: [:played_movies],
          fields: { movie: [:release_year], actor: [:first_name] }
        }
      end

      it do
        expect(serialized['data'])
          .to have_jsonapi_attributes(:first_name).exactly

        expect(serialized['included']).to include(
          have_type('movie')
          .and(have_id(actor.movies[0].id))
          .and(have_jsonapi_attributes('release_year').exactly)
        )
      end
    end

    context 'with an attribute filter using a method permitting a few attributs only' do
      let(:params) { { params: { filter_attributes: %i[last_name email] } } }

      let(:serialized) do
        MethodFilteredActorSerializer.new(actor, params).serializable_hash.as_json
      end

      it do
        expect(serialized['data'])
          .to have_jsonapi_attributes('last_name', 'email').exactly
      end
    end

    context 'with an attribute filter using a method permitting all' do
      let(:params) { { params: { filter_attributes: :all } } }

      let(:serialized) do
        MethodFilteredActorSerializer.new(actor, params).serializable_hash.as_json
      end

      it do
        expect(serialized['data'])
          .to have_jsonapi_attributes('first_name', 'last_name', 'email').exactly
      end
    end

    context 'with an attribute filter using a block' do
      let(:params) { { params: { filter_attributes: %i[last_name email] } } }

      let(:serialized) do
        CallableFilteredActorSerializer.new(actor, params).serializable_hash.as_json
      end

      it do
        expect(serialized['data'])
          .to have_jsonapi_attributes('last_name', 'email').exactly
      end
    end
  end
end
