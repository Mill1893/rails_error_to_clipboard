# frozen_string_literal: true

module RailsErrorToClipboard
  class Railtie < Rails::Railtie
    config.before_configuration do
      RailsErrorToClipboard.configure {}
    end

    config.app_middleware.use RailsErrorToClipboard::Middleware
  end
end
