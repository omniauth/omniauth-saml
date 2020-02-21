module OneLogin
  module RubySaml
    class Response < SamlMessage
      # The alias chain is for adding the certificate element if missing in the SAML response.
      alias :old_initialize :initialize
      def initialize(response, options = {})
        old_initialize response, options
        @document.add_certificate options[:idp_cert] if @document.certificate_missing?
      end
    end
  end
end