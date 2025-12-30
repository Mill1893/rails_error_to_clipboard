# frozen_string_literal: true

module RailsErrorToClipboard
  class Railtie < Rails::Railtie
    config.before_configuration do
      RailsErrorToClipboard.configure {}
      puts '[rails_error_to_clipboard] Railtie initializing...'
    end

    config.after_initialize do
      middleware_names = Rails.configuration.app_middleware.map(&:name).map(&:to_s)
      puts "[rails_error_to_clipboard] Middleware in stack: #{middleware_names.include?('RailsErrorToClipboard::Middleware')}"
    end

    config.app_middleware.insert_after(ActionDispatch::ShowExceptions, RailsErrorToClipboard::Middleware)
  end
end
