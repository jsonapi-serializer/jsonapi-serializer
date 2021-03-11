require 'spec_helper'

# Needed to subscribe to `active_support/notifications`
require 'concurrent'

RSpec.describe JSONAPI::Serializer do
  let(:serializer) do
    Instrumented::ActorSerializer.new(Actor.fake)
  end

  it do
    payload = event_name = nil
    notification_name =
      "#{::JSONAPI::Serializer::Instrumentation::NOTIFICATION_NAMESPACE}serializable_hash"

    ActiveSupport::Notifications.subscribe(
      notification_name
    ) do |ev_name, _s, _f, _i, ev_payload|
      event_name = ev_name
      payload = ev_payload
    end

    expect(serializer.serializable_hash).not_to be_nil

    expect(event_name).to eq('render.jsonapi-serializer.serializable_hash')
    expect(payload[:name]).to eq(serializer.class.name)
    expect(payload[:serializer]).to eq(serializer.class)
  end
end
