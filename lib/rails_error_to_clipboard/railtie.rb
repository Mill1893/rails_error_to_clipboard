# frozen_string_literal: true

module RailsErrorToClipboard
  class Railtie < Rails::Railtie
    console do
      puts '[rails_error_to_clipboard] Gem loaded successfully'
    end

    config.before_configuration do
      RailsErrorToClipboard.configure {}
      Rails.logger&.info '[rails_error_to_clipboard] Railtie initialized'
    end

    config.app_middleware.insert_before(ActionDispatch::ShowExceptions, RailsErrorToClipboard::Middleware)
  end
end
