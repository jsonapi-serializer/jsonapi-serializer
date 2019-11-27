require 'spec_helper'

describe FastJsonapi::ObjectSerializer do
  class Lead
    attr_accessor :id, :provider_lead_ids

    def provider_leads
      provider_lead_ids.map.with_index do |id, i|
        x = ProviderLead.new
        x.id = id
        x.lead_id = self.id
        if i.odd?
          x.providable_type = "Agent"
          x.providable_id = 456
        else
          x.providable_type = "Pilot"
          x.providable_id = 123
        end
        x
      end
    end
  end

  class ProviderLead
    attr_accessor :id, :lead_id, :providable_type, :providable_id

    def providable
      x = providable_type.constantize.new
      x.id = providable_id
      x
    end
  end

  class Pilot
    attr_accessor :id
  end

  class Agent
    attr_accessor :id
  end

  class LeadSerializer
    include FastJsonapi::ObjectSerializer
    has_many :provider_leads
    attributes :id
  end

  class ProviderLeadSerializer
    include FastJsonapi::ObjectSerializer
    belongs_to :providable, polymorphic: true, lazy_load_data: true
    belongs_to :lead
    attributes :id
  end

  class PilotSerializer
    include FastJsonapi::ObjectSerializer
    attributes :id
  end

  class AgentSerializer
    include FastJsonapi::ObjectSerializer
    attributes :id
  end

  let(:pilot) do
    x = Pilot.new
    x.id =  123
    x
  end

  let(:agent) do
    x = Agent.new
    x.id = 456
    x
  end

  let(:lead) do
    x = Lead.new
    x.id = 1
    x.provider_lead_ids = [99, 100]
    x
  end

  let(:provider_lead_1) do
    x = ProviderLead.new
    x.id = 99
    x.lead_id = lead.id
    x.providable_type = 'Agent'
    x.providable_id = agent.id
    x
  end

  let(:provider_lead_2) do
    x = ProviderLead.new
    x.id = 100
    x.lead_id = lead.id
    x.providable_type = 'Pilot'
    x.providable_id = pilot.id
    x
  end

  context 'when serializing id and type of polymorphic relationships' do
    context 'when included relationship is lazy loaded' do
      it 'should return correct relationship data' do
        options = { include: [:provider_leads, :"provider_leads.providable"] }
        lead_hash = LeadSerializer.new(lead, options).to_hash

        provider_leads = lead_hash[:data][:relationships][:provider_leads][:data]
        expect(provider_leads).to be_present

        provider_leads.each do |pl|
          included_data = lead_hash[:included].find { |x| x[:id] == pl[:id] }

          expect(included_data).to be_present
          expect(included_data[:relationships][:providable][:data]).to be_present
        end
      end
    end
  end
end
