require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:actor) { Actor.fake }
  let(:params) { {} }

  describe 'with errors' do
    it do
      expect do
        BadMovieSerializerActorSerializer.new(
          actor, include: ['played_movies']
        )
      end.to raise_error(
        NameError, /cannot resolve a serializer class for 'bad'/
      )
    end

    it do
      expect { ActorSerializer.new(actor, include: ['bad_include']) }
        .to raise_error(
          JSONAPI::Serializer::UnsupportedIncludeError, /bad_include is not specified as a relationship/
        )
    end

    context 'when include is provided for a resource that does not have relationships' do
      let(:user) { User.fake }

      it do
        expect { UserSerializer.new(user, include: ['bad_include']) }
          .to raise_error(
            JSONAPI::Serializer::UnsupportedIncludeError, /bad_include is not specified as a relationship/
          )
      end
    end
  end
end
