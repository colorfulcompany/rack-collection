# SimpleBackstageStatus

A Ruby library for building simple backstage (service status management) systems. This gem provides both server and client functionality for managing and distributing operational status of services.

## Features

- **HTTP Client** - Fetch service status from external APIs
- **Rack Server** - Serve service status as HTTP API
- **Content Loaders** - Load service status from JSON, YAML, or Ruby files
- **Schema Validation** - Validate status data using dry-schema
- **CLI Tools** - Command-line tools for validation and JSON building
- **Predefined Status Constants** - Standard operational status definitions

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple-backstage-status'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install simple-backstage-status
```

## Usage

### As a Rack Server

Use as middleware to serve service status:

```ruby
require 'simple_backstage_status'

# Serve status from a JSON file
use SimpleBackstageStatus::RackServer, {
  uri: "json://path/to/status.json"
}

# Serve status from a YAML file
use SimpleBackstageStatus::RackServer, {
  uri: "yaml://path/to/status.yaml"
}

# Serve status from a Ruby file
use SimpleBackstageStatus::RackServer, {
  uri: "ruby://path/to/status.rb"
}

# Serve status from a Hash
use SimpleBackstageStatus::RackServer, {
  hash: {
    services: [
      {
        name: "api",
        status: "operational",
        description: "API is running normally",
        updated_at: Time.now
      }
    ]
  }
}
```

### As a Client

Fetch and validate service status from remote endpoints:

```ruby
require 'simple_backstage_status'

client = SimpleBackstageStatus::Client.new(
  "https://status.example.com/api/status",
  service: "api"
)

result = client.service_status
result.either(
  ->(status) { puts "Service status: #{status}" },
  ->(error) { puts "Error: #{error}" }
)
```

### CLI Tools

Validate status files:

```bash
backstage-status validate status.json
```

Convert status files to JSON:

```bash
backstage-status build status.yaml
```

### Status File Format

Status files should follow this structure ( with default schema, you can customize that ) :

#### JSON Format


```json
{
  "services": [
    {
      "name": "api",
      "status": "operational",
      "description": "API is running normally",
      "updated_at": "2025-07-31T10:00:00+09:00"
    }
  ]
}
```

#### YAML Format

```yaml
services:
  - name: api
    status: operational
    description: API is running normally
    updated_at: 2025-07-31T10:00:00+09:00
```

#### Ruby Format

```ruby
{
  services: [
    {
      name: "api",
      status: "operational",
      description: "API is running normally",
      updated_at: Time.now
    }
  ]
}
```

### Available Status Values

```ruby
SimpleBackstageStatus::Status::OPERATIONAL           # :operational
SimpleBackstageStatus::Status::DEGRATED             # :degrated
SimpleBackstageStatus::Status::PARTIAL_OUTAGE       # :partial_outage
SimpleBackstageStatus::Status::MAJOR_OUTAGE         # :major_outage
SimpleBackstageStatus::Status::SCHEDULE_MAINTENANCE # :schedule_maintenance
SimpleBackstageStatus::Status::MAINTENANCE          # :maintenance
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/colorfulcompany/rack-collection.
