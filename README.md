# rails_error_to_clipboard

Add 'Copy for AI' button to Rails error pages. Formats error details into structured Markdown for easy copy to AI assistants.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails_error_to_clipboard"
```

Then run:

```bash
bundle install
```

## Configuration

Create an initializer in `config/initializers/rails_error_to_clipboard.rb`:

```ruby
RailsErrorToClipboard.configure do |config|
  config.enabled = true
end
```

## Usage

When a Rails error page is rendered, a "Copy for AI" button will appear. Clicking it copies the error details in Markdown format to your clipboard.
