# OmniAuth SAML Version History

A generic SAML strategy for OmniAuth.

https://github.com/PracticallyGreen/omniauth-saml


## 1.1.0 (2013-11-07)

* no longer set a default `name_identifier_format`
* pass strategy options to the underlying ruby-saml library
* fallback to omniauth callback url if `assertion_consumer_service_url` is not set
* add `idp_sso_target_url_runtime_params` option

## 1.0.0 (2012-11-12)

* remove SAML code and port to ruby-saml gem
* fix incompatibility with OmniAuth 1.1

## 0.9.2 (2012-03-30)

* validate the SAML response
* 100% test coverage
* now requires ruby 1.9.2+

## 0.9.1 (2012-02-23)

* return first and last name in the info hash
* no longer use LDAP OIDs for name and email selection
* return SAML attributes as the omniauth raw_info hash

## 0.9.0 (2012-02-14)

* initial release
* extracts commits from omniauth 0-3-stable branch
* port to omniauth 1.0 strategy format
* update README with more documentation and license
* package as the `omniauth-saml` gem
