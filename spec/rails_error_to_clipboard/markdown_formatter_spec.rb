# frozen_string_literal: true

RSpec.describe RailsErrorToClipboard::MarkdownFormatter do
  let(:exception) { StandardError.new('test error message') }
  let(:request) do
    double('request', request_method: 'GET', path: '/test/path',
                      params: { controller: 'test', action: 'index', id: '123' })
  end

  describe '#format' do
    context 'with exception and request' do
      subject(:formatted) { described_class.new(exception, request).format }

      it 'includes error type' do
        expect(formatted).to include('**Type:** `StandardError`')
      end

      it 'includes error message' do
        expect(formatted).to include('**Message:** test error message')
      end

      it 'includes request method' do
        expect(formatted).to include('**Method:** GET')
      end

      it 'includes request path' do
        expect(formatted).to include('**Path:** /test/path')
      end

      it 'includes request params' do
        expect(formatted).to include('**Params:**')
      end

      it 'includes backtrace section' do
        expect(formatted).to include('## Backtrace')
      end

      it 'formats as code block' do
        expect(formatted).to include('```')
      end
    end

    context 'without request' do
      subject(:formatted) { described_class.new(exception).format }

      it 'shows N/A for request details' do
        expect(formatted).to include('**Method:** N/A')
        expect(formatted).to include('**Path:** N/A')
        expect(formatted).to include('**Params:** N/A')
      end
    end

    context 'with empty params' do
      let(:request) do
        double('request', request_method: 'GET', path: '/test', params: { controller: 'test', action: 'index' })
      end

      it 'shows empty params as empty hash' do
        formatted = described_class.new(exception, request).format
        expect(formatted).to include('**Params:** {}')
      end
    end

    context 'with backtrace' do
      it 'includes backtrace lines' do
        exception.set_backtrace(['/app/file1.rb:10', '/app/file2.rb:20'])
        formatted = described_class.new(exception).format
        expect(formatted).to include('/app/file1.rb:10')
        expect(formatted).to include('/app/file2.rb:20')
      end

      it 'limits backtrace to 20 lines' do
        long_backtrace = (1..30).map { |i| "/app/file#{i}.rb:#{i * 10}" }
        exception.set_backtrace(long_backtrace)
        formatted = described_class.new(exception).format
        lines = formatted.lines.select { |l| l.include?('/app/file') }
        expect(lines.length).to be <= 20
      end
    end

    context 'markdown escaping' do
      it 'escapes backticks in message' do
        exception = StandardError.new('Error with `code` here')
        formatted = described_class.new(exception).format
        expect(formatted).to include('\\`code\\`')
      end

      it 'escapes asterisks in message' do
        exception = StandardError.new('Error with *asterisks*')
        formatted = described_class.new(exception).format
        expect(formatted).to include('\\*asterisks\\*')
      end
    end
  end
end
