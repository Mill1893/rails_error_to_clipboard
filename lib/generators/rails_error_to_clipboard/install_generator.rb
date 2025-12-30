# frozen_string_literal: true

module RailsErrorToClipboard
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def create_initializer
        create_file 'config/initializers/rails_error_to_clipboard.rb', <<~RUBY
          # frozen_string_literal: true

          RailsErrorToClipboard.configure do |config|
            config.enabled = true
            config.button_text = "Copy for AI"
          end
        RUBY
      end

      def add_middleware
        puts "\nMiddleware auto-injected via Railtie - no manual configuration needed.\n\n"
      end
    end
  end
end
