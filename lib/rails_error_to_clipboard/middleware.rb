# frozen_string_literal: true

module RailsErrorToClipboard
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      puts "[rails_error_to_clipboard] Status: #{status}, Content-Type: #{headers['Content-Type']}"

      return [status, headers, body] unless should_inject?(status, headers)

      exception = env['action_dispatch.exception'] || env['rack.exception']
      puts "[rails_error_to_clipboard] Exception found: #{!exception.nil?}"

      puts "[rails_error_to_clipboard] Keys in env: #{env.keys.grep(/exception|error/i).join(', ')}" if exception.nil?

      modified_body = inject_button(body, exception, env)
      return [status, headers, body] if modified_body.nil?

      new_body = Array(modified_body)
      headers['Content-Length'] = new_body.sum(&:bytesize).to_s

      [status, headers, new_body]
    end

    private

    def should_inject?(status, headers)
      return false unless configuration.enabled
      return false unless status.to_i >= 400
      return false unless html_content?(headers)

      true
    end

    def html_content?(headers)
      content_type = headers['Content-Type']
      return false unless content_type

      content_type.include?('text/html')
    end

    def inject_button(body, exception, env)
      puts '[rails_error_to_clipboard] inject_button called'

      body_content = read_body(body)
      return nil if body_content.nil?

      puts "[rails_error_to_clipboard] Body content length: #{body_content.length}"

      return nil if exception.nil?

      puts "[rails_error_to_clipboard] Exception: #{exception.class}: #{exception.message}"

      request = env['action_dispatch.request']

      markdown = MarkdownFormatter.new(exception, request).format
      puts "[rails_error_to_clipboard] Markdown length: #{markdown.length}"

      injector = ButtonInjector.new(configuration)
      result = injector.inject(body_content, markdown)
      puts "[rails_error_to_clipboard] Injection result: #{result ? 'success' : 'nil'}"

      result
    end

    def read_body(body)
      strings = []
      body.each { |part| strings << part }
      body.close if body.respond_to?(:close)

      strings.join
    rescue StandardError
      nil
    end

    def configuration
      RailsErrorToClipboard.configuration
    end
  end
end
