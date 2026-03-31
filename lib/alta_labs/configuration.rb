module AltaLabs
  class Configuration
    COGNITO_USER_POOL_ID = 'us-east-1_4QbA7N3Uy'
    COGNITO_CLIENT_ID = '24bk8l088t5bf31nuceoqb503q'
    COGNITO_REGION = 'us-east-1'
    DEFAULT_API_URL = 'https://manage.alta.inc'

    attr_accessor :email, :password, :api_url,
                  :user_pool_id, :client_id, :region,
                  :log_level, :timeout, :open_timeout

    def initialize
      @email = ENV['ALTA_LABS_EMAIL']
      @password = ENV['ALTA_LABS_PASSWORD']
      @api_url = ENV.fetch('ALTA_LABS_API_URL', DEFAULT_API_URL)
      @user_pool_id = COGNITO_USER_POOL_ID
      @client_id = COGNITO_CLIENT_ID
      @region = COGNITO_REGION
      @log_level = :warn
      @timeout = 30
      @open_timeout = 10
    end

    def pool_name
      user_pool_id.split('_').last
    end

    def cognito_endpoint
      "https://cognito-idp.#{region}.amazonaws.com/"
    end

    def self.default
      @default ||= new
    end

    def self.reset!
      @default = new
    end
  end
end
