module AltaLabs
  class Resource
    attr_reader :client

    def initialize(client)
      @client = client
    end

    private

    # GET request — for read operations.
    def get(path, params = {})
      client.get(path, params)
    end

    # POST request — for write/mutation operations.
    def post(path, body = {})
      client.post(path, body)
    end

    # POST with access_token — for account operations.
    def post_authenticated(path, body = {})
      client.post_authenticated(path, body)
    end
  end
end
