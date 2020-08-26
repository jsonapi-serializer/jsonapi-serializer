require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:movie) do
    mov = Movie.fake
    mov.actors = rand(2..5).times.map { Actor.fake }
    mov.owner = User.fake
    poly_act = Actor.fake
    poly_act.movies = [Movie.fake]
    mov.polymorphics = [User.fake, poly_act]
    mov.actor_or_user = Actor.fake
    mov
  end
  let(:params) { {} }
  let(:serialized) do
    MovieSerializer.new(movie, params).serializable_hash.as_json
  end

  describe 'relationships' do
    it do
      actors_rel = movie.actors.map { |a| { 'id' => a.uid, 'type' => 'actor' } }

      expect(serialized['data'])
        .to have_relationship('actors').with_data(actors_rel)

      expect(serialized['data'])
        .to have_relationship('owner')
        .with_data('id' => movie.owner.uid, 'type' => 'user')

      expect(serialized['data'])
        .to have_relationship('creator')
        .with_data('id' => movie.owner.uid, 'type' => 'user')

      expect(serialized['data'])
        .to have_relationship('actors_and_users')
        .with_data(
          [
            { 'id' => movie.polymorphics[0].uid, 'type' => 'user' },
            { 'id' => movie.polymorphics[1].uid, 'type' => 'actor' }
          ]
        )

      expect(serialized['data'])
        .to have_relationship('dynamic_actors_and_users')
        .with_data(
          [
            { 'id' => movie.polymorphics[0].uid, 'type' => 'user' },
            { 'id' => movie.polymorphics[1].uid, 'type' => 'actor' }
          ]
        )

      expect(serialized['data'])
        .to have_relationship('auto_detected_actors_and_users')
        .with_data(
          [
            { 'id' => movie.polymorphics[0].uid, 'type' => 'user' },
            { 'id' => movie.polymorphics[1].uid, 'type' => 'actor' }
          ]
        )
    end

    describe 'has relationship meta' do
      it do
        expect(serialized['data']['relationships']['actors'])
          .to have_meta('count' => movie.actors.length)
      end
    end

    context 'with include' do
      let(:params) do
        { include: [:actors] }
      end

      it do
        movie.actors.each do |actor|
          expect(serialized['included']).to include(
            have_type('actor')
            .and(have_id(actor.uid))
            .and(have_relationship('played_movies')
            .with_data([{ 'id' => actor.movies[0].id, 'type' => 'movie' }]))
          )
        end
      end

      context 'with `if` conditions' do
        let(:params) do
          {
            include: ['actors'],
            params: { conditionals_off: 'yes' }
          }
        end

        it do
          movie.actors.each do |actor|
            expect(serialized['included']).not_to include(
              have_type('actor')
              .and(have_id(actor.uid))
              .and(have_relationship('played_movies'))
            )
          end
        end
      end

      context 'with has_many polymorphic' do
        let(:params) do
          { include: ['actors_and_users.played_movies'] }
        end

        it do
          expect(serialized['included']).to include(
            have_type('user').and(have_id(movie.polymorphics[0].uid))
          )

          expect(serialized['included']).to include(
            have_type('movie').and(have_id(movie.polymorphics[1].movies[0].id))
          )

          expect(serialized['included']).to include(
            have_type('actor')
            .and(have_id(movie.polymorphics[1].uid))
            .and(
              have_relationship('played_movies').with_data(
                [{
                  'id' => movie.polymorphics[1].movies[0].id,
                  'type' => 'movie'
                }]
              )
            )
          )
        end
      end

      context 'with belongs_to polymorphic' do
        let(:params) do
          { include: ['actor_or_user'] }
        end

        it do
          expect(serialized['included']).to include(
            have_type('actor').and(have_id(movie.actor_or_user.uid))
          )
        end
      end
    end
  end
end
