require 'spec_helper'

RSpec.describe AltaLabs do
  describe '.root' do
    it 'returns the gem root path' do
      expect(AltaLabs.root).to be_a(Pathname)
      expect(AltaLabs.root.join('lib', 'alta_labs.rb')).to exist
    end
  end

  describe '.logger' do
    it 'returns a logger' do
      expect(AltaLabs.logger).to be_a(Logger)
    end
  end

  describe '.configure' do
    after { AltaLabs::Configuration.reset! }

    it 'yields the default configuration' do
      AltaLabs.configure do |config|
        config.email = 'test@example.com'
      end
      expect(AltaLabs.configuration.email).to eq('test@example.com')
    end
  end
end
