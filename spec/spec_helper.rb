if RUBY_VERSION >= '1.9'
  require 'simplecov'

  if ENV['COVERALLS_REPO_TOKEN']
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

def load_xml(filename=:example_response)
  filename = File.expand_path(File.join('..', 'support', "#{filename.to_s}.xml"), __FILE__)
  Base64.encode64(IO.read(filename))
end
