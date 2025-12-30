# frozen_string_literal: true

require 'rails_error_to_clipboard/version'
require 'rails_error_to_clipboard/configuration'
require 'rails_error_to_clipboard/markdown_formatter'
require 'rails_error_to_clipboard/middleware'
require 'rails_error_to_clipboard/button_injector'

module RailsErrorToClipboard
  class << self
    def configure
      @configuration ||= Configuration.default
      yield(@configuration)
      @configuration
    end

    def configuration
      @configuration ||= Configuration.default
    end

    def reset_configuration
      @configuration = Configuration.default
    end
  end
end

require 'rails_error_to_clipboard/railtie' if defined?(Rails)
require 'rails_error_to_clipboard/engine' if defined?(Rails)
