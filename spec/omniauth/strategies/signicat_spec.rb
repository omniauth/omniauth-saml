# rubocop:disable Metrics/LineLength
require 'spec_helper'

RSpec::Matchers.define :fail_with do |message|
  match do |actual|
    actual.redirect? && /\?.*message=#{message}/ =~ actual.location
  end
end

def post_xml(xml = :example_response)
  post '/auth/signicat/callback', 'SAMLResponse' => load_xml(xml)
end

describe OmniAuth::Strategies::Signicat, type: :strategy do
  include OmniAuth::Test::StrategyTestCase

  let(:auth_hash) { last_request.env['omniauth.auth'] }
  let(:signicat_options) do
    {
      env: 'preprod',
      service: 'demo',
      method: 'nbid',
      language: 'nb'
    }
  end
  let(:strategy) { [OmniAuth::Strategies::Signicat, signicat_options] }

  describe 'GET /auth/signicat' do
    before do
      get '/auth/signicat'
    end

    it 'should redirect correctly' do
      last_response.location.should include 'https://preprod.signicat.com/std/method/demo?id=nbid:default:nb'
    end
  end

  describe 'POST /auth/signicat/callback' do
    subject { last_response }

    let(:xml) { :example_response }

    before :each do
      Time.stub(:now).and_return(Time.utc(2016, 5, 10, 8, 57, 00))
    end

    shared_examples_for 'a valid response' do
      it 'should set the uid to the nameID in the SAML response' do
        auth_hash['uid'].should == '9578-6000-4-140135'
      end

      it 'should set the info' do
        auth_hash[:info].should == {
          'firstname' => 'Bjørn Test',
          'lastname' => 'Teisvær',
          'date-of-birth' => '1961-03-23'
        }
      end

      it 'should set the raw info to all attributes' do
        auth_hash['extra'][:raw_info].should == {
          'action' => 'auth',
          'bank' => 'TestBank1',
          'bankid-no' => '9578-6000-4-140135',
          'date-of-birth' => '1961-03-23',
          'firstname' => "Bjørn Test",
          'fnr' => '23036107340',
          'issuer-dn' => 'CN=BankID TestBank1 Bank CA 2,OU=123456789,O=TestBank1 AS,C=NO',
          'key-algorithm' => 'RSA',
          'key-size' => '2048',
          'lastname' => "Teisvær",
          'method-name' => 'nbid',
          'monetary-limit-amount' => '100000',
          'monetary-limit-currency' => 'NOK',
          'national-id' => '23036107340',
          'no.fnr' => '23036107340',
          'originator' => '9999',
          'plain-name' => "Teisvær, Bjørn Test",
          'policy-oid' => '2.16.578.1.16.1.12.1.1',
          'qualified' => 'true',
          'security-level' => '3',
          'serialnumber' => '552735',
          'service-name' => 'shared',
          'subject-dn' => "CN=Teisvær\\, Bjørn Test,O=BankID - TestBank1,C=NO,SERIALNUMBER=9578-6000-4-140135",
          'unique-id' => '9578-6000-4-140135',
          'valid-from' => '2016-05-09',
          'valid-to' => '2018-05-09',
          'version-number' => '3'
        }
      end
    end

    context 'when the response is valid' do
      before :each do
        post_xml
      end

      it_behaves_like 'a valid response'
    end

    context 'when there is no SAMLResponse parameter' do
      before :each do
        post '/auth/signicat/callback'
      end

      it { should fail_with(:invalid_ticket) }
    end

    context 'when the digest is invalid' do
      before :each do
        post_xml :digest_mismatch
      end

      it { should fail_with(:invalid_ticket) }
    end

    context 'when the signature is invalid' do
      before :each do
        post_xml :invalid_signature
      end

      it { should fail_with(:invalid_ticket) }
    end

    context 'when the cert is wrong' do
      before :each do
        post_xml :invalid_cert
      end

      it { should fail_with(:invalid_ticket) }
    end
  end

  describe 'subclass behavior' do
    it 'registers subclasses in OmniAuth.strategies' do
      subclass = Class.new(described_class)
      expect(OmniAuth.strategies).to include(described_class, subclass)
    end
  end
end
