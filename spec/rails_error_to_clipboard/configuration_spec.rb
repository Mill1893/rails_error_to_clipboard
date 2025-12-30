# frozen_string_literal: true

RSpec.describe RailsErrorToClipboard::Configuration do
  describe 'initialization' do
    it 'has default enabled value of true' do
      config = described_class.new
      expect(config.enabled).to be true
    end

    it 'has default button text' do
      config = described_class.new
      expect(config.button_text).to eq('Copy for AI')
    end

    it 'has default button css class' do
      config = described_class.new
      expect(config.button_css_class).to eq('rails-error-to-clipboard-button')
    end

    it 'has default position' do
      config = described_class.new
      expect(config.position).to eq('bottom-right')
    end
  end

  describe 'attributes' do
    it 'allows updating enabled' do
      config = described_class.new
      config.enabled = false
      expect(config.enabled).to be false
    end

    it 'allows updating button_text' do
      config = described_class.new
      config.button_text = 'Copy Error'
      expect(config.button_text).to eq('Copy Error')
    end

    it 'allows updating button_css_class' do
      config = described_class.new
      config.button_css_class = 'custom-class'
      expect(config.button_css_class).to eq('custom-class')
    end

    it 'allows updating position' do
      config = described_class.new
      config.position = 'top-left'
      expect(config.position).to eq('top-left')
    end
  end

  describe '.default' do
    it 'returns a new Configuration instance' do
      config = described_class.default
      expect(config).to be_a(described_class)
      expect(config.enabled).to be true
    end
  end
end
