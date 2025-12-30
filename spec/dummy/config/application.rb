# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'

Bundler.require(*Rails.groups)
require 'rails_error_to_clipboard'

module Dummy
  class Application < Rails::Application
    config.load_defaults 7.0
    config.eager_load = false
    config.secret_key_base = 'test_secret_key_base'
    config.hosts.clear

    console do
      RailsErrorToClipboard.configure do |config|
        config.enabled = true
      end
    end
  end
end
