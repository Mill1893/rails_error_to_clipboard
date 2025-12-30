# frozen_string_literal: true

module RailsErrorToClipboard
  class ButtonInjector
    def initialize(configuration)
      @configuration = configuration
    end

    def inject(html, markdown)
      return html if html.nil? || !html.include?("</body>")

      button_html = generate_button_html(markdown)
      html = html.dup
      html.sub!(%r{</body>}i) { "#{button_html}</body>" }

      html
    end

    private

    def generate_button_html(markdown)
      escaped_markdown = escape_js(markdown)
      button_text = escape_html(@configuration.button_text)
      button_class = escape_html(@configuration.button_css_class)

      <<~HTML
        <script>
          (function() {
            var markdown = `#{escaped_markdown}`;
            var button = document.createElement('button');
            button.type = 'button';
            button.className = '#{button_class}';
            button.textContent = '#{button_text}';
            button.style.cssText = 'position:fixed;bottom:20px;right:20px;z-index:9999;padding:10px 16px;background:#2563eb;color:#fff;border:none;border-radius:6px;cursor:pointer;font-family:system-ui,sans-serif;font-size:14px;box-shadow:0 2px 8px rgba(0,0,0,0.15);';
            button.onclick = function() {
              navigator.clipboard.writeText(markdown).then(function() {
                var originalText = button.textContent;
                button.textContent = 'Copied!';
                button.style.background = '#16a34a';
                setTimeout(function() {
                  button.textContent = originalText;
                  button.style.background = '#2563eb';
                }, 2000);
              }).catch(function(err) {
                console.error('Failed to copy:', err);
                button.textContent = 'Error';
              });
            };
            document.body.appendChild(button);
          })();
        </script>
      HTML
    end

    def escape_js(text)
      result = text.dup
      result.gsub!("\\") { "\\\\" }
      result.gsub!("`") { '\\`' }
      result.gsub!("$") { '\\$' }
      result.gsub!("<") { '\\<' }
      result.gsub!(">") { '\\>' }
      result
    end

    def escape_html(text)
      CGI.escapeHTML(text.to_s)
    end
  end
end
