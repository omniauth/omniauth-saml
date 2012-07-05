require 'spec_helper'

describe OmniAuth::Strategies::SAML::MetadataResponse do
  describe :create do
    let(:metadata) do
      described_class.new.create(
          {
              :idp_sso_target_url             => 'example.com',
              :assertion_consumer_service_url => 'http://example.com/auth/saml/callback',
              :issuer                         => 'This is an issuer',
              :name_identifier_format         => 'Some Policy'
          },
          {
              :some_param => 'foo',
              :some_other => 'bar'
          }
      )
    end

    describe "the saml SP metadata" do
      subject { metadata }

      let(:xml) { REXML::Document.new(metadata) }

      it "should contain the issuer" do
        REXML::XPath.first(xml, '//md:EntityDescriptor').attributes['entityID'].should == 'This is an issuer'
      end

      it "should contain the callback url in the settings" do
        REXML::XPath.first(xml, '//md:AssertionConsumerService').attributes['Location'].should == 'http://example.com/auth/saml/callback'
      end

      it "should contain the name identifier format" do
        REXML::XPath.first(xml, '//md:NameIDFormat').text.should == 'Some Policy'
      end

    end
  end
end