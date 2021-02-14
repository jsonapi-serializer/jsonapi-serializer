require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:actor) { Actor.fake }
  let(:params) { {} }

  describe 'with errors' do
    it do
      expect do
        BadMovieSerializerActorSerializer.new(actor).serializable_hash
      end.to raise_error(JSONAPI::Serializer::NotFoundError)
    end

    it do
      expect do
        ActorSerializer.new(actor, include: ['bad_include']).serializable_hash
      end.to raise_error(JSONAPI::Serializer::IncludeError)
    end
  end
end
