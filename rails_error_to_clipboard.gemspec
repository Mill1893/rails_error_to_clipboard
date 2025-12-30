# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'rails_error_to_clipboard'
  spec.version = '0.1.0'
  spec.authors = ['Andrew Miller']
  spec.email = ['andrew@example.com']
  spec.summary = "Add 'Copy for AI' button to Rails error pages"
  spec.description = 'Formats error details into structured Markdown for easy copy to AI assistants'
  spec.homepage = 'https://github.com/andrewmiller/rails_error_to_clipboard'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.files = Dir.glob('{lib,config,app}/**/*') + %w[LICENSE README.md]

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
end
