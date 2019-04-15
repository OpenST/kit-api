module ManagerManagement

  module Login

    module MultiFactor

      class GetMfaUrl < ManagerManagement::Login::MultiFactor::Base

        # Initialize
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        # @params [String] manager_id (mandatory) - manager_id
        # @params [String] browser_user_agent (mandatory) - browser user agent
        # @params [String] cookie_value (mandatory) -
        #
        # @return [ManagerManagement::Login::MultiFactor::GetMfaUrl]
        #
        def initialize(params)
          super
          @qr_code_token = ''
          @sub_env_payload_data = nil
          @client_id = @client[:id]
        end

        # Perform
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        # @return [Result::Base]
        #
        def perform

          handle_errors_and_exceptions do

            r = validate
            return r unless r.success?

            r = fetch_manager
            return r unless r.success?

            r = handle_go_to
            return r unless r.success?

            if @manager_obj.mfa_token.present?
              if @manager_obj.send("#{GlobalConstant::Manager.has_setup_mfa_property}?")
                # If manager already setup MFA
                return success_response
              else
                # case when QR Code URL was once generated but manager never submitted valid OTP against it to setup MFA
                r = decrypt_authentication_salt
                return r unless r.success?

                r = decrypt_ga_secret
                return r unless r.success?
              end
            else
              # Set up a new one
              r = decrypt_authentication_salt
              return r unless r.success?

              r = setup_ga_secret
              return r unless r.success?
            end

            r = set_ga_secret_auth
            return r unless r.success?

            r = fetch_sub_env_payloads
            return r unless r.success?

            success_response

          end

        end

        private

        # Set up Ga Secret Auth
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        # Sets @ga_secret_d
        #
        def setup_ga_secret

          @ga_secret_d = ROTP::Base32.random_base32

          encryptor_obj = LocalCipher.new(@authentication_salt_d)

          #get encrypted_ga_secret
          r = encryptor_obj.encrypt(@ga_secret_d)
          return r unless r.success?

          @manager_obj.mfa_token = r.data[:ciphertext_blob]
          @manager_obj.save

          success

        end

        # Set Ga Secret Auth
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        #
        def set_ga_secret_auth

          rotp_client = Google::Authenticator.new(@ga_secret_d)
          r = rotp_client.provisioning_uri("#{@manager_obj.email}")
          return r unless r.success?

          @qr_code_token = r.data[:otpauth]

          success

        end

        # Set success output format
        #
        # * Author: Shlok
        # * Date: 13/12/2018
        # * Reviewed By:
        #
        def success_response
          success_with_data({
                              setup_mfa: {
                                qr_code_token: @qr_code_token
                              },
                              sub_env_payloads: @sub_env_payload_data,
                            })
        end

        # fetch the sub env response data entity
        #
        # * Author: Ankit
        # * Date: 04/02/2019
        # * Reviewed By: Sunil
        #
        # @return [Result::Base]
        #
        def fetch_sub_env_payloads
          r = SubEnvPayload.new({client_id: @client_id}).perform
          return r unless r.success?

          @sub_env_payload_data = r.data[:sub_env_payloads]

          success
        end

      end

    end

  end

end