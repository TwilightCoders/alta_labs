module AltaLabs
  class Client
    attr_reader :config, :auth

    def initialize(email: nil, password: nil, config: nil)
      @config = config || Configuration.new
      @config.email = email if email
      @config.password = password if password
      @auth = Auth::Cognito.new(@config)
    end

    # Authenticate with Cognito. Called automatically on first request if needed.
    def authenticate
      @auth.authenticate
      self
    end

    # GET request — token sent as query parameter.
    def get(path, params = {})
      ensure_authenticated
      params[:token] = @auth.id_token

      response = connection.get(path, params)
      handle_response(response)
    end

    # POST request — token sent in JSON body.
    def post(path, body = {})
      ensure_authenticated
      body[:token] = @auth.id_token

      response = connection.post(path) do |req|
        req.body = body.to_json
      end
      handle_response(response)
    end

    # POST request that also includes the Cognito access_token.
    def post_authenticated(path, body = {})
      ensure_authenticated
      body[:token] = @auth.id_token
      body[:access_token] = @auth.tokens[:access_token]

      response = connection.post(path) do |req|
        req.body = body.to_json
      end
      handle_response(response)
    end

    def sites
      @sites ||= Resources::Site.new(self)
    end

    def devices
      @devices ||= Resources::Device.new(self)
    end

    def wifi
      @wifi ||= Resources::Ssid.new(self)
    end

    def clients
      @clients ||= Resources::ClientDevice.new(self)
    end

    def account
      @account ||= Resources::Account.new(self)
    end

    def groups
      @groups ||= Resources::Group.new(self)
    end

    def profiles
      @profiles ||= Resources::Profile.new(self)
    end

    def floor_plans
      @floor_plans ||= Resources::FloorPlan.new(self)
    end

    def filters
      @filters ||= Resources::Filter.new(self)
    end

    private

    def ensure_authenticated
      if @auth.id_token.nil?
        authenticate
      elsif @auth.token_expired?
        @auth.refresh
      end
    end

    def connection
      @connection ||= Faraday.new(url: @config.api_url) do |f|
        f.headers['Content-Type'] = 'application/json'
        f.headers['Accept'] = 'application/json'
        f.request :retry, max: 2, interval: 0.5, backoff_factor: 2,
                          exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed]
        f.options.timeout = @config.timeout
        f.options.open_timeout = @config.open_timeout
        f.adapter Faraday.default_adapter
      end
    end

    def handle_response(response)
      body = parse_body(response)

      case response.status
      when 200..299
        body
      when 401
        @auth.refresh
        raise AuthenticationError, 'Authentication failed after refresh'
      when 404
        raise NotFoundError.new(status: response.status, body: body)
      when 429
        raise RateLimitError.new(status: response.status, body: body)
      when 500..599
        raise ServerError.new(status: response.status, body: body)
      else
        raise ApiError.new("#{body}", status: response.status, body: body)
      end
    end

    def parse_body(response)
      return response.body unless response.body.is_a?(String)
      return nil if response.body.empty?

      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end
  end
end
