require 'omniauth'
require 'cgi'
require 'base64'
require 'nokogiri'
require 'digest/sha1'

module OmniAuth
  module Strategies
    # OmniAuth Strategy for authenticating with Signicat based identity solutions
    class Signicat
      include OmniAuth::Strategy

      def self.inherited(subclass)
        OmniAuth::Strategy.included(subclass)
      end

      XML_DS_NS = 'http://www.w3.org/2000/09/xmldsig#'.freeze

      option :env, 'preprod'
      option :service, 'demo'
      option :method, nil
      option :profile, 'default'
      option :language, 'en'

      def request_phase
        redirect(target_url)
      end

      def callback_phase
        unless request.params['SAMLResponse']
          raise OmniAuth::Strategies::Signicat::ValidationError, 'SAML response missing'
        end

        saml_response = Base64.decode64(request.params['SAMLResponse'])
        xml = Nokogiri.parse(saml_response)
        verify_signature!(xml)
        assign_attributes(xml)

        super
      rescue OmniAuth::Strategies::Signicat::ValidationError
        fail!(:invalid_ticket, $ERROR_INFO)
      end

      def target_url
        [
          "https://#{options[:env]}.signicat.com",
          "/std/method/#{options[:service]}",
          "?id=#{options[:method]}:#{options[:profile]}:#{options[:language]}",
          "&target=#{CGI.escape(callback_url)}"
        ].join('')
      end

      uid { @name_id }

      info do
        {
          'firstname' => @attributes['firstname'],
          'lastname' => @attributes['lastname'],
          'date-of-birth' => @attributes['date-of-birth']
        }
      end

      extra { { raw_info: @attributes } }

      private

      def verify_signature!(xml)
        key = extract_public_key(xml)

        signed_info = extract_signed_info(xml)
        signature = extract_signature(xml)
        return if key.verify(OpenSSL::Digest::SHA1.new, signature, signed_info)

        raise OmniAuth::Strategies::Signicat::ValidationError, 'Invalid signature'
      end

      def extract_public_key(xml)
        raw_cert = xml.xpath('//ds:X509Certificate/text()', 'ds' => XML_DS_NS).text
        cert = OpenSSL::X509::Certificate.new(Base64.decode64(raw_cert))
        if cert.subject.to_s != expected_cert_subject
          raise OmniAuth::Strategies::Signicat::ValidationError, 'Invalid certificate'
        end
        cert.public_key
      end

      def extract_signed_info(xml)
        noko_sig_element = xml.at_xpath('//ds:Signature', 'ds' => XML_DS_NS)
        noko_signed_info_element = noko_sig_element.at_xpath('./ds:SignedInfo', 'ds' => XML_DS_NS)

        canon_algorithm = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0
        noko_signed_info_element.canonicalize(canon_algorithm)
      end

      def extract_signature(xml)
        raw_signature = xml.xpath('//ds:SignatureValue', 'ds' => XML_DS_NS).text
        Base64.decode64(raw_signature)
      end

      def assign_attributes(xml)
        @attributes = {}
        xml.xpath('//saml:Attribute').each do |attr_node|
          key   = attr_node['AttributeName']
          value = attr_node.text
          @attributes[key] = value
        end
        @name_id = @attributes['unique-id']
      end

      def expected_cert_subject
        if options[:env] == 'id'
          '/C=NO/ST=Norway/L=Trondheim/O=Signicat/OU=Signicat/CN=id.signicat.com/std'
        else
          '/C=NO/ST=Norway/L=Trondheim/O=Signicat/OU=Signicat/CN=test.signicat.com/std'
        end
      end
    end
  end
end
