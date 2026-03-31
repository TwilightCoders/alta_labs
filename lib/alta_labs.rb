require 'json'
require 'logger'
require 'openssl'
require 'securerandom'
require 'base64'
require 'pathname'
require 'time'

require 'faraday'
require 'faraday/retry'

require_relative 'alta_labs/version'
require_relative 'alta_labs/error'
require_relative 'alta_labs/configuration'
require_relative 'alta_labs/auth/srp'
require_relative 'alta_labs/auth/cognito'
require_relative 'alta_labs/resource'
require_relative 'alta_labs/resources/account'
require_relative 'alta_labs/resources/site'
require_relative 'alta_labs/resources/device'
require_relative 'alta_labs/resources/ssid'
require_relative 'alta_labs/resources/client_device'
require_relative 'alta_labs/resources/group'
require_relative 'alta_labs/resources/profile'
require_relative 'alta_labs/resources/floor_plan'
require_relative 'alta_labs/resources/filter'
require_relative 'alta_labs/client'

module AltaLabs
  class << self
    attr_writer :logger

    def root(*args)
      (@root ||= Pathname.new(File.expand_path('../', __dir__))).join(*args)
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
        log.level = Logger::WARN
      end
    end

    def configure
      yield(Configuration.default)
    end

    def configuration
      Configuration.default
    end
  end
end
