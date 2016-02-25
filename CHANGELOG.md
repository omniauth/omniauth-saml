# OmniAuth SAML Version History

A generic SAML strategy for OmniAuth.

https://github.com/omniauth/omniauth-saml

## 1.5.0 (2016-02-25)

* Initialize OneLogin::RubySaml::Response instance with settings
* Adding "settings" to Response Class at initialization to handle signing verification
* Support custom attributes
* change URL from PracticallyGreen to omniauth
* Add specs for ACS fallback URL behavior
* Call validation earlier to get real error instead of 'response missing name_id'
* Avoid mutation of the options hash during requests and callbacks

## 1.4.2 (2016-02-09)

* update ruby-saml to 1.1

## 1.4.1 (2015-08-09)

* Configurable attribute_consuming_service

## 1.4.0 (2015-07-23)

* update ruby-saml to 1.0.0

## 1.3.1 (2015-02-26)

* Added missing fingerprint key check
* Expose fingerprint on the auth_hash

## 1.3.0 (2015-01-23)

* add `idp_cert_fingerprint_validator` option

## 1.2.0 (2014-03-19)

* provide SP metadata at `/auth/saml/metadata`

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
