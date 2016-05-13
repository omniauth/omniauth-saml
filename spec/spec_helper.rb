if RUBY_VERSION >= '1.9'
  require 'simplecov'

  if ENV['CI']
    require 'coveralls'
    Coveralls.wear!
  end

  SimpleCov.start
end

require 'omniauth-signicat'
require 'rack/test'
require 'rexml/document'
require 'rexml/xpath'
require 'base64'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end

def load_xml(filename = :example_response)
  filename = File.expand_path(File.join('..', 'support', "#{filename}.xml"), __FILE__)
  Base64.encode64(IO.read(filename))
end
