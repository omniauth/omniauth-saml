<a name="v2.2.3"></a>
### v2.2.3 (2025-03-12)


#### Features

* new release 2.2.3	 ([34eb354](/../../commit/34eb354))


#### Bug Fixes

* bump ruby-saml to 1.18	 ([7a348b4](/../../commit/7a348b4))


<a name="v2.2.2"></a>
### v2.2.2 (2025-03-04)


#### Features

* log errors on failed logout	 ([23ef364](/../../commit/23ef364))


<a name="v2.2.1"></a>
### v2.2.1 (2024-09-11)

* Fix permission file permissions within published gem (#226)

<a name="v2.2.0"></a>
### v2.2.0 (2024-09-10)

This release fixes:

* [GHSA-jw9c-mfg7-9rx2](https://github.com/SAML-Toolkits/ruby-saml/security/advisories/GHSA-jw9c-mfg7-9rx2)
* [GHSA-cvp8-5r8g-fhvq](https://github.com/omniauth/omniauth-saml/security/advisories/GHSA-cvp8-5r8g-fhvq)

#### Chores

* use semantic versioning for ruby-saml as per gem build hints ([e17f460](/../../commit/e17f460))

<a name="v2.1.1"></a>
### v2.1.1 (2024-09-10)

#### Chores

* Add Ruby 3.1 to the CI matrix ([8954310](/../../commit/8954310))
* Add Ruby 3.2 to CI matrix ([9403366](/../../commit/9403366))
* Fix copy-pasteability of code example ([3eb8942](/../../commit/3eb8942))
* bump dependencies and remove ruby eol versions  ([c6fc2db](/../../commit/c6fc2db))
* Remove old maintainer email from gemspec ([9f6daa](/../../commit/9f6daa))

<a name="v2.1.0"></a>
### v2.1.0 (2022-03-01)


#### Refactor

* Rename usage of deprecated SAML options  ([74ed8df](/../../commit/74ed8df))

#### Chores

* bump ruby-saml to 1.12  ([15c156a](/../../commit/15c156a))

<a name="v2.0.0"></a>
### v2.0.0 (2021-01-13)


#### Chores

* Allow OmniAuth 2.0.0	 ([f7ec7ee](/../../commit/f7ec7ee))


<a name="v1.10.3"></a>
### v1.10.3 (2020-10-06)


#### Bug Fixes

* add options to logout_request initialization	 ([c271a37](/../../commit/c271a37))


<a name="v1.10.2"></a>
### v1.10.2 (2018-05-23)


#### Features

* **saml**
  * inherits allows response options from ruby-saml instead of whitelist	 ([a0eedd6](/../../commit/a0eedd6))


<a name="v1.10.1"></a>
### v1.10.1 (2018-06-07)


#### Features

* **saml-response**
  * whitelist more response options	 ([575198d](/../../commit/575198d))


<a name="v1.10.0"></a>
### v1.10.0 (2018-02-19)


#### Bug Fixes

* ambiguous path match in other phase	 ([1b465b9](/../../commit/1b465b9))
* Update ruby-saml gem to 1.7 or later to fix CVE-2017-11430 ([6bc28ad](/../../commit/6bc28ad))


<a name="v1.9.0"></a>
### v1.9.0 (2018-01-29)


#### Bug Fixes

* Update omniauth gem to 1.3.2 or later 1.3.x	 ([b6bb425](/../../commit/b6bb425))


<a name="v1.8.1"></a>
### v1.8.1 (2017-06-22)


#### Bug Fixes

* default assertion_consumer_service_url not set during callback	 ([4a2a5ef](/../../commit/4a2a5ef))


<a name="v1.8.0"></a>
### v1.8.0 (2017-06-07)


#### Features

* include SessionIndex in logout requests	 ([fb6ad86](/../../commit/fb6ad86))
* Support for configurable IdP SLO session destruction	 ([586bf89](/../../commit/586bf89))
* Add `uid_attribute` option to control the attribute used for the user id.	 ([eacc536](/../../commit/eacc536))


<a name="v1.7.0"></a>
### v1.7.0 (2016-10-19)

#### Features

* Support for Single Logout	 ([cd3fc43](/../../commit/cd3fc43))
* Add issuer information to the metadata endpoint, to allow IdPs to properly configure themselves.	 ([7bbbb67](/../../commit/7bbbb67))
* Added the response object to the extra['response_object'], so we can use the raw response object if we want to.	 ([76ed3d6](/../../commit/76ed3d6))

#### Chores

* Update `ruby-saml` to 1.4.0 to address security fixes. ([638212](/../../commit/638212))

<a name="v1.6.0"></a>
### v1.6.0 (2016-06-27)
* Ensure that subclasses of `OmniAuth::Stategies::SAML` are registered with OmniAuth as strategies (https://github.com/omniauth/omniauth-saml/pull/95)
* Update ruby-saml to 1.3 to address [CVE-2016-5697](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-5697) (Signature wrapping attacks)

<a name="v1.5.0"></a>
### v1.5.0 (2016-02-25)

* Initialize OneLogin::RubySaml::Response instance with settings
* Adding "settings" to Response Class at initialization to handle signing verification
* Support custom attributes
* change URL from PracticallyGreen to omniauth
* Add specs for ACS fallback URL behavior
* Call validation earlier to get real error instead of 'response missing name_id'
* Avoid mutation of the options hash during requests and callbacks

<a name="v1.4.2"></a>
### v1.4.2 (2016-02-09)

* update ruby-saml to 1.1

<a name="v1.4.1"></a>
### v1.4.1 (2015-08-09)

* Configurable attribute_consuming_service

<a name="v1.4.0"></a>
### v1.4.0 (2015-07-23)

* update ruby-saml to 1.0.0

<a name="v1.3.1"></a>
### v1.3.1 (2015-02-26)

* Added missing fingerprint key check
* Expose fingerprint on the auth_hash

<a name="v1.3.0"></a>
### v1.3.0 (2015-01-23)

* add `idp_cert_fingerprint_validator` option

<a name="v1.2.0"></a>
### v1.2.0 (2014-03-19)

* provide SP metadata at `/auth/saml/metadata`

<a name="v1.1.0"></a>
### v1.1.0 (2013-11-07)

* no longer set a default `name_identifier_format`
* pass strategy options to the underlying ruby-saml library
* fallback to omniauth callback url if `assertion_consumer_service_url` is not set
* add `idp_sso_target_url_runtime_params` option

<a name="v1.0.0"></a>
### v1.0.0 (2012-11-12)

* remove SAML code and port to ruby-saml gem
* fix incompatibility with OmniAuth 1.1

<a name="v0.9.2"></a>
### v0.9.2 (2012-03-30)

* validate the SAML response
* 100% test coverage
* now requires ruby 1.9.2+

<a name="v0.9.1"></a>
### v0.9.1 (2012-02-23)

* return first and last name in the info hash
* no longer use LDAP OIDs for name and email selection
* return SAML attributes as the omniauth raw_info hash

<a name="v0.9.0"></a>
### v0.9.0 (2012-02-14)

* initial release
* extracts commits from omniauth 0-3-stable branch
* port to omniauth 1.0 strategy format
* update README with more documentation and license
* package as the `omniauth-saml` gem
