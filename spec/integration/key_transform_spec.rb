require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:actor) { Actor.fake }

  describe 'camel case key tranformation' do
    let(:serialized) do
      CamelCaseActorSerializer.new(actor).serializable_hash.as_json
    end

    it do
      expect(serialized['data']).to have_id(actor.uid)
      expect(serialized['data']).to have_type('UserActor')
      expect(serialized['data']).to have_attribute('FirstName')
      expect(serialized['data']).to have_relationship('PlayedMovies')
      expect(serialized['data']).to have_link('MovieUrl').with_value(nil)
    end
  end

  describe 'inherited class dasherized case key tranformation' do
    let(:serialized) do
      DasherizedActorSerializer.new(actor).serializable_hash.as_json
    end

    it do
      expect(serialized['data']).to have_id(actor.uid)
      expect(serialized['data']).to have_type('user-actor')
      expect(serialized['data']).to have_attribute('first-name')
      expect(serialized['data']).to have_relationship('played-movies')
      expect(serialized['data']).to have_link('movie-url').with_value(nil)
    end
  end
end
