require 'spec_helper'

RSpec::Matchers.define :fail_with do |message|
  match do |actual|
    actual.redirect? && /\?.*message=#{message}/ === actual.location
  end
end

describe OmniAuth::Strategies::SAML, :type => :strategy do
  include OmniAuth::Test::StrategyTestCase

  let(:auth_hash){ last_request.env['omniauth.auth'] }
  let(:saml_options) do
    {
      :assertion_consumer_service_url     => "http://localhost:9080/auth/saml/callback",
      :single_logout_service_url          => "http://localhost:9080/auth/saml/slo",
      :idp_sso_service_url                => "https://idp.sso.example.com/signon/29490",
      :idp_slo_service_url                => "https://idp.sso.example.com/signoff/29490",
      :idp_cert_fingerprint               => "C1:59:74:2B:E8:0C:6C:A9:41:0F:6E:83:F6:D1:52:25:45:58:89:FB",
      :idp_sso_service_url_runtime_params => {:original_param_key => :mapped_param_key},
      :name_identifier_format             => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
      :request_attributes                 => [
        { :name => 'email', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Email address' },
        { :name => 'name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Full name' },
        { :name => 'first_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Given name' },
        { :name => 'last_name', :name_format => 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', :friendly_name => 'Family name' }
      ],
      :attribute_service_name             => 'Required attributes'
    }
  end
  let(:strategy) { [OmniAuth::Strategies::SAML, saml_options] }

  shared_examples 'validating RelayState param' do
    context 'when slo_relay_state_validator is not defined and default' do
      [
        ['/signed-out', '//attacker.test',                            '%2Fsigned-out'],
        ['/signed-out', 'javascript:alert(1)',                        '%2Fsigned-out'],
        ['/signed-out', 'https://example.com/logout',                 '%2Fsigned-out'],
        ['/signed-out', 'https://example.com/logout?param=1&two=two', '%2Fsigned-out'],
        ['/signed-out', '/',                                          '%2F'],
        ['',            '//attacker.test',                            ''],
        ['',            '/team/logout',                               '%2Fteam%2Flogout'],
      ].each do |slo_default_relay_state, relay_state_param, expected_relay_state|
        context "when slo_default_relay_state: #{slo_default_relay_state.inspect}, relay_state_param: #{relay_state_param.inspect}" do
          let(:saml_options) { super().merge(slo_default_relay_state: slo_default_relay_state) }
          let(:params) { super().merge('RelayState' => relay_state_param) }

          it { is_expected.to be_redirect.and have_attributes(location: a_string_including("RelayState=#{expected_relay_state}")) }
        end
      end
    end

    context 'when slo_relay_state_validator is overridden' do
      [
        ['/signed-out', proc { |state| state.start_with?('https://trusted.example.com') }, 'https://trusted.example.com/logout', 'https%3A%2F%2Ftrusted.example.com%2Flogout'],
        ['/signed-out', proc { |state| state.start_with?('https://trusted.example.com') }, 'https://attacker.test/logout',       '%2Fsigned-out'],
        ['/signed-out', proc { |state| state.start_with?('https://trusted.example.com') }, '/safe/path',                         '%2Fsigned-out'],
        ['/signed-out', proc { |state, req| state == req.params['RelayState'] },           '/team/logout',                       '%2Fteam%2Flogout'],
        ['/signed-out', nil,                                                               '//attacker.test',                    '%2Fsigned-out'],
        ['/signed-out', false,                                                             '//attacker.test',                    '%2Fsigned-out'],
        ['/signed-out', proc { |_| false },                                                '//attacker.test',                    '%2Fsigned-out'],
        ['/signed-out', proc { |_| true },                                                 'javascript:alert(1)',                'javascript%3Aalert%281%29'],
        [nil,           true,                                                              'https://example.com/logout',         'https%3A%2F%2Fexample.com%2Flogout'],
        [nil,           true,                                                              'javascript:alert(1)',                'javascript%3Aalert%281%29'],
        [nil,           true,                                                              '/',                                  '%2F'],
      ].each do |slo_default_relay_state, slo_relay_state_validator, relay_state_param, expected_relay_state|
        context "when slo_default_relay_state: #{slo_default_relay_state.inspect}, slo_relay_state_validator: #{slo_relay_state_validator.inspect}, relay_state_param: #{relay_state_param.inspect}" do
          let(:saml_options) do
            super().merge(
              slo_default_relay_state: slo_default_relay_state,
              slo_relay_state_validator: slo_relay_state_validator,
            )
          end
          let(:params) { super().merge('RelayState' => relay_state_param) }

          it { is_expected.to be_redirect.and have_attributes(location: a_string_including("RelayState=#{expected_relay_state}")) }
        end
      end
    end
  end

  describe 'POST /auth/saml' do
    context 'without idp runtime params present' do
      before do
        post '/auth/saml'
      end

      it 'should get authentication page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to match /https:\/\/idp.sso.example.com\/signon\/29490/
        expect(last_response.location).to match /\?SAMLRequest=/
        expect(last_response.location).not_to match /mapped_param_key/
        expect(last_response.location).not_to match /original_param_key/
      end
    end

    context 'with idp runtime params' do
      before do
        post '/auth/saml', 'original_param_key' => 'original_param_value', 'mapped_param_key' => 'mapped_param_value'
      end

      it 'should get authentication page' do
        expect(last_response).to be_redirect
        expect(last_response.location).to match /https:\/\/idp.sso.example.com\/signon\/29490/
        expect(last_response.location).to match /\?SAMLRequest=/
        expect(last_response.location).to match /\&mapped_param_key=original_param_value/
        expect(last_response.location).not_to match /original_param_key/
      end
    end

    context "when the assertion_consumer_service_url is the default" do
      before :each do
        saml_options[:compress_request] = false
        saml_options.delete(:assertion_consumer_service_url)
      end

      it 'should send the current callback_url as the assertion_consumer_service_url' do
        %w(foo.example.com bar.example.com).each do |host|
          post "https://#{host}/auth/saml"

          expect(last_response).to be_redirect

          location = URI.parse(last_response.location)
          query = Rack::Utils.parse_query location.query
          expect(query).to have_key('SAMLRequest')

          request = REXML::Document.new(Base64.decode64(query['SAMLRequest']))
          expect(request.root).not_to be_nil

          acs = request.root.attributes.get_attribute('AssertionConsumerServiceURL')
          expect(acs.to_s).to eq "https://#{host}/auth/saml/callback"
        end
      end
    end

    context 'when authn request signing is requested' do
      subject { post '/auth/saml' }

      let(:private_key) { OpenSSL::PKey::RSA.new 2048 }

      before do
        saml_options[:compress_request] = false

        saml_options[:private_key] = private_key.to_pem
        saml_options[:security] = {
          authn_requests_signed: true,
          signature_method: XMLSecurity::Document::RSA_SHA256
        }
      end

      it 'should sign the request' do
        is_expected.to be_redirect

        location = URI.parse(last_response.location)
        query = Rack::Utils.parse_query location.query
        expect(query).to have_key('SAMLRequest')
        expect(query).to have_key('Signature')
        expect(query).to have_key('SigAlg')

        expect(query['SigAlg']).to eq XMLSecurity::Document::RSA_SHA256
      end
    end
  end

  describe 'POST /auth/saml/callback' do
    let(:xml) { :example_response }
    let(:params) { { 'SAMLResponse' => load_xml(xml) } }

    subject(:post_callback_response) do
      post "/auth/saml/callback", params
    end

    before :each do
      allow(Time).to receive(:now).and_return(Time.utc(2012, 11, 8, 20, 40, 00))
    end

    context "when the response is valid" do
      it "should set the uid to the nameID in the SAML response" do
        post_callback_response

        expect(auth_hash['uid']).to eq '_1f6fcf6be5e13b08b1e3610e7ff59f205fbd814f23'
      end

      it "should set the raw info to all attributes" do
        post_callback_response

        expect(auth_hash['extra']['raw_info'].all.to_hash).to eq(
          'first_name'   => ['Rajiv'],
          'last_name'    => ['Manglani'],
          'email'        => ['user@example.com'],
          'company_name' => ['Example Company'],
          'fingerprint'  => saml_options[:idp_cert_fingerprint]
        )
      end

      it "should set the response_object to the response object from ruby_saml response" do
        post_callback_response

        expect(auth_hash['extra']['response_object']).to be_kind_of(OneLogin::RubySaml::Response)
      end
    end

    context "when the assertion_consumer_service_url is the default" do
      before :each do
        saml_options.delete(:assertion_consumer_service_url)
        OmniAuth.config.full_host = 'http://localhost:9080'
      end

      it { is_expected.not_to fail_with(:invalid_ticket) }
    end

    context "when there is no SAMLResponse parameter" do
      let(:params) { {} }

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when there is no name id in the XML" do
      let(:xml) { :no_name_id }

      before :each do
        allow(Time).to receive(:now).and_return(Time.utc(2012, 11, 8, 23, 55, 00))
      end

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when the fingerprint is invalid" do
      before :each do
        saml_options[:idp_cert_fingerprint] = "00:00:00:00:00:0C:6C:A9:41:0F:6E:83:F6:D1:52:25:45:58:89:FB"
      end

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when the digest is invalid" do
      let(:xml) { :digest_mismatch }

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when the signature is invalid" do
      let(:xml) { :invalid_signature }

      it { is_expected.to fail_with(:invalid_ticket) }
    end

    context "when the response is stale" do
      let(:xml) { :example_response }

      before :each do
        allow(Time).to receive(:now).and_return(Time.utc(2012, 11, 8, 20, 45, 00))
      end

      context "without :allowed_clock_drift option" do
        it { is_expected.to fail_with(:invalid_ticket) }
      end

      context "with :allowed_clock_drift option" do
        before :each do
          saml_options[:allowed_clock_drift] = 60
        end

        it { is_expected.to_not fail_with(:invalid_ticket) }
      end
    end

    context "when response has custom attributes" do
      let(:xml) { :custom_attributes }

      before :each do
        saml_options[:idp_cert_fingerprint] = "3B:82:F1:F5:54:FC:A8:FF:12:B8:4B:B8:16:61:1D:E4:8E:9B:E2:3C"
        saml_options[:attribute_statements] = {
          email: ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"],
          first_name: ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"],
          last_name: ["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"]
        }

        post_callback_response
      end

      it "should obey attribute statements mapping" do
        expect(auth_hash[:info]).to eq(
          'first_name'   => 'Rajiv',
          'last_name'    => 'Manglani',
          'email'        => 'user@example.com',
          'name'         => nil
        )
      end
    end

    context "when using custom user id attribute" do
      let(:xml) { :custom_attributes }

      before :each do
        saml_options[:idp_cert_fingerprint] = "3B:82:F1:F5:54:FC:A8:FF:12:B8:4B:B8:16:61:1D:E4:8E:9B:E2:3C"
        saml_options[:uid_attribute] = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"

        post_callback_response
      end

      it "should return user id attribute" do
        expect(auth_hash[:uid]).to eq("user@example.com")
      end
    end

    context "when using custom user id attribute, but it is missing" do
      before :each do
        saml_options[:uid_attribute] = "missing_attribute"
      end

      it "should fail to authenticate" do
        expect(post_callback_response).to fail_with(:invalid_ticket)
        expect(last_request.env['omniauth.error']).to be_instance_of(OmniAuth::Strategies::SAML::ValidationError)
        expect(last_request.env['omniauth.error'].message).to eq("SAML response missing 'missing_attribute' attribute")
      end
    end
  end

  describe 'POST /auth/saml/slo' do
    before do
      saml_options[:sp_entity_id] = "https://idp.sso.example.com/metadata/29490"
    end

    context "when response is a logout response" do
      let(:opts) do
        { "rack.session" => { "saml_transaction_id" => "_3fef1069-d0c6-418a-b68d-6f008a4787e9" } }
      end

      let(:params) { { SAMLResponse: load_xml(:example_logout_response) } }

      subject(:post_slo_response) { post "/auth/saml/slo", params, opts }

      context "when relay state is relative" do
        let(:params) {super().merge(RelayState: "/signed-out")}

        it "redirects to the relaystate" do
          post_slo_response

          expect(last_response).to be_redirect
          expect(last_response.location).to eq "/signed-out"
        end
      end

      context "when relay state is an absolute https URL" do
        let(:params) {super().merge(RelayState: "https://example.com/")}

        it "redirects without a location header" do
          post_slo_response

          expect(last_response).to be_redirect
          expect(last_response.headers.fetch("Location")).to be_nil
        end
      end

      context 'when slo_default_relay_state is present' do
        let(:saml_options) { super().merge(slo_default_relay_state: '/signed-out') }

        context "when response relay state is valid" do
          let(:params) {super().merge(RelayState: "/safe/logout")}

          it {is_expected.to be_redirect.and have_attributes(location: '/safe/logout') }
        end

        context "when response relay state is invalid" do
          let(:params) {super().merge(RelayState: "javascript:alert(1)")}

          it {is_expected.to be_redirect.and have_attributes(location: '/signed-out') }
        end
      end

      context 'when slo_default_relay_state is blank' do
        let(:saml_options) { super().merge(slo_default_relay_state: nil) }

        context "when response relay state is valid" do
          let(:params) {super().merge(RelayState: "/safe/logout")}

          it {is_expected.to be_redirect.and have_attributes(location: '/safe/logout') }
        end

        context "when response relay state is invalid" do
          let(:params) {super().merge(RelayState: "javascript:alert(1)")}

          it {is_expected.to be_redirect.and have_attributes(location: nil) }
        end
      end
    end

    context "when request is a logout request" do
      subject { post "/auth/saml/slo", params, "rack.session" => { "saml_uid" => "username@example.com" } }

      let(:relay_state) { "https://example.com/" }

      let(:params) do
        {
          "SAMLRequest" => load_xml(:example_logout_request),
          "RelayState" => relay_state,
        }
      end

      context "when logout request is valid" do
        let(:relay_state) { "/logout" }

        before { subject }

        it "should redirect to logout response" do
          expect(last_response).to be_redirect
          expect(last_response.location).to match /https:\/\/idp.sso.example.com\/signoff\/29490/
          expect(last_response.location).to match /RelayState=%2Flogout/
        end
      end

      it_behaves_like 'validating RelayState param'

      context 'when slo_default_relay_state is blank' do
        let(:saml_options) { super().merge(slo_default_relay_state: nil) }

        context "when request relay state is invalid" do
          let(:params) do
            {
              "SAMLRequest" => load_xml(:example_logout_request),
              "RelayState" => "javascript:alert(1)",
            }
          end

          it "redirects without including a RelayState parameter" do
            subject

            expect(last_response).to be_redirect
            expect(last_response.location).to match %r{https://idp\.sso\.example\.com/signoff/29490}
            expect(last_response.location).not_to match(/RelayState=/)
          end
        end
      end

      context "with a custom relay state validator" do
        let(:saml_options) do
          super().merge(
            slo_relay_state_validator: proc do |relay_state, rack_request|
              expect(rack_request).to respond_to(:params)
              relay_state == "custom-state"
            end,
          )
        end
        let(:params) { super().merge("RelayState" => "custom-state") }

        it { is_expected.to be_redirect.and have_attributes(location: a_string_matching(/RelayState=custom-state/)) }
      end

      context "when request is an invalid logout request" do
        before :each do
          allow_any_instance_of(OneLogin::RubySaml::SloLogoutrequest).to receive(:is_valid?).and_return(false)
          allow_any_instance_of(OneLogin::RubySaml::SloLogoutrequest).to receive(:errors).and_return(['Blank logout request'])
        end

        # TODO: Maybe this should not raise an exception, but return some 4xx error instead?
        it "should raise an exception" do
          expect { subject }.
            to raise_error(OmniAuth::Strategies::SAML::ValidationError, 'SAML failed to process LogoutRequest (Blank logout request)')
        end
      end

      context "when request is a logout request but the request param is missing" do
        let(:params) { {} }

        # TODO: Maybe this should not raise an exception, but return a 422 error instead?
        it 'should raise an exception' do
          expect { subject }.
            to raise_error(OmniAuth::Strategies::SAML::ValidationError, 'SAML logout response/request missing')
        end
      end
    end

    context "when SLO is disabled" do
      before do
        saml_options[:slo_enabled] = false
        post "/auth/saml/slo"
      end

      it "should return not implemented" do
        expect(last_response.status).to eq 501
        expect(last_response.body).to eq "Not Implemented"
      end
    end
  end

  describe 'POST /auth/saml/spslo' do
    let(:params) { {} }
    subject { post "/auth/saml/spslo", params }

    def test_default_relay_state(static_default_relay_state = nil, &block_default_relay_state)
      saml_options["slo_default_relay_state"] = static_default_relay_state || block_default_relay_state
      post "/auth/saml/spslo"

      expect(last_response).to be_redirect
      expect(last_response.location).to match /https:\/\/idp.sso.example.com\/signoff\/29490/
      expect(last_response.location).to match /RelayState=https%3A%2F%2Fexample.com%2F/
    end

    it "should redirect to logout request" do
      test_default_relay_state("https://example.com/")
    end

    it "should redirect to logout request with a block" do
      test_default_relay_state do
        "https://example.com/"
      end
    end

    it "should redirect to logout request with a block with a request parameter" do
      test_default_relay_state do |request|
        "https://example.com/"
      end
    end

    it_behaves_like 'validating RelayState param'

    context 'when slo_default_relay_state is blank' do
      let(:saml_options) { super().merge(slo_default_relay_state: nil) }
      let(:params) { { RelayState: "//example.com" } }

      it "redirects without including a RelayState parameter" do
        subject

        expect(last_response).to be_redirect
        expect(last_response.location).to match %r{https://idp\.sso\.example\.com/signoff/29490}
        expect(last_response.location).not_to match(/RelayState=/)
      end
    end

    it "should give not implemented without an idp_slo_service_url" do
      saml_options.delete(:idp_slo_service_url)
      post "/auth/saml/spslo"

      expect(last_response.status).to eq 501
      expect(last_response.body).to match /Not Implemented/
    end

    context "when SLO is disabled" do
      before do
        saml_options[:slo_enabled] = false
        post "/auth/saml/spslo"
      end

      it "should return not implemented" do
        expect(last_response.status).to eq 501
        expect(last_response.body).to eq "Not Implemented"
      end
    end
  end

  describe 'POST /auth/saml/metadata' do
    before do
      saml_options[:sp_entity_id] = 'http://example.com/SAML'
      post '/auth/saml/metadata'
    end

    it 'should get SP metadata page' do
      expect(last_response.status).to eq 200
      expect(last_response.headers["Content-Type"]).to eq "application/xml"
    end

    it 'should configure attributes consuming service' do
      expect(last_response.body).to match /AttributeConsumingService/
      expect(last_response.body).to match /first_name/
      expect(last_response.body).to match /last_name/
      expect(last_response.body).to match /Required attributes/
      expect(last_response.body).to match /entityID/
      expect(last_response.body).to match /http:\/\/example.com\/SAML/
    end
  end

  context 'when hitting an unknown route in our sub path' do
    before { post '/auth/saml/unknown' }

    specify { expect(last_response.status).to eql 404 }
  end

  context 'when hitting a completely unknown route' do
    before { post '/unknown' }

    specify { expect(last_response.status).to eql 404 }
  end

  context 'when hitting a route that contains a substring match for the strategy name' do
    before { post '/auth/saml2/metadata' }

    it 'should not set the strategy' do
      expect(last_request.env['omniauth.strategy']).to be_nil
      expect(last_response.status).to eql 404
    end
  end

  describe 'subclass behavior' do
    it 'registers subclasses in OmniAuth.strategies' do
      subclass = Class.new(described_class)
      expect(OmniAuth.strategies).to include(described_class, subclass)
    end
  end
end
