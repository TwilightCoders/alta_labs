require 'spec_helper'

RSpec.describe AltaLabs::Client do
  let(:client) { described_class.new(email: 'test@example.com', password: 'secret') }

  describe '#initialize' do
    it 'sets credentials on the config' do
      expect(client.config.email).to eq('test@example.com')
      expect(client.config.password).to eq('secret')
    end

    it 'creates an auth instance' do
      expect(client.auth).to be_a(AltaLabs::Auth::Cognito)
    end
  end

  describe 'resource accessors' do
    it { expect(client.sites).to be_a(AltaLabs::Resources::Site) }
    it { expect(client.devices).to be_a(AltaLabs::Resources::Device) }
    it { expect(client.wifi).to be_a(AltaLabs::Resources::Ssid) }
    it { expect(client.clients).to be_a(AltaLabs::Resources::ClientDevice) }
    it { expect(client.account).to be_a(AltaLabs::Resources::Account) }
    it { expect(client.groups).to be_a(AltaLabs::Resources::Group) }
    it { expect(client.profiles).to be_a(AltaLabs::Resources::Profile) }
    it { expect(client.floor_plans).to be_a(AltaLabs::Resources::FloorPlan) }
    it { expect(client.filters).to be_a(AltaLabs::Resources::Filter) }
  end

  describe '#get' do
    before do
      allow(client.auth).to receive(:id_token).and_return('test-token')
      allow(client.auth).to receive(:token_expired?).and_return(false)
    end

    it 'includes token as query parameter' do
      stub = stub_request(:get, 'https://manage.alta.inc/api/sites/list')
        .with(query: hash_including('token' => 'test-token'))
        .to_return(status: 200, body: '[]', headers: { 'Content-Type' => 'application/json' })

      client.get('/api/sites/list')
      expect(stub).to have_been_requested
    end
  end

  describe '#post' do
    before do
      allow(client.auth).to receive(:id_token).and_return('test-token')
      allow(client.auth).to receive(:token_expired?).and_return(false)
    end

    it 'includes token in JSON body' do
      stub = stub_request(:post, 'https://manage.alta.inc/api/sites/stats')
        .with(body: hash_including('token' => 'test-token'))
        .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

      client.post('/api/sites/stats', siteid: 'abc')
      expect(stub).to have_been_requested
    end
  end

  describe 'error handling' do
    before do
      allow(client.auth).to receive(:id_token).and_return('test-token')
      allow(client.auth).to receive(:token_expired?).and_return(false)
    end

    it 'raises NotFoundError on 404' do
      stub_request(:get, /manage\.alta\.inc/)
        .to_return(status: 404, body: '"not found"', headers: { 'Content-Type' => 'application/json' })

      expect { client.get('/api/site', id: 'bad') }.to raise_error(AltaLabs::NotFoundError)
    end

    it 'raises ServerError on 500' do
      stub_request(:get, /manage\.alta\.inc/)
        .to_return(status: 500, body: '"internal error"', headers: { 'Content-Type' => 'application/json' })

      expect { client.get('/api/site', id: 'bad') }.to raise_error(AltaLabs::ServerError)
    end
  end
end
