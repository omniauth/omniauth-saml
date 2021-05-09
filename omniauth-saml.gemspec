require File.expand_path('../lib/omniauth-saml/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-saml'
  gem.version       = OmniAuth::SAML::VERSION
  gem.summary       = 'A generic SAML strategy for OmniAuth.'
  gem.description   = 'A generic SAML strategy for OmniAuth.'
  gem.license       = 'MIT'

  gem.authors       = ['Raecoo Cao', 'Ryan Wilcox', 'Rajiv Aaron Manglani', 'Steven Anderson', 'Nikos Dimitrakopoulos', 'Rudolf Vriend', 'Bruno Pedro']
  gem.email         = 'rajiv@alum.mit.edu'
  gem.homepage      = 'https://github.com/omniauth/omniauth-saml'

  gem.required_ruby_version = '>= 2.4'

  gem.add_runtime_dependency 'omniauth', '~> 2.0'
  gem.add_runtime_dependency 'ruby-saml', '~> 1.12'

  gem.add_development_dependency 'rake', '>= 12.3.3'
  gem.add_development_dependency 'rspec', '~>3.4'
  gem.add_development_dependency 'simplecov', '~> 0.11'
  gem.add_development_dependency 'rack-test', '~> 0.6', '>= 0.6.3'
  gem.add_development_dependency 'conventional-changelog', '~> 1.2'
  gem.add_development_dependency 'coveralls', '>= 0.8.23'

  gem.files         = ['README.md', 'CHANGELOG.md', 'LICENSE.md'] + Dir['lib/**/*.rb']
  gem.test_files    = Dir['spec/**/*.rb']
  gem.require_paths = ["lib"]
end
