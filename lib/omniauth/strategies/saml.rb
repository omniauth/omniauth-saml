require 'omniauth'
require 'ruby-saml'

module OmniAuth
  module Strategies
    class SAML
      include OmniAuth::Strategy

      option :name_identifier_format, "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
      option :idp_sso_target_url_runtime_params, {}

      def request_phase
        runtime_request_parameters = options.delete(:idp_sso_target_url_runtime_params)

        additional_params = {}
        runtime_request_parameters.each_pair do |request_param_key, mapped_param_key|
          puts "Inside each param keypair : #{request_param_key} - #{mapped_param_key}"
          additional_params[mapped_param_key] = request.params[request_param_key.to_s] if request.params.has_key?(request_param_key.to_s)
        end if runtime_request_parameters

        authn_request = Onelogin::Saml::Authrequest.new
        settings = Onelogin::Saml::Settings.new(options)

        redirect(authn_request.create(settings, additional_params))
      end

      def callback_phase
        unless request.params['SAMLResponse']
          raise OmniAuth::Strategies::SAML::ValidationError.new("SAML response missing")
        end

        response = Onelogin::Saml::Response.new(request.params['SAMLResponse'])
        response.settings = Onelogin::Saml::Settings.new(options)

        @name_id = response.name_id
        @attributes = response.attributes

        if @name_id.nil? || @name_id.empty?
          raise OmniAuth::Strategies::SAML::ValidationError.new("SAML response missing 'name_id'")
        end

        response.validate!

        super
      rescue OmniAuth::Strategies::SAML::ValidationError
        fail!(:invalid_ticket, $!)
      rescue Onelogin::Saml::ValidationError
        fail!(:invalid_ticket, $!)
      end

      uid { @name_id }

      info do
        {
          :name  => @attributes[:name],
          :email => @attributes[:email] || @attributes[:mail],
          :first_name => @attributes[:first_name] || @attributes[:firstname] || @attributes[:firstName],
          :last_name => @attributes[:last_name] || @attributes[:lastname] || @attributes[:lastName]
        }
      end

      extra { { :raw_info => @attributes } }
    end
  end
end

OmniAuth.config.add_camelization 'saml', 'SAML'
