require File.expand_path('../lib/omniauth-saml/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "omniauth-saml"
  gem.version       = OmniAuth::SAML::VERSION
  gem.summary       = %q{A generic SAML strategy for OmniAuth.}
  gem.description   = %q{A generic SAML strategy for OmniAuth.}

  gem.authors       = ["Raecoo Cao", "Ryan Wilcox", "Rajiv Aaron Manglani", "Steven Anderson"]
  gem.email         = "rajiv@alum.mit.edu"
  gem.homepage      = "https://github.com/PracticallyGreen/omniauth-saml"

  gem.add_runtime_dependency 'omniauth', '~> 1.0'
  gem.add_runtime_dependency 'xmlcanonicalizer', '0.1.1'
  gem.add_runtime_dependency 'uuid', '~> 2.3'

  gem.add_development_dependency 'guard', '1.0.1'
  gem.add_development_dependency 'guard-rspec', '0.6.0'
  gem.add_development_dependency 'rspec', '2.8'
  gem.add_development_dependency 'simplecov', '0.6.1'
  gem.add_development_dependency 'rack-test', '0.6.1'

  gem.files         = ['README.md'] + Dir['lib/**/*.rb']
  gem.test_files    = Dir['spec/**/*.rb']
  gem.require_paths = ["lib"]
end
