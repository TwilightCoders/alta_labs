module AltaLabs
  class Error < StandardError; end

  class AuthenticationError < Error; end
  class TokenExpiredError < AuthenticationError; end
  class InvalidCredentialsError < AuthenticationError; end
  class MfaRequiredError < AuthenticationError
    attr_reader :session, :challenge_name

    def initialize(message = 'MFA verification required', session: nil, challenge_name: nil)
      @session = session
      @challenge_name = challenge_name
      super(message)
    end
  end

  class ApiError < Error
    attr_reader :status, :body

    def initialize(message = nil, status: nil, body: nil)
      @status = status
      @body = body
      super(message || "API error (#{status})")
    end
  end

  class NotFoundError < ApiError; end
  class RateLimitError < ApiError; end
  class ServerError < ApiError; end
end
