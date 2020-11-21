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

    it 'raises correct error on bad include for serializer with other relationships' do
      expect(ActorSerializer.relationships_to_serialize).to be_present

      expect { ActorSerializer.new(actor, include: ['bad_include']) }
        .to raise_error(
          JSONAPI::Serializer::UnsupportedIncludeError, /bad_include is not specified as a relationship/
        )
    end

    it 'raises correct error on bad include for serializer with no relationships at all' do
      expect(UserSerializer.relationships_to_serialize).to be_nil

      expect { UserSerializer.new(actor, include: ['bad_include']) }
        .to raise_error(
          JSONAPI::Serializer::UnsupportedIncludeError, /bad_include is not specified as a relationship/
        )
    end
  end
end
