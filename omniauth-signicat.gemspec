require File.expand_path('../lib/omniauth-signicat/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-signicat'
  gem.version       = OmniAuth::Signicat::VERSION
  gem.summary       = 'Signicat strategy for OmniAuth.'
  gem.description   = 'Signicat strategy for OmniAuth.'
  gem.license       = 'MIT'

  gem.authors       = [
    'Theodor Tonum',
    'Raecoo Cao',
    'Ryan Wilcox',
    'Rajiv Aaron Manglani',
    'Steven Anderson',
    'Nikos Dimitrakopoulos',
    'Rudolf Vriend',
    'Bruno Pedro'
  ]
  gem.email         = 'theodor@nabobil.no'
  gem.homepage      = 'https://github.com/Nabobil/omniauth-signicat'

  gem.add_runtime_dependency 'omniauth', '~> 1.3'
  gem.add_runtime_dependency 'nokogiri', '~> 1.5.1'

  gem.add_development_dependency 'rspec', '~>3.4'
  gem.add_development_dependency 'simplecov', '~> 0.11'
  gem.add_development_dependency 'rack-test', '~> 0.6', '>= 0.6.3'

  gem.files = [
    'README.md',
    'CHANGELOG.md',
    'LICENSE.md'
  ] + Dir['lib/**/*.rb']
  gem.test_files = Dir['spec/**/*.rb']
  gem.require_paths = ['lib']
end
