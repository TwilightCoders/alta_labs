require 'simplecov'
require 'simplecov-json'

SimpleCov.start do
  add_filter 'spec'
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ])
end

require 'alta_labs'
require 'webmock/rspec'
require 'json'

RSpec.configure do |config|
  config.order = 'random'
  config.filter_run_when_matching :focus

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
