module AltaLabs
  module Auth
    # Authenticates with AWS Cognito using the SRP protocol.
    # Returns JWT tokens (id_token, access_token, refresh_token).
    class Cognito
      attr_reader :config, :tokens

      def initialize(config)
        @config = config
        @tokens = {}
      end

      # Perform full SRP authentication flow.
      # @return [Hash] tokens hash with :id_token, :access_token, :refresh_token
      def authenticate(email: config.email, password: config.password)
        raise InvalidCredentialsError, 'Email and password are required' unless email && password

        srp = SRP.new(config.pool_name)

        # Step 1: Initiate auth
        challenge = initiate_auth(email, srp.srp_a)

        case challenge['ChallengeName']
        when 'PASSWORD_VERIFIER'
          respond_to_password_verifier(srp, challenge, email, password)
        when 'SOFTWARE_TOKEN_MFA', 'SMS_MFA'
          raise MfaRequiredError.new(
            session: challenge['Session'],
            challenge_name: challenge['ChallengeName']
          )
        else
          raise AuthenticationError, "Unexpected challenge: #{challenge['ChallengeName']}"
        end
      end

      # Refresh tokens using the refresh_token.
      # @return [Hash] refreshed tokens
      def refresh(refresh_token = nil)
        refresh_token ||= @tokens[:refresh_token]
        raise AuthenticationError, 'No refresh token available' unless refresh_token

        result = cognito_request('InitiateAuth', {
          'AuthFlow' => 'REFRESH_TOKEN_AUTH',
          'ClientId' => config.client_id,
          'AuthParameters' => {
            'REFRESH_TOKEN' => refresh_token
          }
        })

        auth_result = result['AuthenticationResult']
        @tokens = {
          id_token: auth_result['IdToken'],
          access_token: auth_result['AccessToken'],
          refresh_token: refresh_token, # Cognito doesn't return a new refresh token
          expires_at: Time.now + auth_result['ExpiresIn'].to_i
        }
      end

      # Respond to MFA challenge.
      # @param code [String] the MFA code
      # @param session [String] session from MfaRequiredError
      # @param challenge_name [String] challenge type from MfaRequiredError
      # @return [Hash] tokens
      def verify_mfa(code:, session:, challenge_name: 'SOFTWARE_TOKEN_MFA')
        result = cognito_request('RespondToAuthChallenge', {
          'ChallengeName' => challenge_name,
          'ClientId' => config.client_id,
          'Session' => session,
          'ChallengeResponses' => {
            'USERNAME' => config.email,
            'SOFTWARE_TOKEN_MFA_CODE' => code
          }
        })

        extract_tokens(result['AuthenticationResult'])
      end

      def id_token
        @tokens[:id_token]
      end

      def token_expired?
        return true unless @tokens[:expires_at]

        Time.now >= @tokens[:expires_at] - 60 # 60s buffer
      end

      private

      def initiate_auth(email, srp_a)
        cognito_request('InitiateAuth', {
          'AuthFlow' => 'USER_SRP_AUTH',
          'ClientId' => config.client_id,
          'AuthParameters' => {
            'USERNAME' => email,
            'SRP_A' => srp_a
          }
        })
      end

      def respond_to_password_verifier(srp, challenge, email, password)
        params = challenge['ChallengeParameters']
        timestamp = Time.now.utc.strftime('%a %b %-d %H:%M:%S UTC %Y')

        signature = srp.compute_claim(
          user_id: params['USER_ID_FOR_SRP'],
          password: password,
          srp_b: params['SRP_B'],
          salt: params['SALT'],
          secret_block: params['SECRET_BLOCK'],
          timestamp: timestamp
        )

        result = cognito_request('RespondToAuthChallenge', {
          'ChallengeName' => 'PASSWORD_VERIFIER',
          'ClientId' => config.client_id,
          'ChallengeResponses' => {
            'USERNAME' => params['USER_ID_FOR_SRP'],
            'PASSWORD_CLAIM_SECRET_BLOCK' => params['SECRET_BLOCK'],
            'PASSWORD_CLAIM_SIGNATURE' => signature,
            'TIMESTAMP' => timestamp
          }
        })

        if result['ChallengeName']
          case result['ChallengeName']
          when 'SOFTWARE_TOKEN_MFA', 'SMS_MFA'
            raise MfaRequiredError.new(
              session: result['Session'],
              challenge_name: result['ChallengeName']
            )
          else
            raise AuthenticationError, "Unexpected post-auth challenge: #{result['ChallengeName']}"
          end
        end

        extract_tokens(result['AuthenticationResult'])
      end

      def extract_tokens(auth_result)
        raise AuthenticationError, 'No authentication result' unless auth_result

        @tokens = {
          id_token: auth_result['IdToken'],
          access_token: auth_result['AccessToken'],
          refresh_token: auth_result['RefreshToken'],
          expires_at: Time.now + auth_result['ExpiresIn'].to_i
        }
      end

      def cognito_request(action, body)
        response = cognito_connection.post('') do |req|
          req.headers['X-Amz-Target'] = "AWSCognitoIdentityProviderService.#{action}"
          req.headers['Content-Type'] = 'application/x-amz-json-1.1'
          req.body = body.to_json
        end

        result = JSON.parse(response.body)

        if response.status != 200
          error_type = result['__type']&.split('#')&.last || 'Unknown'
          error_msg = result['message'] || result['Message'] || 'Authentication failed'
          raise AuthenticationError, "#{error_type}: #{error_msg}"
        end

        result
      end

      def cognito_connection
        @cognito_connection ||= Faraday.new(url: config.cognito_endpoint) do |f|
          f.options.timeout = config.timeout
          f.options.open_timeout = config.open_timeout
          f.adapter Faraday.default_adapter
        end
      end
    end
  end
end
