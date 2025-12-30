# frozen_string_literal: true

RailsErrorToClipboard.configure do |config|
  config.enabled = true
  config.button_text = 'Copy for AI'
  config.button_css_class = 'rails-error-to-clipboard-button'
  config.position = 'bottom-right'
end
