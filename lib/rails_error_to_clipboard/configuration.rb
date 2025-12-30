# frozen_string_literal: true

module RailsErrorToClipboard
  class Configuration
    attr_accessor :enabled, :button_text, :button_css_class, :position

    def initialize
      @enabled = true
      @button_text = "Copy for AI"
      @button_css_class = "rails-error-to-clipboard-button"
      @position = "bottom-right"
    end

    def self.default
      Configuration.new
    end
  end
end
