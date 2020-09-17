require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:car) { Car.fake }
  let(:bus) { Bus.fake }
  let(:truck) { Truck.fake }

  context 'when serializing a mixed collection' do
    it 'uses the correct serializer for each object' do
      vehicles = VehicleSerializer.new([car, bus], serializers: { Car: CarSerializer, Bus: BusSerializer }).to_hash
      car_hash, bus_hash = vehicles[:data]

      expect(car_hash[:type]).to eq(:car)
      expect(car_hash[:attributes]).to eq(model: car.model, year: car.year, purchased_at: car.purchased_at)

      expect(bus_hash[:type]).to eq(:bus)
      expect(bus_hash[:attributes]).to eq(model: bus.model, year: bus.year, passenger_count: bus.passenger_count)
    end

    context 'when there is no serializer given for the class' do
      it 'raises ArgumentError' do
        expect { VehicleSerializer.new([truck], serializers: { Car: CarSerializer, Bus: BusSerializer }).to_hash }
          .to raise_error(ArgumentError, 'no serializer defined for Truck')
      end
    end

    context 'when given an empty set of serializers' do
      it 'uses the serializer being called' do
        data = VehicleSerializer.new([truck], serializers: {}).to_hash[:data][0]
        expect(data[:type]).to eq(:vehicle)
        expect(data[:attributes]).to eq(model: truck.model, year: truck.year)
      end
    end
  end

  context 'when serializing an single object' do
    it 'uses the correct serializer' do
      data = VehicleSerializer.new(car, serializers: { Car: CarSerializer, Bus: BusSerializer }).to_hash[:data]

      expect(data[:type]).to eq(:car)
      expect(data[:attributes]).to eq(model: car.model, year: car.year, purchased_at: car.purchased_at)
    end

    context 'when there is no serializer given for the class' do
      it 'raises ArgumentError' do
        expect { VehicleSerializer.new(truck, serializers: { Car: CarSerializer, Bus: BusSerializer }).to_hash }
          .to raise_error(ArgumentError, 'no serializer defined for Truck')
      end
    end

    context 'when given an empty set of serializers' do
      it 'uses the serializer being called' do
        data = VehicleSerializer.new(truck, serializers: {}).to_hash[:data]
        expect(data[:type]).to eq(:vehicle)
        expect(data[:attributes]).to eq(model: truck.model, year: truck.year)
      end
    end
  end
end
