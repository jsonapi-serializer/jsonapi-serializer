RSpec.shared_context 'group class' do
  # Person, Group Classes and serializers
  before(:context) do
    # models
    class Person
      attr_accessor :id, :first_name, :last_name
    end

    class Group
      attr_accessor :id, :name, :groupees # Let's assume groupees can be Person or Group objects
    end

    # serializers
    class PersonSerializer
      include FastJsonapi::ObjectSerializer
      set_type :person
      attributes :first_name, :last_name
    end

    class GroupSerializer
      include FastJsonapi::ObjectSerializer
      set_type :group
      attributes :name
      has_many :groupees, polymorphic: true
    end
  end

  # Person and Group struct
  before(:context) do
    PersonStruct = Struct.new(
      :id, :first_name, :last_name
    )

    GroupStruct = Struct.new(
      :id, :name, :groupees, :groupee_ids
    )
  end

  after(:context) do
    classes_to_remove = %i[
      Person
      PersonSerializer
      Group
      GroupSerializer
      PersonStruct
      GroupStruct
    ]
    classes_to_remove.each do |klass_name|
      Object.send(:remove_const, klass_name) if Object.constants.include?(klass_name)
    end
  end

  let(:group) do
    group = Group.new
    group.id = 1
    group.name = 'Group 1'

    person = Person.new
    person.id = 1
    person.last_name = 'Last Name 1'
    person.first_name = 'First Name 1'

    child_group = Group.new
    child_group.id = 2
    child_group.name = 'Group 2'

    group.groupees = [person, child_group]
    group
  end
end
