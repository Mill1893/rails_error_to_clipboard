# frozen_string_literal: true

module RailsErrorToClipboard
  class Railtie < Rails::Railtie
    config.before_configuration do
      RailsErrorToClipboard.configure {}
    end

    class ExceptionWrapper
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env)
      rescue StandardError => e
        status = e.respond_to?(:status) ? e.status : 500
        status = 500 unless status.to_i.between?(400, 599)

        request = ActionDispatch::Request.new(env)
        body = render_exception_page(e, request, status)

        headers = {
          'Content-Type' => 'text/html; charset=utf-8',
          'Content-Length' => body.bytesize.to_s
        }

        [status, headers, [body]]
      end

      private

      def render_exception_page(exception, request, status)
        html = <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <title>#{status} - Error</title>
            <style>
              body { font-family: system-ui, sans-serif; padding: 2rem; }
              h1 { color: #dc2626; }
              pre { background: #f5f5f5; padding: 1rem; overflow-x: auto; }
            </style>
          </head>
          <body>
            <h1>#{exception.class}: #{exception.message}</h1>
            <pre>#{exception.backtrace.first(20).join("\n")}</pre>
          </body>
          </html>
        HTML

        markdown = MarkdownFormatter.new(exception, request).format
        ButtonInjector.new(RailsErrorToClipboard.configuration).inject(html, markdown)
      end
    end

    config.app_middleware.use ExceptionWrapper
  end
end
