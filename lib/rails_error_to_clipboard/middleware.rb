# frozen_string_literal: true

module RailsErrorToClipboard
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      return [status, headers, body] unless should_inject?(status, headers)

      exception = env['action_dispatch.exception'] || env['rack.exception']
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
      return true if content_type.nil? || content_type.empty?

      content_type.include?('text/html')
    end

    def inject_button(body, exception, env)
      body_content = read_body(body)
      return nil if body_content.nil?

      warn "[rails_error_to_clipboard] Body has </body>: #{body_content.include?('</body>')}"
      warn "[rails_error_to_clipboard] Body has </html>: #{body_content.include?('</html>')}"

      unless exception
        exception = create_synthetic_exception(@app.call(env).first, env)
        return nil unless exception
      end

      request = env['action_dispatch.request']
      markdown = MarkdownFormatter.new(exception, request).format
      injector = ButtonInjector.new(configuration)
      result = injector.inject(body_content, markdown)

      warn "[rails_error_to_clipboard] Injection result: #{result ? 'success' : 'nil'}"

      result
    end

    def create_synthetic_exception(status_code, env)
      case status_code.to_i
      when 404
        path = env['PATH_INFO']
        ActionController::RoutingError.new("No route matches #{env['REQUEST_METHOD']} \"#{path}\"")
      when 500
        RuntimeError.new('Internal server error')
      end
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
