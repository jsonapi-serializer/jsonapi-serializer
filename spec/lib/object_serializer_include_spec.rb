require 'spec_helper'

describe FastJsonapi::ObjectSerializer do
  include_context 'movie class'

  def has_included_type?(hash, type)
    hash[:included].any? { |i| i[:type].to_sym == type }
  end

  describe '`include`' do
    it 'can defined as symbols' do
      hash = MovieSerializer.new(movie, include: [:actors, :advertising_campaign]).serializable_hash
      expect(has_included_type?(hash, :actor)).to eq true
      expect(has_included_type?(hash, :advertising_campaign)).to eq true
      expect(has_included_type?(hash, :agency)).to eq false
    end

    it 'can be defined as strings' do
      hash = MovieSerializer.new(movie, include: ['actors', 'advertising_campaign']).serializable_hash
      expect(has_included_type?(hash, :actor)).to eq true
      expect(has_included_type?(hash, :advertising_campaign)).to eq true
      expect(has_included_type?(hash, :agency)).to eq false
    end

    describe 'nested relationships' do

      it 'can be defined as dot notation' do
        hash = MovieSerializer.new(movie, include: ['actors', 'actors.agency', 'actors.agency.state']).serializable_hash
        expect(has_included_type?(hash, :actor)).to eq true
        expect(has_included_type?(hash, :agency)).to eq true
        expect(has_included_type?(hash, :state)).to eq true
      end

      it 'does not require the parent to be specified separately in dot notation' do
        hash = MovieSerializer.new(movie, include: ['actors.agency.state']).serializable_hash
        expect(has_included_type?(hash, :actor)).to eq true
        expect(has_included_type?(hash, :agency)).to eq true
        expect(has_included_type?(hash, :state)).to eq true
      end

      it 'can be specified as hashes' do
        hash = MovieSerializer.new(movie, include: { actors: { agency: :state } }).serializable_hash
        expect(has_included_type?(hash, :actor)).to eq true
        expect(has_included_type?(hash, :agency)).to eq true
        expect(has_included_type?(hash, :state)).to eq true
      end
    end

    it 'can include any combination of notation' do
      hash = MovieSerializer.new(movie, include: [{ actors: :agency }, :advertising_campaign, 'actors.agency.state' ]).serializable_hash
      expect(has_included_type?(hash, :actor)).to eq true
      expect(has_included_type?(hash, :agency)).to eq true
      expect(has_included_type?(hash, :state)).to eq true
      expect(has_included_type?(hash, :advertising_campaign)).to eq true
    end
  end

  describe 'validation' do
    it 'raises an exception if an included item is not a relationship on the object' do
      expect { MovieSerializer.new(movie, include: [:foo]).serializable_hash }.to raise_error(FastJsonapi::InvalidIncludeError)
      expect { MovieSerializer.new(movie, include: { actors: :foo }).serializable_hash }.to raise_error(FastJsonapi::InvalidIncludeError)
    end

    it 'properly validates dynamic (e.g. polymorphic) relationships' do
      expect { TheaterSerializer.new(theater, include: { snacks: :supplier }).serializable_hash }.to_not raise_error
      expect { TheaterSerializer.new(theater, include: { snacks: :foo }).serializable_hash }.to raise_error(FastJsonapi::InvalidIncludeError)
    end
  end
end
