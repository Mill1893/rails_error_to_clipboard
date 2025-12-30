# frozen_string_literal: true

RSpec.describe RailsErrorToClipboard::Middleware do
  let(:app) { proc { [status, headers, body] } }
  let(:configuration) { RailsErrorToClipboard::Configuration.new }
  let(:exception) { StandardError.new('test error') }

  before do
    allow(RailsErrorToClipboard).to receive(:configuration).and_return(configuration)
  end

  describe '#call' do
    context 'when disabled' do
      let(:status) { 500 }
      let(:headers) { { 'Content-Type' => 'text/html' } }
      let(:body) { ['<html><body>Error</body></html>'] }

      before { configuration.enabled = false }

      it 'does not modify response' do
        result = described_class.new(app).call({})
        expect(result[0]).to eq(500)
        expect(result[1]).to eq(headers)
        expect(result[2]).to eq(body)
      end
    end

    context 'when not HTML content' do
      let(:status) { 500 }
      let(:headers) { { 'Content-Type' => 'text/plain' } }
      let(:body) { ['Error message'] }

      it 'does not modify response' do
        result = described_class.new(app).call({})
        expect(result[0]).to eq(500)
        expect(result[1]).to eq(headers)
      end
    end

    context 'when status is success' do
      let(:status) { 200 }
      let(:headers) { { 'Content-Type' => 'text/html' } }
      let(:body) { ['<html><body>OK</body></html>'] }

      it 'does not modify response' do
        result = described_class.new(app).call({})
        expect(result[0]).to eq(200)
      end
    end

    context 'when status is error (4xx/5xx)' do
      let(:headers) { { 'Content-Type' => 'text/html' } }
      let(:body) { ['<html><body>Error</body></html>'] }

      context 'with 500 status' do
        let(:status) { 500 }

        it 'processes the response' do
          env = {
            'action_dispatch.exception' => exception,
            'action_dispatch.request' => nil
          }
          result = described_class.new(app).call(env)

          expect(result[0]).to eq(500)
          expect(result[2].join).to include('<script>')
        end
      end

      context 'with 404 status' do
        let(:status) { 404 }
        let(:body) { ['<html><body>Not Found</body></html>'] }

        it 'does not inject button for 404' do
          env = { 'action_dispatch.exception' => nil }
          result = described_class.new(app).call(env)

          expect(result[2].join).not_to include('<script>')
        end
      end
    end

    context 'with request information' do
      let(:status) { 500 }
      let(:headers) { { 'Content-Type' => 'text/html' } }
      let(:body) { ['<html><body>Error</body></html>'] }

      let(:request) do
        double('request', request_method: 'POST', path: '/users', params: { user: { name: 'test' } })
      end

      it 'includes request details in markdown' do
        env = {
          'action_dispatch.exception' => exception,
          'action_dispatch.request' => request
        }
        result = described_class.new(app).call(env)

        markdown = result[2].join
        expect(markdown).to include('POST')
        expect(markdown).to include('/users')
      end
    end
  end
end
