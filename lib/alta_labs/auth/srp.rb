module AltaLabs
  module Auth
    # Implements the Secure Remote Password (SRP-6a) protocol as used by
    # AWS Cognito. Uses only Ruby stdlib (OpenSSL) -- no AWS SDK required.
    #
    # Matches the amazon-cognito-identity-js reference implementation.
    class SRP
      # Cognito's 3072-bit SRP prime (hex)
      N_HEX = 'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD1' \
              '29024E088A67CC74020BBEA63B139B22514A08798E3404DD' \
              'EF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245' \
              'E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7ED' \
              'EE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3D' \
              'C2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F' \
              '83655D23DCA3AD961C62F356208552BB9ED529077096966D' \
              '670C354E4ABC9804F1746C08CA18217C32905E462E36CE3B' \
              'E39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9' \
              'DE2BCBF6955817183995497CEA956AE515D2261898FA0510' \
              '15728E5A8AAAC42DAD33170D04507A33A85521ABDF1CBA64' \
              'ECFB850458DBEF0A8AEA71575D060C7DB3970F85A6E1E4C7' \
              'ABF5AE8CDB0933D71E8C94E04A25619DCEE3D2261AD2EE6B' \
              'F12FFA06D98A0864D87602733EC86A64521F2B18177B200CB' \
              'BE117577A615D6C770988C0BAD946E208E24FA074E5AB3143' \
              'DB5BFCE0FD108E4B82D120A93AD2CAFFFFFFFFFFFFFFFF'

      G_HEX = '2'
      INFO_BITS = 'Caldera Derived Key'

      attr_reader :pool_name, :big_a, :small_a

      def initialize(pool_name)
        @pool_name = pool_name
        @n = OpenSSL::BN.new(N_HEX, 16)
        @g = OpenSSL::BN.new(G_HEX, 16)
        @k = compute_k
        generate_a
      end

      def srp_a
        @big_a.to_s(16)
      end

      # Given the server's challenge parameters, compute the password claim signature.
      def compute_claim(user_id:, password:, srp_b:, salt:, secret_block:, timestamp:)
        big_b = OpenSSL::BN.new(srp_b, 16)

        u = compute_u(big_b)
        raise AuthenticationError, 'SRP safety check: u must not be zero' if u.zero?

        x = compute_x(salt, user_id, password)
        s = compute_s(big_b, x, u)
        hkdf_key = compute_hkdf(s, u)

        secret_block_bytes = Base64.decode64(secret_block)
        msg = pool_name.encode('utf-8') +
              user_id.encode('utf-8') +
              secret_block_bytes +
              timestamp.encode('utf-8')
        hmac = OpenSSL::HMAC.digest('SHA256', hkdf_key, msg)
        Base64.strict_encode64(hmac)
      end

      private

      def generate_a
        loop do
          @small_a = OpenSSL::BN.new(SecureRandom.hex(128), 16)
          @big_a = @g.mod_exp(@small_a, @n)
          break unless (@big_a % @n).zero?
        end
      end

      def compute_k
        hex_hash_bn(pad_hex(@n) + pad_hex(@g))
      end

      def compute_u(big_b)
        hex_hash_bn(pad_hex(@big_a) + pad_hex(big_b))
      end

      def compute_x(salt_hex, user_id, password)
        # Inner: H(poolName || userId || ":" || password) -> hex
        identity_hex = hex_sha256(pool_name + user_id + ':' + password)
        # Outer: H(pad(salt) || identityHash)
        hex_hash_bn(pad_hex_str(salt_hex) + identity_hex)
      end

      def compute_s(big_b, x, u)
        gx = @g.mod_exp(x, @n)
        base = (big_b - @k * gx) % @n
        exp = @small_a + u * x
        base.mod_exp(exp, @n)
      end

      def compute_hkdf(s, u)
        ikm = hex_to_bytes(pad_hex(s))
        salt = hex_to_bytes(pad_hex(OpenSSL::BN.new(u.to_s(16), 16)))

        prk = OpenSSL::HMAC.digest('SHA256', salt, ikm)
        info = INFO_BITS + "\x01"
        hmac = OpenSSL::HMAC.digest('SHA256', prk, info)
        hmac[0, 16]
      end

      # Cognito-style hex padding: ensure even length, prepend 00 if high bit set.
      # Matches amazon-cognito-identity-js padHex().
      def pad_hex(bn)
        pad_hex_str(bn.to_s(16))
      end

      def pad_hex_str(hex)
        hex = hex.delete_prefix('-')
        hex = "0#{hex}" if hex.length.odd?
        hex = "00#{hex}" if hex[0]&.match?(/[89a-fA-F]/)
        hex
      end

      def hex_to_bytes(hex)
        [hex].pack('H*')
      end

      # SHA256 of a raw string, returned as hex
      def hex_sha256(str)
        OpenSSL::Digest::SHA256.hexdigest(str)
      end

      # Hash a hex string (converting to bytes first), return as BN
      def hex_hash_bn(hex_str)
        digest = OpenSSL::Digest::SHA256.hexdigest(hex_to_bytes(hex_str))
        OpenSSL::BN.new(digest, 16)
      end
    end
  end
end
