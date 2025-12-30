# frozen_string_literal: true

module RailsErrorToClipboard
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      return [status, headers, body] unless should_inject?(status, headers, env)

      modified_body = inject_button(body, env)
      return [status, headers, body] if modified_body.nil?

      new_body = Array(modified_body)
      headers["Content-Length"] = new_body.sum(&:bytesize).to_s

      [status, headers, new_body]
    end

    private

    def should_inject?(status, headers, _env)
      return false unless configuration.enabled
      return false unless status.to_i >= 400
      return false unless html_content?(headers)

      true
    end

    def html_content?(headers)
      content_type = headers["Content-Type"]
      return false unless content_type

      content_type.include?("text/html")
    end

    def inject_button(body, env)
      body_content = read_body(body)
      return nil if body_content.nil?

      exception = env["action_dispatch.exception"]
      request = env["action_dispatch.request"]

      return nil if exception.nil?

      markdown = MarkdownFormatter.new(exception, request).format
      injector = ButtonInjector.new(configuration)
      injector.inject(body_content, markdown)
    end

    def read_body(body)
      strings = []
      body.each { |part| strings << part }
      body.close if body.respond_to?(:close)

      strings.join
    rescue
      nil
    end

    def configuration
      RailsErrorToClipboard.configuration
    end
  end
end
