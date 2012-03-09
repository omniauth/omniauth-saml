def assert_is_valid(soft)
  if soft
    it { should be_valid }
  else
    it "should be valid" do
      expect { subject.validate! }.not_to raise_error
    end
  end
end

def assert_is_not_valid(soft)
  if soft
    it { should_not be_valid }
  else
    it "should be invalid" do
      expect { subject.validate! }.to raise_error
    end
  end
end

def stub_validate_to_fail(soft)
  if soft
    subject.document.stub(:validate).and_return(false)
  else
    subject.document.stub(:validate).and_raise(Exception)
  end
end

shared_examples_for 'a validating method' do |soft|
  before :each do
    subject.settings = mock(Object, :idp_cert_fingerprint => 'FINGERPRINT', :idp_cert => nil)
    subject.document.stub(:validate).and_return(true)
  end

  context "when the response is empty" do
    subject { described_class.new('') }

    assert_is_not_valid(soft)
  end

  context "when the settings are nil" do
    before :each do
      subject.settings = nil
    end

    assert_is_not_valid(soft)
  end

  context "when there is no idp_cert_fingerprint and idp_cert" do
    before :each do
      subject.settings = mock(Object, :idp_cert_fingerprint => nil, :idp_cert => nil)
    end

    assert_is_not_valid(soft)
  end

  context "when conditions are not given" do
    let(:xml) { :no_conditions }

    assert_is_valid(soft)
  end

  context "when the current time is before the NotBefore time" do
    before :each do
      Time.stub(:now).and_return(Time.new(2000, 01, 01, 10, 00, 00, 0))
    end

    assert_is_not_valid(soft)
  end

  context "when the current time is after the NotOnOrAfter time" do
    before :each do
      # We're assuming here that this code will be out of use in 1000 years...
      Time.stub(:now).and_return(Time.new(3012, 01, 01, 10, 00, 00, 0))
    end

    assert_is_not_valid(soft)
  end

  context "when the current time is between the NotBefore and NotOnOrAfter times" do
    before :each do
      Time.stub(:now).and_return(Time.new(2012, 3, 8, 16, 25, 00, 0))
    end

    assert_is_valid(soft)
  end

  context "when skip_conditions option is given" do
    before :each do
      subject.options[:skip_conditions] = true
    end

    assert_is_valid(soft)
  end

  context "when the SAML document is valid" do
    before :each do
      subject.document.should_receive(:validate).with('FINGERPRINT', soft).and_return(true)
      subject.options[:skip_conditions] = true
    end

    assert_is_valid(soft)
  end

  context "when the SAML document is valid and the idp_cert is given" do
    let(:cert) do
      filename = File.expand_path(File.join('..', '..', 'support', "example_cert.pem"), __FILE__)
      IO.read(filename)
    end
    let(:expected) { 'E6:87:89:FB:F2:5F:CD:B0:31:32:7E:05:44:84:53:B1:EC:4E:3F:FA' }

    before :each do
      subject.settings.stub(:idp_cert).and_return(cert)
      subject.document.should_receive(:validate).with(expected, soft).and_return(true)
      subject.options[:skip_conditions] = true
    end

    assert_is_valid(soft)
  end

  context "when the SAML document is invalid" do
    before :each do
      stub_validate_to_fail(soft)
      subject.options[:skip_conditions] = true
    end

    assert_is_not_valid(soft)
  end
end
