require 'spec_helper'

RSpec::Matchers.define :fail_with do |message|
  match do |actual|
    actual.redirect? && actual.location == "/auth/failure?message=#{message}&strategy=saml"
  end
end

def post_xml(xml=:example_response)
  post "/auth/saml/callback", {'SAMLResponse' => load_xml(xml)}
end

describe OmniAuth::Strategies::SAML, :type => :strategy do
  include OmniAuth::Test::StrategyTestCase

  let(:auth_hash){ last_request.env['omniauth.auth'] }
  let(:saml_options) do
    {
      :assertion_consumer_service_url => "http://localhost:3000/auth/saml/callback",
      :issuer                         => "https://saml.issuer.url/issuers/29490",
      :idp_sso_target_url             => "https://idp.sso.target_url/signon/29490",
      :idp_cert_fingerprint           => "E6:87:89:FB:F2:5F:CD:B0:31:32:7E:05:44:84:53:B1:EC:4E:3F:FA",
      :name_identifier_format         => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    }
  end
  let(:strategy) { [OmniAuth::Strategies::SAML, saml_options] }

  describe 'GET /auth/saml' do
    before do
      get '/auth/saml'
    end

    it 'should get authentication page' do
      last_response.should be_redirect
    end
  end

  describe 'POST /auth/saml/callback' do
    subject { last_response }

    let(:xml) { :example_response }

    before :each do
      Time.stub(:now).and_return(Time.new(2012, 3, 8, 16, 25, 00, 0))
    end

    context "when the response is valid" do
      before :each do
        post_xml
      end

      it "should set the uid to the nameID in the SAML response" do
        auth_hash['uid'].should == 'THISISANAMEID'
      end

      it "should set the raw info to all attributes" do
        auth_hash['extra']['raw_info'].to_hash.should == {
          'forename' => 'Steven',
          'surname' => 'Anderson',
          'address_1' => '24 Made Up Drive',
          'address_2' => nil,
          'companyName' => 'Test Company Ltd',
          'postcode' => 'XX2 4XX',
          'city' => 'Newcastle',
          'country' => 'United Kingdom',
          'userEmailID' => 'steve@example.com',
          'county' => 'TYNESIDE',
          'versionID' => '1',
          'bundleID' => '1'
        }
      end
    end

    context "when there is no SAMLResponse parameter" do
      before :each do
        post '/auth/saml/callback'
      end

      it { should fail_with(:invalid_ticket) }
    end

    context "when there is no name id in the XML" do
      before :each do
        post_xml :no_name_id
      end

      it { should fail_with(:invalid_ticket) }
    end

    context "when the fingerprint is invalid" do
      before :each do
        saml_options[:idp_cert_fingerprint] = "E6:87:89:FB:F2:5F:CD:B0:31:32:7E:05:44:84:53:B1:EC:4E:3F:FB"
        post_xml
      end

      it { should fail_with(:invalid_ticket) }
    end

    context "when the digest is invalid" do
      before :each do
        post_xml :digest_mismatch
      end

      it { should fail_with(:invalid_ticket) }
    end

    context "when the signature is invalid" do
      before :each do
        post_xml :invalid_signature
      end

      it { should fail_with(:invalid_ticket) }
    end

    context "when the time is before the NotBefore date" do
      before :each do
        Time.stub(:now).and_return(Time.new(2000, 3, 8, 16, 25, 00, 0))
        post_xml
      end

      it { should fail_with(:invalid_ticket) }
    end

    context "when the time is after the NotOnOrAfter date" do
      before :each do
        Time.stub(:now).and_return(Time.new(3000, 3, 8, 16, 25, 00, 0))
        post_xml
      end

      it { should fail_with(:invalid_ticket) }
    end
  end

  describe 'GET /auth/saml/metadata' do
    before do
      get '/auth/saml/metadata'
    end

    it 'should get SP metadata page' do
      last_response.status.should == 200
      last_response.header["Content-Type"].should == "application/xml"
    end
  end
end
