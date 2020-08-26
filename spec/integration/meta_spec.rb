require 'spec_helper'

RSpec.describe JSONAPI::Serializer do
  let(:user) { User.fake }
  let(:params) { {} }
  let(:serialized) do
    UserSerializer.new(user, params).serializable_hash.as_json
  end

  it do
    expect(serialized['data']).to have_meta('email_length' => user.email.size)
  end

  context 'with root meta' do
    let(:params) do
      {
        meta: { 'code' => FFaker::Internet.password }
      }
    end

    it do
      expect(serialized).to have_meta(params[:meta])
    end
  end
end
