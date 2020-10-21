require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:user) { User.fake }
  let(:actor) { Actor.fake }
  let(:movie) { Movie.fake }
  let(:serialized) do
    JSONAPI::Serializer.serialize(
      [user, actor, movie]
    ).as_json
  end

  it do
    expect(serialized['data']).to include(
      have_type(:user).and(have_id(user.uid))
    ).and(
      include(have_type('actor').and(have_id(actor.uid)))
    ).and(
      include(have_type('movie').and(have_id(movie.id)))
    )
  end
end
