# Rack::MaintenanceMode

A Rack middleware that provides maintenance mode functionality by monitoring external status endpoints or using custom checkers. When maintenance mode is detected, it displays customizable maintenance pages with HTTP 503 status.

## Features

- **External Status Monitoring**: Monitor maintenance status via HTTP endpoints
- **Custom Checkers**: Use your own objects with `maintenance_mode?` method
- **Customizable Pages**: Display custom HTML files or inline content during maintenance
- **Rack Compatible**: Works with any Rack-based application (Rails, Sinatra, etc.)

## Installation

**Important**: This gem depends on `simple-backstage-status` which is hosted on GitHub. You need to add both gems to your Gemfile:

```ruby
# Add to your Gemfile
gem "simple-backstage-status", git: "https://github.com/colorfulcompany/rack-collection", glob: "simple-backstage-status/*.gemspec"
gem "rack-maintenance_mode"
```

Then execute:

```bash
bundle install
```

## How It Works

1. **Status Checking**: The middleware checks maintenance status on each request
2. **Service Filtering**: When using status endpoints, you can specify which service to monitor
3. **Response Handling**:
   - Normal operation: Passes request to your application
   - Maintenance mode: Returns HTTP 503 with maintenance page
4. **Page Rendering**: Shows custom HTML file or default "MaintenancePage" message

## Usage

### Basic Usage with Status Endpoint

Monitor an external status endpoint to determine maintenance mode:

```ruby
# In your config.ru or Rails application
use Rack::MaintenanceMode, {
  status_endpoint: "https://status.example.com/api/status.json",
  service: "your_service_name",
  file: "/path/to/maintenance.html"  # Optional: custom maintenance page
}
```

### Custom Maintenance Page

You can specify a custom HTML file to display during maintenance. If not specified, a default "MaintenancePage" message will be shown:

```ruby
use Rack::MaintenanceMode, {
  status_endpoint: "https://status.example.com/api/status.json",
  service: "your_service_name",
  file: Rails.root.join("public", "maintenance.html")
}
```

Example maintenance page (`public/maintenance.html`):

```html
<!DOCTYPE html>
<html>
<head>
  <title>Maintenance Mode</title>
  <meta charset="utf-8">
</head>
<body>
  <h1>We're currently under maintenance</h1>
  <p>We'll be back shortly. Thank you for your patience.</p>
</body>
</html>
```

### Custom Maintenance Checker

Use your own object that responds to `maintenance_mode?`:

```ruby
class MaintenanceConfig
  def maintenance_mode?
    # Your custom logic here
    Rails.cache.read("maintenance_mode") == true
  end
end

use Rack::MaintenanceMode, {
  checker: MaintenanceConfig.new
}
```

### Rails Integration

In your Rails application, add to `config/application.rb`:

```ruby
config.middleware.use Rack::MaintenanceMode, {
  status_endpoint: ENV["STATUS_ENDPOINT"],
  service: ENV["SERVICE_NAME"],
  file: Rails.root.join("public", "maintenance.html")
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/colorfulcompany/rack-collection.
