# Email::Services::PepoCampaigns.new.get_send_info(<pepo_campaign_send_id>)
# Email::Services::PepoCampaigns.new.fetch_users_info([<email_address>])
# Email::Services::PepoCampaigns.new.create_list(<list_name>, <list_description>, 'single')
# Email::Services::PepoCampaigns.new.add_contact(
#   <list_id>,
#   <email_address>,
#   {
#     <attribute_1> => <value>,
#     <attribute_2> => <value>
#   },
#   {
#     <setting_1> => <value>,
#     <setting_2> => <value>,
#   }
#)
module Email

  module Services

    class PepoCampaigns

      require "uri"
      require "open-uri"
      require "openssl"

      # Initialize
      #
      # Sets @api_key, @api_secret, @api_base_url, @version
      #
      def initialize
        @api_key = GlobalConstant::PepoCampaigns.api_key
        @api_secret = GlobalConstant::PepoCampaigns.api_secret
        @api_base_url = GlobalConstant::PepoCampaigns.base_url
        @version = GlobalConstant::PepoCampaigns.version
      end

      # Create a List
      #
      # params:
      #   name, String
      #   source, String
      #   opt_in_type, String, (Single Opt In / Double Opt In)
      #
      # returns:
      #   Hash, response data from server
      #
      def create_list(name, source, opt_in_type)
        endpoint = "/api/#{@version}/list/create/"
        custom_params = {
          "name" => name,
          "source" => source,
          "opt_in_type" => opt_in_type
        }
        make_post_request(endpoint, custom_params)
      end

      # Add Contact to a List
      #
      # params:
      #   list_id, Integer
      #   email, String
      #   attributes, Hash
      #   user_status, Hash
      #
      # returns:
      #   Hash, response data from server
      #
      def add_contact(list_id, email, attributes = {}, user_status = {})
        endpoint = "/api/#{@version}/list/#{list_id}/add-contact/"
        custom_params = {
          'email' => email,
          'attributes' => attributes,
          'user_status' => user_status
        }
        make_post_request(endpoint, custom_params)
      end

      # Update contact
      #
      # params:
      #   list_id, Integer
      #   email, String
      #   attributes, Hash
      #   user_status, Hash
      #
      # returns:
      #   Hash, response data from server
      #
      def update_contact(list_id, email, attributes = {}, user_status = {})
        endpoint = "/api/#{@version}/list/#{list_id}/update-contact/"
        custom_params = {
          "email" => email,
          'attributes' => attributes,
          'user_status' => user_status
        }
        make_post_request(endpoint, custom_params)
      end

      # Remove contact
      #
      # params:
      #   list_id, Integer
      #   email, String
      #
      # returns:
      #   Hash, response data from server
      #
      def remove_contact(list_id, email)
        endpoint = "/api/#{@version}/list/#{list_id}/remove-contact/"
        custom_params = {
          "email" => email
        }
        make_post_request(endpoint, custom_params)
      end

      # Change user status
      #
      # params:
      #   email, String
      #   type, String
      #
      # returns:
      #   Hash, response data from server
      #
      def change_user_status(email, type)
        endpoint = "/api/#{@version}/user/change-status/"
        custom_params = {
          'email' => email,
          'type' => type
        }
        make_post_request(endpoint, custom_params)
      end

      # Fetch User Info
      #
      # params:
      #   emails, Array
      #
      # returns:
      #   Hash, response data from server
      #
      def fetch_users_info(emails)
        endpoint = "/api/#{@version}/user/info/"
        custom_params = {
          'emails' => emails.join(',')
        }
        make_get_request(endpoint, custom_params)
      end

      # Send transactional email
      #
      # params:
      #   email, String
      #   template, String
      #   email_vars, Hash
      #
      # returns:
      #   Hash, response data from server
      #
      def send_transactional_email(email, template, email_vars)
        endpoint = "/api/#{@version}/send/"
        email_vars['sub_environment'] = GlobalConstant::Base.main_sub_environment? ?
                                          GlobalConstant::Environment.mainnet_environment :
                                          GlobalConstant::Environment.testnet_environment
        custom_params = {
          "email" => email,
          "template" => template,
          "email_vars" => email_vars.to_json
        }
        make_post_request(endpoint, custom_params)
      end

      # Get Transactional Send Info
      #
      # params:
      #   send_id, String
      #
      # returns:
      #   Hash, response data from server
      #
      def get_send_info(send_id)
        endpoint = "/api/#{@version}/get-send/"
        custom_params = {
          "send_id" => send_id
        }
        make_get_request(endpoint, custom_params)
      end

      # List All Custom Attributes of an Account
      #
      # returns:
      #   Hash, response data from server
      #
      def fetch_custom_attributes
        endpoint = "/api/#{@version}/custom-attributes/"
        make_get_request(endpoint)
      end

      # Create New Custom Attribute
      #
      # params:
      #   name, String
      #   type, String
      #   options, Hash
      #
      # returns:
      #   Hash, response data from server
      #
      def create_custom_attribute(name, type, options={})
        endpoint = "/api/#{@version}/custom-attribute/create/"
        custom_params = {
          "name" => name,
          "type" => type,
          "fallback" => options[:fallback]
        }
        make_post_request(endpoint, custom_params)
      end

      private

      # Create Request Data
      #
      # params:
      #   uri, URI object
      #
      # returns:
      #   http, Net::HTTP object
      #
      def setup_request(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        end
        http
      end

      # Create Base Params
      #
      # params:
      #   endpoint, String
      #   custom_params, Hash
      #
      # returns:
      #   Hash, Request Data
      #
      def base_params(endpoint, custom_params={})
        request_time = DateTime.now.to_s
        query_param = custom_params.merge("request-time" => request_time).to_query.gsub(/^&/, '')
        str = "#{endpoint}?#{query_param}"
        {
          "request-time" => request_time,
          "signature" => generate_signature(str),
          "api-key" => @api_key
        }
      end

      # Generate Signature
      #
      # params:
      #   string_to_sign, String
      #
      # returns:
      #   String, HexDigest
      #
      def generate_signature(string_to_sign)
        digest = OpenSSL::Digest.new('sha256')
        OpenSSL::HMAC.hexdigest(digest, @api_secret, string_to_sign)
      end

      # Post API URI object
      #
      # params:
      #   endpoint, String
      #
      # returns:
      #   Object, URI object
      #
      def post_api_uri(endpoint)
        URI(@api_base_url + endpoint)
      end

      # Get API Url
      #
      # params:
      #   endpoint, String
      #
      # returns:
      #   String
      #
      def get_api_url(endpoint)
        @api_base_url + endpoint
      end

      # Make Get Request
      #
      # params:
      #   endpoint, String
      #   custom_params, Hash
      #
      # returns:
      #   Hash, Response
      #
      def make_get_request(endpoint, custom_params = {})
        base_params = base_params(endpoint, custom_params)
        raw_url = get_api_url(endpoint) + "?#{base_params.merge(custom_params).to_query}"

        begin
          Timeout.timeout(GlobalConstant::PepoCampaigns.api_timeout) do
            result = URI.parse(raw_url).read
            return JSON.parse(result)
          end
        rescue Timeout::Error => e
          return {"error" => "Timeout Error", "message" => "Error: #{e.message}"}
        rescue => e
          return {"error" => "Exception: Something Went Wrong", "message" => "Exception: #{e.message}"}
        end
      end

      # Make Post Request
      #
      # params:
      #   endpoint, String
      #   custom_params, Hash
      #
      # returns:
      #   Hash, Response
      #
      def make_post_request(endpoint, custom_params = {})
        base_params = base_params(endpoint, custom_params)
        uri = post_api_uri(endpoint)
        begin
          Timeout.timeout(GlobalConstant::PepoCampaigns.api_timeout) do
            http = setup_request(uri)
            result = http.post(uri.path, base_params.merge(custom_params).to_query)
            return JSON.parse(result.body)
          end
        rescue Timeout::Error => e
          return {"error" => "Timeout Error", "message" => "Error: #{e.message}"}
        rescue => e
          return {"error" => "Something Went Wrong", "message" => "Exception: #{e.message}"}
        end

      end

    end

  end

end