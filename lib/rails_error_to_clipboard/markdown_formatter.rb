# frozen_string_literal: true

module RailsErrorToClipboard
  class MarkdownFormatter
    def initialize(exception, request = nil)
      @exception = exception
      @request = request
    end

    def format
      <<~MARKDOWN.chomp
        # Error

        **Type:** `#{exception_class}`
        **Message:** #{escape_markdown(exception_message)}

        ## Request

        - **Method:** #{request_method}
        - **Path:** #{request_path}
        #{request_params}

        ## Backtrace

        ```
        #{formatted_backtrace}
        ```
      MARKDOWN
    end

    private

    def exception_class
      @exception.class.name
    end

    def exception_message
      @exception.message
    end

    def request_method
      return 'N/A' unless @request

      @request.request_method
    end

    def request_path
      return 'N/A' unless @request

      @request.path
    end

    def request_params
      return '- **Params:** N/A' unless @request

      params = @request.params.reject { |k, _| %w[controller action].include?(k) }
      if params.empty?
        '- **Params:** {}'
      else
        "- **Params:** #{escape_markdown(params.inspect)}"
      end
    end

    def formatted_backtrace
      return 'No backtrace available' unless @exception.backtrace

      @exception.backtrace.first(20).map { |line| "  #{line}" }.join("\n")
    end

    def escape_markdown(text)
      text.to_s.gsub(/`/, '\\`').gsub(/\*/, '\\*').gsub(/_/, '\\_')
    end
  end
end
