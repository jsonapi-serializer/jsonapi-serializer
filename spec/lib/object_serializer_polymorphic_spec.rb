require 'spec_helper'

describe FastJsonapi::ObjectSerializer do
  class List
    attr_accessor :id, :name, :items
  end

  class ChecklistItem
    attr_accessor :id, :name

    # fake belongs_to :list
    attr_accessor :list_id
    def list
      []
    end
  end

  class Car
    attr_accessor :id, :model, :year

    # fake belongs_to :list
    attr_accessor :list_id
    def list
      []
    end
  end

  class ListSerializer
    include FastJsonapi::ObjectSerializer
    set_type :list
    attributes :name
    set_key_transform :dash
    has_many :items, polymorphic: true
  end

  class ChecklistItemSerializer
    include FastJsonapi::ObjectSerializer
    set_type :checklist_item
    attributes :name
    belongs_to :list
  end

  class CarSerializer
    include FastJsonapi::ObjectSerializer
    set_type :car
    attributes :model
    attributes :year
    belongs_to :list
  end

  let(:car) do
    car = Car.new
    car.id = 1
    car.model = 'Toyota Corolla'
    car.year = 1987
    car
  end

  let(:checklist_item) do
    checklist_item = ChecklistItem.new
    checklist_item.id = 2
    checklist_item.name = 'Do this action!'
    checklist_item
  end

  context 'when serializing id and type of polymorphic relationships' do
    it 'should return correct type when transform_method is specified' do
      list = List.new
      list.id = 1
      list.items = [checklist_item, car]
      list_hash = ListSerializer.new(list).to_hash
      record_type = list_hash[:data][:relationships][:items][:data][0][:type]
      expect(record_type).to eq 'checklist-item'.to_sym
      record_type = list_hash[:data][:relationships][:items][:data][1][:type]
      expect(record_type).to eq 'car'.to_sym
    end
  end

  context 'when serializing included polymorphic relationships' do
    it "should not raise" do
      list = List.new
      list.id = 1
      list.items = [checklist_item, car]
      expect(-> {ListSerializer.new(list, include: ["items.list"])}).not_to raise_error
    end
  end
end
