require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:movie) do
    faked = Movie.fake
    faked.actors = [Actor.fake]
    faked
  end
  let(:params) { {} }
  let(:serialized) do
    MovieSerializer.new(movie, params).serializable_hash.as_json
  end

  describe 'links' do
    it do
      expect(serialized['data']).to have_link('self').with_value(movie.url)
      expect(serialized['data']['relationships']['actors'])
        .to have_link('actors_self').with_value(movie.url)
      expect(serialized['data']['relationships']['actors'])
        .to have_link('related').with_value(movie.url(movie))
    end

    context 'with included records' do
      let(:serialized) do
        ActorSerializer.new(movie.actors[0]).serializable_hash.as_json
      end

      it do
        expect(serialized['data']['relationships']['played_movies'])
          .to have_link('movie_url').with_value(movie.url)
      end
    end

    context 'with root link' do
      let(:params) do
        {
          links: { 'root_link' => FFaker::Internet.http_url }
        }
      end

      it do
        expect(serialized)
          .to have_link('root_link').with_value(params[:links]['root_link'])
      end
    end
  end
end
