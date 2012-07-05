module OmniAuth
  module Strategies
    class SAML
      class MetadataResponse
        def create(settings, params = { })
          response =
              "<?xml version='1.0'?>\n" +
                  "<md:EntityDescriptor xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\" entityID=\"#{settings[:issuer]}\">\n" +
                  "<md:SPSSODescriptor protocolSupportEnumeration=\"urn:oasis:names:tc:SAML:2.0:protocol\">\n"
          unless settings[:name_identifier_format].nil?
            response << "<md:NameIDFormat>#{settings[:name_identifier_format]}</md:NameIDFormat>\n"
          end
          response <<
              "<md:AssertionConsumerService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Location=\"#{settings[:assertion_consumer_service_url]}\"/>\n" +
              "</md:SPSSODescriptor>\n" +
              "</md:EntityDescriptor>"
        end
      end
    end
  end
end

