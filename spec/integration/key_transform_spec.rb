require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:actor) { Actor.fake }
  let(:params) { {} }
  let(:serialized) do
    CamelCaseActorSerializer.new(actor, params).serializable_hash.as_json
  end

  describe 'camel case key tranformation' do
    it do
      expect(serialized['data']).to have_id(actor.uid)
      expect(serialized['data']).to have_type('UserActor')
      expect(serialized['data']).to have_attribute('FirstName')
      expect(serialized['data']).to have_relationship('PlayedMovies')
      expect(serialized['data']).to have_link('MovieUrl').with_value(nil)
    end
  end
end
