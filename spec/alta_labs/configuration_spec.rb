require 'spec_helper'

RSpec.describe AltaLabs::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it 'uses the production API URL' do
      expect(config.api_url).to eq('https://manage.alta.inc')
    end

    it 'uses the production Cognito settings' do
      expect(config.user_pool_id).to eq('us-east-1_4QbA7N3Uy')
      expect(config.client_id).to eq('24bk8l088t5bf31nuceoqb503q')
      expect(config.region).to eq('us-east-1')
    end

    it 'has sensible timeout defaults' do
      expect(config.timeout).to eq(30)
      expect(config.open_timeout).to eq(10)
    end
  end

  describe '#pool_name' do
    it 'extracts the pool name from the user pool ID' do
      expect(config.pool_name).to eq('4QbA7N3Uy')
    end
  end

  describe '#cognito_endpoint' do
    it 'builds the Cognito IDP URL' do
      expect(config.cognito_endpoint).to eq('https://cognito-idp.us-east-1.amazonaws.com/')
    end
  end

  describe '.reset!' do
    it 'replaces the default configuration' do
      old = described_class.default
      described_class.default.email = 'changed@example.com'
      described_class.reset!
      expect(described_class.default).not_to eq(old)
      expect(described_class.default.email).to be_nil
    end
  end
end
