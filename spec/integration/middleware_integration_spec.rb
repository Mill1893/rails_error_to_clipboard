# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RailsErrorToClipboard::Middleware do
  let(:headers) { { 'Content-Type' => 'text/html' } }

  def env_with_exception
    rack_env.tap do |env|
      env['action_dispatch.exception'] = StandardError.new('Test error')
      env['action_dispatch.request'] = double(request_method: 'GET', path: '/test', params: {})
    end
  end

  def valid_env
    rack_env
  end

  def rack_env
    {
      'REQUEST_METHOD' => 'GET',
      'PATH_INFO' => '/test',
      'rack.input' => StringIO.new('')
    }
  end

  around do |example|
    RailsErrorToClipboard.reset_configuration
    example.run
    RailsErrorToClipboard.reset_configuration
  end

  describe 'when enabled' do
    before do
      RailsErrorToClipboard.configure do |config|
        config.enabled = true
      end
    end

    it 'injects button into 500 error pages' do
      app = ->(_) { [500, headers, ['<html><body>Internal Server Error</body></html>']] }
      middleware = described_class.new(app)
      status, _, body = middleware.call(env_with_exception)
      expect(status).to eq(500)
      expect(body.join).to include('Copy for AI')
    end

    it 'passes through non-error responses' do
      app = ->(_) { [200, headers, ['OK']] }
      middleware = described_class.new(app)
      status, _, body = middleware.call(valid_env)
      expect(status).to eq(200)
      expect(body.join).to eq('OK')
    end

    it 'does not inject button for non-HTML responses' do
      app_with_json = ->(_) { [500, { 'Content-Type' => 'application/json' }, ['{"error": "test"}']] }
      middleware_with_json = described_class.new(app_with_json)
      status, _, body = middleware_with_json.call(env_with_exception)
      expect(status).to eq(500)
      expect(body.join).to_not include('Copy for AI')
    end
  end

  describe 'when disabled' do
    before do
      RailsErrorToClipboard.configure do |config|
        config.enabled = false
      end
    end

    it 'does not inject button' do
      app = ->(_) { [500, headers, ['<html><body>Internal Server Error</body></html>']] }
      middleware = described_class.new(app)
      status, _, body = middleware.call(env_with_exception)
      expect(status).to eq(500)
      expect(body.join).to_not include('Copy for AI')
    end

    it 'passes through non-error responses' do
      app = ->(_) { [200, headers, ['OK']] }
      middleware = described_class.new(app)
      status, _, body = middleware.call(valid_env)
      expect(status).to eq(200)
      expect(body.join).to eq('OK')
    end
  end

  describe 'error status handling' do
    before do
      RailsErrorToClipboard.configure do |config|
        config.enabled = true
      end
    end

    it 'injects button for 400 status codes' do
      app_400 = ->(_) { [400, headers, ['<html><body>Bad Request</body></html>']] }
      middleware_400 = described_class.new(app_400)
      status, _, body = middleware_400.call(env_with_exception)
      expect(status).to eq(400)
      expect(body.join).to include('Copy for AI')
    end

    it 'injects button for 404 status codes' do
      app_404 = ->(_) { [404, headers, ['<html><body>Not Found</body></html>']] }
      middleware_404 = described_class.new(app_404)
      env_404 = rack_env.tap do |env|
        env['action_dispatch.exception'] = StandardError.new('Not found')
        env['action_dispatch.request'] = double(request_method: 'GET', path: '/missing', params: {})
      end
      status, _, body = middleware_404.call(env_404)
      expect(status).to eq(404)
      expect(body.join).to include('Copy for AI')
    end

    it 'does not inject button for 200 status codes' do
      app_200 = ->(_) { [200, headers, ['<html><body>OK</body></html>']] }
      middleware_200 = described_class.new(app_200)
      status, _, body = middleware_200.call(valid_env)
      expect(status).to eq(200)
      expect(body.join).to eq('<html><body>OK</body></html>')
    end
  end

  describe 'body injection' do
    before do
      RailsErrorToClipboard.configure do |config|
        config.enabled = true
      end
    end

    it 'injects button before closing body tag' do
      app_with_body = ->(_) { [500, headers, ['<html><body>Error page</body></html>']] }
      middleware_with_body = described_class.new(app_with_body)
      _, _, body = middleware_with_body.call(env_with_exception)
      expect(body.join).to include('</body>')
      expect(body.join).to match(%r{Copy for AI.*</body>}m)
    end

    it 'handles bodies without closing body tag' do
      app_no_body = ->(_) { [500, headers, ['<html>No body tag']] }
      middleware_no_body = described_class.new(app_no_body)
      _, _, body = middleware_no_body.call(env_with_exception)
      expect(body.join).to eq('<html>No body tag')
    end

    it 'handles array bodies' do
      app_array_body = ->(_) { [500, headers, ['<html>', '<body>Error', '</body>', '</html>']] }
      middleware_array = described_class.new(app_array_body)
      _, _, body = middleware_array.call(env_with_exception)
      expect(body.join).to include('Copy for AI')
    end
  end
end
