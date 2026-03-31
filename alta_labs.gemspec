require_relative 'lib/alta_labs/version'

Gem::Specification.new do |spec|
  spec.name          = 'alta_labs'
  spec.version       = AltaLabs::VERSION
  spec.authors       = ['Dale Stevens']
  spec.email         = ['dale@twilightcoders.net']

  spec.summary       = 'Ruby SDK for the Alta Labs cloud management API'
  spec.description   = 'A Ruby client library for interacting with the Alta Labs cloud management platform. Manage sites, devices, WiFi networks, and more programmatically.'
  spec.homepage      = 'https://github.com/TwilightCoders/alta_labs'
  spec.license       = 'MIT'

  spec.metadata = {
    'allowed_push_host' => 'https://rubygems.org',
    'homepage_uri'      => spec.homepage,
    'source_code_uri'   => 'https://github.com/TwilightCoders/alta_labs',
    'changelog_uri'     => 'https://github.com/TwilightCoders/alta_labs/blob/main/CHANGELOG.md',
    'bug_tracker_uri'   => 'https://github.com/TwilightCoders/alta_labs/issues'
  }

  spec.files         = Dir['CHANGELOG.md', 'README.md', 'LICENSE.txt', 'lib/**/*']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.1'

  spec.add_runtime_dependency 'base64', '~> 0.2'
  spec.add_runtime_dependency 'faraday', '~> 2.0'
  spec.add_runtime_dependency 'faraday-retry', '~> 2.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry-byebug', '~> 3'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-json', '~> 0.2'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'vcr', '~> 6.0'
end
