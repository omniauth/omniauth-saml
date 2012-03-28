require 'spec_helper'

describe OmniAuth::Strategies::SAML::AuthResponse do
  let(:xml) { :example_response }
  subject { described_class.new(load_xml(xml)) }

  describe :initialize do
    context "when the response is nil" do
      it "should raise an exception" do
        expect { described_class.new(nil) }.to raise_error ArgumentError
      end
    end
  end

  describe :name_id do
    it "should load the name id from the assertion" do
      subject.name_id.should == 'THISISANAMEID'
    end

    context "when the response contains the signed_element_id" do
      let(:xml) { :response_contains_signed_element }

      it "should load the name id from the assertion" do
        subject.name_id.should == 'THISISANAMEID'
      end
    end
  end

  describe :attributes do
    it "should return all of the attributes as a hash" do
      subject.attributes.should == {
        :forename => 'Steven',
        :surname => 'Anderson',
        :address_1 => '24 Made Up Drive',
        :address_2 => nil,
        :companyName => 'Test Company Ltd',
        :postcode => 'XX2 4XX',
        :city => 'Newcastle',
        :country => 'United Kingdom',
        :userEmailID => 'steve@example.com',
        :county => 'TYNESIDE',
        :versionID => '1',
        :bundleID => '1',

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

    context "when no attributes exist in the XML" do
      let(:xml) { :no_attributes }

      it "should return an empty hash" do
        subject.attributes.should == {}
      end
    end
  end

  describe :session_expires_at do
    it "should return the SessionNotOnOrAfter as a Ruby date" do
      subject.session_expires_at.to_i.should == Time.new(2012, 04, 8, 12, 0, 24, 0).to_i
    end
  end

  describe :conditions do
    it "should return the conditions element from the XML" do
      subject.conditions.attributes['NotOnOrAfter'].should == '2012-03-08T16:30:01.336Z'
      subject.conditions.attributes['NotBefore'].should    == '2012-03-08T16:20:01.336Z'
      REXML::XPath.first(subject.conditions, '//saml:Audience').text.should include 'AUDIENCE'
    end
  end

  describe :valid? do
    it_should_behave_like 'a validating method', true
  end

  describe :validate! do
    it_should_behave_like 'a validating method', false
  end
end
