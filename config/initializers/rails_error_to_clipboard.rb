# frozen_string_literal: true

RailsErrorToClipboard.configure do |config|
  config.enabled = Rails.env.development?
end
