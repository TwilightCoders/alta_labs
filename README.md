[![Gem Version](https://img.shields.io/gem/v/alta_labs.svg)](https://rubygems.org/gems/alta_labs)
[![Build Status](https://github.com/TwilightCoders/alta_labs/workflows/CI/badge.svg)](https://github.com/TwilightCoders/alta_labs/actions)
[![Coverage](https://img.qlty.sh/badges/github/TwilightCoders/alta_labs/coverage.svg)](https://qlty.sh/gh/TwilightCoders/alta_labs)

# AltaLabs

A Ruby SDK for the [Alta Labs](https://alta.inc) cloud management API. Manage sites, devices, WiFi networks, and more programmatically.

> **Note:** Alta Labs does not currently publish public API documentation. This library was built by reverse-engineering the web management portal at `manage.alta.inc`. While functional, the API surface may change without notice.

## Installation

Add to your Gemfile:

```ruby
gem 'alta_labs'
```

Or install directly:

```
$ gem install alta_labs
```

## Usage

### Authentication

The SDK authenticates with Alta Labs via AWS Cognito SRP — the same mechanism used by the web portal. No AWS SDK dependency is required; SRP is implemented natively.

```ruby
require 'alta_labs'

client = AltaLabs::Client.new(
  email: 'you@example.com',
  password: 'your-password'
)

# Authentication happens automatically on the first API call,
# or you can authenticate explicitly:
client.authenticate
```

You can also configure via environment variables or a block:

```ruby
# Environment variables (ALTA_LABS_EMAIL, ALTA_LABS_PASSWORD)
client = AltaLabs::Client.new

# Block configuration
AltaLabs.configure do |config|
  config.email = 'you@example.com'
  config.password = 'your-password'
  config.timeout = 60
end
```

### Sites

```ruby
# List all sites
sites = client.sites.list
# => [{"id" => "abc123", "name" => "Main Office", "online" => 5, ...}]

# Get site detail
site = client.sites.find(id: 'abc123')
# => {"id" => "abc123", "tz" => "America/Denver", "vlans" => [...], ...}

# Site audit log
audit = client.sites.audit(id: 'abc123')
audit['trail'].each do |entry|
  puts "[#{entry['ts']}] #{entry['action']} #{entry['type']}"
end

# Create a site
client.sites.create(name: 'New Site', type: 'residential')

# Rename a site
client.sites.rename(id: 'abc123', name: 'Updated Name')
```

### Devices

```ruby
# List devices for a site
devices = client.devices.list(site_id: 'abc123')

# Add a device by serial number
client.devices.add_serial(site_id: 'abc123', serial: 'ALTA-XXXX')

# Move a device between sites
client.devices.move(id: 'device-id', site_id: 'new-site-id')
```

### WiFi / SSIDs

```ruby
# List SSIDs for a site
result = client.wifi.list(site_id: 'abc123')
result['ssids'].each do |ssid|
  puts "#{ssid['ssid']} (#{ssid.dig('config', 'security')})"
end

# Get a specific SSID
ssid = client.wifi.find(id: 'ssid-id')
```

### Account

```ruby
# Get account info (requires access_token)
info = client.account.info
```

### Content Filtering

```ruby
# Get content filter settings
filter = client.filters.get_filter(site_id: 'abc123')
# => {"blockedRegions" => ["CN"], "blockWired" => true, ...}
```

### Profiles

```ruby
profiles = client.profiles.list(site_ids: ['abc123'])
```

### Floor Plans

```ruby
floors = client.floor_plans.floors(site_id: 'abc123')
```

## Token Management

Tokens are automatically refreshed when they expire. The SDK handles:

- Initial SRP authentication with Cognito
- JWT token storage and expiration tracking
- Automatic token refresh using the refresh token
- MFA challenges (raises `AltaLabs::MfaRequiredError` with session data)

### MFA Support

If MFA is enabled on the account:

```ruby
begin
  client.authenticate
rescue AltaLabs::MfaRequiredError => e
  # Prompt user for MFA code
  client.auth.verify_mfa(
    code: '123456',
    session: e.session,
    challenge_name: e.challenge_name
  )
end
```

## Error Handling

```ruby
begin
  client.sites.find(id: 'nonexistent')
rescue AltaLabs::AuthenticationError => e
  # Invalid credentials or expired session
rescue AltaLabs::NotFoundError => e
  # Resource not found
rescue AltaLabs::RateLimitError => e
  # Too many requests
rescue AltaLabs::ServerError => e
  # Alta Labs server error
rescue AltaLabs::ApiError => e
  # Generic API error
  puts e.status # HTTP status code
  puts e.body   # Response body
end
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `email` | `ENV['ALTA_LABS_EMAIL']` | Account email |
| `password` | `ENV['ALTA_LABS_PASSWORD']` | Account password |
| `api_url` | `https://manage.alta.inc` | API base URL |
| `timeout` | `30` | Request timeout (seconds) |
| `open_timeout` | `10` | Connection open timeout (seconds) |

## Self-Hosted Controller

To use with a self-hosted Alta Control instance:

```ruby
client = AltaLabs::Client.new(
  email: 'you@example.com',
  password: 'your-password',
)
client.config.api_url = 'https://your-controller.local'
```

## Development

```
$ bundle install
$ bundle exec rspec
$ bin/console
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## License

MIT License. See [LICENSE.txt](LICENSE.txt).
