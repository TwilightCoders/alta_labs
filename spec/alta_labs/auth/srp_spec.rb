require 'spec_helper'

RSpec.describe AltaLabs::Auth::SRP do
  subject(:srp) { described_class.new('TestPool') }

  describe '#srp_a' do
    it 'returns a hex string' do
      expect(srp.srp_a).to match(/\A[0-9a-fA-F]+\z/)
    end

    it 'is not zero mod N' do
      a = OpenSSL::BN.new(srp.srp_a, 16)
      n = OpenSSL::BN.new(described_class::N_HEX, 16)
      expect((a % n).zero?).to be false
    end

    it 'generates a different value each time' do
      other = described_class.new('TestPool')
      expect(srp.srp_a).not_to eq(other.srp_a)
    end
  end

  describe '#compute_claim' do
    it 'returns a base64-encoded string' do
      # Use deterministic test values
      claim = srp.compute_claim(
        user_id: 'testuser',
        password: 'testpass',
        srp_b: 'A' * 768,
        salt: 'DEADBEEF',
        secret_block: Base64.strict_encode64('secret' * 20),
        timestamp: 'Mon Mar 30 12:00:00 UTC 2026'
      )
      expect(claim).to match(%r{\A[A-Za-z0-9+/]+=*\z})
    end
  end
end
