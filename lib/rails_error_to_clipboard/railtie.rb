# frozen_string_literal: true

module RailsErrorToClipboard
  class Railtie < Rails::Railtie
    config.before_configuration do
      RailsErrorToClipboard.configure {}
    end

    config.middleware.insert_after(ActionDispatch::Executor, RailsErrorToClipboard::Middleware)
  end
end
