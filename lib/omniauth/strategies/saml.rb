require 'omniauth'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class SAML
      include OmniAuth::Strategy

      option :name_identifier_format, nil
      option :idp_sso_target_url_runtime_params, {}
      option :request_attributes, [
        { name: 'email', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Email address' },
        { name: 'name', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Full name' },
        { name: 'first_name', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Given name' },
        { name: 'last_name', name_format: 'urn:oasis:names:tc:SAML:2.0:attrname-format:basic', friendly_name: 'Family name' }
      ]
      option :attribute_service_name, 'Required attributes'
      
      option :slo_default_relay_state
      option :uid_attribute
      

      def request_phase
        # delete params from session - causes CookieOverflow exception.

        session.delete('omniauth.params')
        options.request_dynamic_options.(request, options)
        options[:assertion_consumer_service_url] ||= callback_url
        runtime_request_parameters = options.delete(:idp_sso_target_url_runtime_params)

        additional_params = {}
        runtime_request_parameters.each_pair do |request_param_key, mapped_param_key|
          additional_params[mapped_param_key] = request.params[request_param_key.to_s] if request.params.has_key?(request_param_key.to_s)
        end if runtime_request_parameters

        authn_request = OneLogin::RubySaml::Authrequest.new
        settings = OneLogin::RubySaml::Settings.new(options)

        redirect(authn_request.create(settings, additional_params))
      end

      def callback_phase
        unless request.params['SAMLResponse']
          raise OmniAuth::Strategies::SAML::ValidationError.new("SAML response missing")
        end
        options.response_dynamic_options.(request, options)

        # Call a fingerprint validation method if there's one
        if options.idp_cert_fingerprint_validator
          fingerprint_exists = options.idp_cert_fingerprint_validator[response_fingerprint]
          unless fingerprint_exists
            raise OmniAuth::Strategies::SAML::ValidationError.new("Non-existent fingerprint")
          end
          # id_cert_fingerprint becomes the given fingerprint if it exists
          options.idp_cert_fingerprint = fingerprint_exists
        end

        response = OneLogin::RubySaml::Response.new(request.params['SAMLResponse'], options)
        response.settings = OneLogin::RubySaml::Settings.new(options)
        response.attributes['fingerprint'] = options.idp_cert_fingerprint

        @name_id = response.name_id
        @attributes = response.attributes
        if @name_id.nil? || @name_id.empty?
          raise OmniAuth::Strategies::SAML::ValidationError.new("SAML response missing 'name_id'")
        end

        # will raise an error since we are not in soft mode
        response.soft = false
        response.is_valid?

        super
      rescue OmniAuth::Strategies::SAML::ValidationError
        fail!(:invalid_ticket, $!)
      rescue OneLogin::RubySaml::ValidationError
        fail!(:invalid_ticket, $!)
      end

      # Obtain an idp certificate fingerprint from the response.
      def response_fingerprint
        response = request.params['SAMLResponse']
        response = (response =~ /^</) ? response : Base64.decode64(response)
        document = XMLSecurity::SignedDocument::new(response)
        cert_element = REXML::XPath.first(document, "//ds:X509Certificate", { "ds"=> 'http://www.w3.org/2000/09/xmldsig#' })
        base64_cert = cert_element.text
        cert_text = Base64.decode64(base64_cert)
        cert = OpenSSL::X509::Certificate.new(cert_text)
        Digest::SHA1.hexdigest(cert.to_der).upcase.scan(/../).join(':')
      end

      def other_phase

        if on_path?("#{request_path}/metadata")
          # omniauth does not set the strategy on the other_phase
          @env['omniauth.strategy'] ||= self
          setup_phase

          response = OneLogin::RubySaml::Metadata.new
          settings = OneLogin::RubySaml::Settings.new(options)
          if options.request_attributes.length > 0
            settings.attribute_consuming_service.service_name options.attribute_service_name
            options.request_attributes.each do |attribute|
              settings.attribute_consuming_service.add_attribute attribute
            end
          end
          Rack::Response.new(response.generate(settings), 200, { "Content-Type" => "application/xml" }).finish
        else
          call_app!
        end
      end

      uid { @name_id }

      # Override
      info do
        found_attributes = options.attribute_statements.map do |key, values|
          attribute = find_attribute_by(values)
          [key, attribute]
        end
        
        Hash[found_attributes]
      end

      def find_attribute_by(keys)
        keys.each do |key|
          return @attributes[key] if @attributes[key]
        end

        nil
      end

    end
  end
end

OmniAuth.config.add_camelization 'saml', 'SAML'
