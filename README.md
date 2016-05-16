# OmniAuth Signicat

[![Gem Version](http://img.shields.io/gem/v/omniauth-signicat.svg)][gem]
[![Build Status](https://img.shields.io/codeship/10a7cb50-af95-0132-a853-0e5ba92aabbb.svg)][codeship]
[![Dependency Status](http://img.shields.io/gemnasium/Nabobil/omniauth-signicat.svg)][gemnasium]
[![Coverage Status](http://img.shields.io/coveralls/Nabobil/omniauth-signicat.svg)][coveralls]

[gem]: https://rubygems.org/gems/omniauth-signicat
[codeship]: https://codeship.com/projects/152234
[gemnasium]: https://gemnasium.com/github.com/Nabobil/omniauth-signicat
[coveralls]: https://coveralls.io/github/Nabobil/omniauth-signicat

Signicat strategy for OmniAuth available under the [MIT License](LICENSE.md)

https://github.com/Nabobil/omniauth-signicat

## Requirements

* [OmniAuth](http://www.omniauth.org/) 1.3+
* Ruby 1.9.x or Ruby 2.1.x+

## Versioning

We tag and release gems according to the [Semantic Versioning](http://semver.org/) principle.

## Usage

Use the Signicat strategy as a middleware in your application:

```ruby
require 'omniauth'
use OmniAuth::Strategies::Signicat,
  :env      => 'preprod',
  :service  => 'demo',
  :method   => 'nbid',
  :language => 'nb'
```

or in your Rails application:

in `Gemfile`:

```ruby
gem 'omniauth-signicat'
```

and in `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :signicat,
    :env      => 'preprod',
    :service  => 'demo',
    :method   => 'nbid',
    :language => 'nb'
end
```

## Options

* `:env` - `preprod` or `id`. **Required**.

* `:service` - The name of your service as registered with Signicat. There is a
  demo preprod service called `demo` which you may use as you'd like, but eventually
  you will start using your own service. **Required**.

* `:method` - The name of the id-method as registered with Signicat. Common
  abbreviations are `nbid` for Norwegian BankID, `sbid` for Swedish BankID,
  `nemid` for Danish NemID, `tupas` for Finnish Tupas, `esteid` for Estonian
  ID-card and so on. **Required**.

* `:language` - Two letter code (ISO 639-1) for the language you would like in
  the user interface, such as `nb` for Norwegian, `da` for Danish, `sv` for
  Swedish, `fi` for Finnish, `et` for Estonian and so on. **Required**.

* `:profile` - The name of the graphical profile you would like to use. If you
  don't have a graphical profile, you can omit the value and the default profile
  will be used. Optional.

## Devise Integration

Straightforward integration with [Devise](https://github.com/plataformatec/devise), the widely-used authentication solution for Rails.

In `config/initializers/devise.rb`:

```ruby
Devise.setup do |config|
  config.omniauth :signicat,
    :env      => 'preprod',
    :service  => 'demo',
    :method   => 'nbid',
    :language => 'nb'
end
```

Then follow Devise's general [OmniAuth tutorial](https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview), replacing references to `facebook` with `signicat`.

## Authors

Authored by [Theodor Tonum](https://github.com/theodorton) at [Nabobil](https://nabobil.no).

Original `omniauth-saml` project authored by [Rajiv Aaron Manglani](http://www.rajivmanglani.com/), Raecoo Cao, Todd W Saxton, Ryan Wilcox, Steven Anderson, Nikos Dimitrakopoulos, Rudolf Vriend and [Bruno Pedro](http://brunopedro.com/).
