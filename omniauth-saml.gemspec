require File.expand_path('../lib/omniauth-saml/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-saml'
  gem.version       = OmniAuth::SAML::VERSION
  gem.summary       = 'A generic SAML strategy for OmniAuth.'
  gem.description   = 'A generic SAML strategy for OmniAuth.'
  gem.license       = 'MIT'

  gem.authors       = ['Raecoo Cao', 'Ryan Wilcox', 'Rajiv Aaron Manglani', 'Steven Anderson', 'Nikos Dimitrakopoulos', 'Rudolf Vriend']
  gem.email         = 'rajiv@alum.mit.edu'
  gem.homepage      = 'https://github.com/PracticallyGreen/omniauth-saml'

  gem.add_runtime_dependency 'omniauth', '~> 1.2'
  gem.add_runtime_dependency 'ruby-saml', '~> 0.8.1'

  gem.add_development_dependency 'rspec', '~> 2.8'
  gem.add_development_dependency 'simplecov', '~> 0.6'
  gem.add_development_dependency 'rack-test', '~> 0.6'

  gem.files         = ['README.md', 'CHANGELOG.md'] + Dir['lib/**/*.rb']
  gem.test_files    = Dir['spec/**/*.rb']
  gem.require_paths = ["lib"]
end
