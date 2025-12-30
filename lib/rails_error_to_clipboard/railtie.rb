# frozen_string_literal: true

module RailsErrorToClipboard
  class Railtie < Rails::Railtie
    console do
      puts '[rails_error_to_clipboard] Gem loaded successfully'
    end

    config.before_configuration do
      RailsErrorToClipboard.configure {}
    end

    config.after_initialize do
      Rails.application.config.exceptions_app = lambda do |env|
        request = ActionDispatch::Request.new(env)
        exception = env['action_dispatch.exception']

        status = case exception
                 when ActionController::RoutingError then 404
                 when ActionController::InvalidAuthenticityToken then 422
                 when ::ActiveRecord::RecordNotFound then 404
                 when ::ActiveRecord::RecordInvalid then 422
                 when StandardError
                   exception.respond_to?(:status) ? exception.status : 500
                 else
                   500
                 end

        status = 500 unless status.to_i.between?(400, 599)

        body = render_exception_page(exception, request, status)

        headers = {
          'Content-Type' => 'text/html; charset=utf-8',
          'Content-Length' => body.bytesize.to_s
        }

        [status, headers, [body]]
      end
    end

    private

    def render_exception_page(exception, request, status)
      html = <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <title>#{status} Error</title>
          <style>
            body { font-family: system-ui, sans-serif; padding: 2rem; max-width: 900px; margin: 0 auto; line-height: 1.6; }
            h1 { color: #dc2626; margin-bottom: 1rem; }
            .error-info { background: #fef2f2; border: 1px solid #fecaca; padding: 1rem; border-radius: 8px; margin-bottom: 1rem; }
            .trace { background: #1f2937; color: #e5e7eb; padding: 1rem; border-radius: 8px; overflow-x: auto; font-size: 12px; font-family: monospace; }
            .trace-line { white-space: pre; }
          </style>
        </head>
        <body>
          <h1>#{exception.class}: #{CGI.escapeHTML(exception.message.to_s)}</h1>
          <div class="error-info">
            <strong>Request:</strong> #{request.request_method} #{request.path}
          </div>
          <h2>Stack Trace</h2>
          <pre class="trace">#{CGI.escapeHTML(exception.backtrace.first(30).join("\n"))}</pre>
        </body>
        </html>
      HTML

      markdown = MarkdownFormatter.new(exception, request).format
      ButtonInjector.new(RailsErrorToClipboard.configuration).inject(html, markdown)
    end
  end
end
