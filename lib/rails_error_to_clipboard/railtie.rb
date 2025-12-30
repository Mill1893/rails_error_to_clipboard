# frozen_string_literal: true

puts '[rails_error_to_clipboard] Loading railtie...'

module RailsErrorToClipboard
  class Railtie < Rails::Railtie
    puts '[rails_error_to_clipboard] Railtie class defined'

    config.before_configuration do
      puts '[rails_error_to_clipboard] before_configuration'
      RailsErrorToClipboard.configure {}
    end

    class ExceptionWrapper
      puts '[rails_error_to_clipboard] ExceptionWrapper class defined'

      def initialize(app)
        @app = app
        puts '[rails_error_to_clipboard] ExceptionWrapper initialized'
      end

      def call(env)
        puts "[rails_error_to_clipboard] ExceptionWrapper#call invoked for #{env['PATH_INFO']}"
        result = @app.call(env)
        puts '[rails_error_to_clipboard] @app.call returned normally'
        result
      rescue StandardError => e
        puts "[rails_error_to_clipboard] Caught exception: #{e.class}: #{e.message}"
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
            <title>#{status} Error</title>
            <style>
              body { font-family: system-ui, sans-serif; padding: 2rem; max-width: 800px; margin: 0 auto; }
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

    puts '[rails_error_to_clipboard] Adding ExceptionWrapper to middleware stack'
    config.app_middleware.insert_before(ActionDispatch::ShowExceptions, ExceptionWrapper)
  end
end

puts '[rails_error_to_clipboard] Railtie loading complete'
