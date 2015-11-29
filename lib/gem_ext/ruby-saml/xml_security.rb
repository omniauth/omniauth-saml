
module XMLSecurity
  class SignedDocument < BaseDocument
    def add_certificate(certificate)
      signature_element = REXML::XPath.first(
        self,
        "//ds:Signature",
        { "ds"=>DSIG }
      )
      key_info_element       = signature_element.add_element("ds:KeyInfo")
      x509_element           = key_info_element.add_element("ds:X509Data")
      x509_cert_element      = x509_element.add_element("ds:X509Certificate")
      if certificate.is_a?(String)
        certificate = OpenSSL::X509::Certificate.new(certificate)
      end
      x509_cert_element.text = Base64.encode64(certificate.to_der).gsub(/\n/, "")
    end

    def certificate_missing?
      cert_element = REXML::XPath.first(
        self,
        "//ds:X509Certificate",
        { "ds"=>DSIG }
      )
      cert_element.nil?
    end
  end
end