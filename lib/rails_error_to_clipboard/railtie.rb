# frozen_string_literal: true

module RailsErrorToClipboard
  class Railtie < Rails::Railtie
    config.before_configuration do
      RailsErrorToClipboard.configure {}
      puts '[rails_error_to_clipboard] Railtie initializing...'
    end

    config.app_middleware.insert_after(ActionDispatch::ShowExceptions, RailsErrorToClipboard::Middleware)
  end
end
