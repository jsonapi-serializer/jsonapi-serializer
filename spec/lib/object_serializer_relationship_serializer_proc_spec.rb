require 'spec_helper'

describe FastJsonapi::ObjectSerializer do

  class Person
    attr_accessor :id, :name, :assets
  end

  class House
    attr_accessor :id, :address
  end

  class Car
    attr_accessor :id, :model, :year
  end

  class PersonSerializer
    include FastJsonapi::ObjectSerializer
    set_type :person
    attributes :name
    set_key_transform :dash

    has_many :assets, serializer: -> (object) do
      if object.is_a?(House)
        HouseSerializer
      elsif object.is_a?(Car)
        CarSerializer
      end
    end
  end

  class HouseSerializer
    include FastJsonapi::ObjectSerializer
    set_type :house
    attributes :address
    set_key_transform :dash
  end

  class CarSerializer
    include FastJsonapi::ObjectSerializer
    set_type :car
    attributes :model, :year
    set_key_transform :dash
  end


  let(:house) do
    house = House.new
    house.id = 123
    house.address = '1600 Pennsylvania Avenue'
    house
  end

  let(:car) do
    car = Car.new
    car.id = 456
    car.model = 'Toyota Corolla'
    car.year = 1987
    car
  end

  context 'when serializing a relationship with a serializer block' do
    it 'should output the correct JSON based on the proper serializer' do
      person = Person.new
      person.id = 1
      person.name = 'Bob'
      person.assets = [house, car]
      person_hash = PersonSerializer.new(person).to_hash

      relationships = person_hash[:data][:relationships]
      house_relationship = relationships[:assets][:data][0]
      expect(house_relationship[:type].to_s).to eq 'house'
      expect(house_relationship[:id].to_s).to eq house.id.to_s
      car_relationship = relationships[:assets][:data][1]
      expect(car_relationship[:type].to_s).to eq 'car'
      expect(car_relationship[:id].to_s).to eq car.id.to_s

      expect(person_hash[:data]).to_not have_key :included
    end

    it 'should output the correct included records' do
      person = Person.new
      person.id = 1
      person.name = 'Bob'
      person.assets = [house, car]
      person_hash = PersonSerializer.new(person, { include: [ :assets ] }).to_hash

      relationships = person_hash[:data][:relationships]
      house_relationship = relationships[:assets][:data][0]
      expect(house_relationship[:type].to_s).to eq 'house'
      expect(house_relationship[:id].to_s).to eq house.id.to_s
      car_relationship = relationships[:assets][:data][1]
      expect(car_relationship[:type].to_s).to eq 'car'
      expect(car_relationship[:id].to_s).to eq car.id.to_s

      included = person_hash[:included]
      house_included = included[0]
      expect(house_included[:type].to_s).to eq 'house'
      expect(house_included[:id].to_s).to eq house.id.to_s
      expect(house_included[:attributes][:address]).to eq house.address
      car_included = included[1]
      expect(car_included[:type].to_s).to eq 'car'
      expect(car_included[:id].to_s).to eq car.id.to_s
      expect(car_included[:attributes][:model]).to eq car.model
    end
  end
end
