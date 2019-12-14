RSpec.shared_examples 'returning correct relationship hash' do |id_method_name, record_type|
  it 'returns correct relationship hash' do
    expect(relationship).to be_instance_of(FastJsonapi::Relationship)
    # expect(relationship.keys).to all(be_instance_of(Symbol))
    expect(relationship.static_serializer).to be relationship_serializer
    expect(relationship.id_method_name).to be id_method_name
    expect(relationship.static_record_type).to be record_type
  end
end

RSpec.shared_examples 'returning key transformed hash' do |relationship_name, resource_type, release_year|
  it 'returns correctly transformed hash' do
    expect(hash[:data][0][:attributes]).to have_key(release_year)
    expect(hash[:data][0][:relationships]).to have_key(relationship_name)
    expect(hash[:data][0][:relationships][relationship_name][:data][:type]).to eq(resource_type)
    expect(hash[:included][0][:type]).to eq(resource_type)
  end
end
