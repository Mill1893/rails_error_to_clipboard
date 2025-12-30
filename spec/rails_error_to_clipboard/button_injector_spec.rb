# frozen_string_literal: true

RSpec.describe RailsErrorToClipboard::ButtonInjector do
  let(:configuration) { RailsErrorToClipboard::Configuration.new }
  subject(:injector) { described_class.new(configuration) }

  describe "#inject" do
    context "with valid HTML containing body tag" do
      it "injects button before closing body tag" do
        html = "<html><body><p>Error page</p></body></html>"
        markdown = "# Error\n**Message:** test"
        result = injector.inject(html, markdown)

        expect(result).to include("</body>")
        expect(result).to include("<script>")
        expect(result).to include("navigator.clipboard.writeText")
      end

      it "preserves original HTML content" do
        html = "<html><body><p>Error page content</p></body></html>"
        markdown = "# Error"
        result = injector.inject(html, markdown)

        expect(result).to include("Error page content")
      end
    end

    context "with HTML without body tag" do
      it "returns original HTML unchanged" do
        html = "<html><div>No body tag</div></html>"
        markdown = "# Error"
        result = injector.inject(html, markdown)

        expect(result).to eq(html)
      end
    end

    context "with nil HTML" do
      it "returns nil unchanged" do
        result = injector.inject(nil, "# Error")
        expect(result).to be_nil
      end
    end

    context "button configuration" do
      it "uses configured button text" do
        configuration.button_text = "Copy Error Details"
        html = "<html><body></body></html>"
        markdown = "# Error"
        result = injector.inject(html, markdown)

        expect(result).to include("Copy Error Details")
      end

      it "uses configured button class" do
        configuration.button_css_class = "my-custom-button"
        html = "<html><body></body></html>"
        markdown = "# Error"
        result = injector.inject(html, markdown)

        expect(result).to include("className = 'my-custom-button'")
      end
    end

    context "script content" do
      it "includes clipboard writeText call" do
        html = "<html><body></body></html>"
        markdown = "# Error message"
        result = injector.inject(html, markdown)

        expect(result).to include("navigator.clipboard.writeText")
      end

      it "escapes markdown content in script" do
        html = "<html><body></body></html>"
        markdown = 'Error with `backtick` and "quotes"'
        result = injector.inject(html, markdown)

        expect(result).to include('\\`backtick\\`')
        expect(result).to include('"quotes"')
      end

      it "includes success feedback" do
        html = "<html><body></body></html>"
        markdown = "# Error"
        result = injector.inject(html, markdown)

        expect(result).to include("Copied!")
        expect(result).to include("setTimeout")
      end

      it "includes error handling" do
        html = "<html><body></body></html>"
        markdown = "# Error"
        result = injector.inject(html, markdown)

        expect(result).to include("console.error")
      end
    end
  end
end
