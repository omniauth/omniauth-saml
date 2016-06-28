if RUBY_VERSION >= '1.9'
  require 'simplecov'

  if ENV['TRAVIS']
    require 'coveralls'
    Coveralls.wear!
  end

  SimpleCov.start
end

require 'omniauth-saml'
require 'rack/test'
require 'rexml/document'
require 'rexml/xpath'
require 'base64'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def example_file(filename=:example_response)
  File.expand_path(File.join('..', 'support', "#{filename.to_s}.xml"), __FILE__)
end

def load_file(filename=:example_response)
  IO.read(example_file(filename))
end

def load_xml(filename=:example_response)
  Base64.encode64(load_file(filename))
end
