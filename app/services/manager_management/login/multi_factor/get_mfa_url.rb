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
        #
        # @return [ManagerManagement::Login::MultiFactor::GetMfaUrl]
        #
        def initialize(params)
          super
          @qr_code_url = ''
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

            validate

            fetch_manager

            if @manager_obj.mfa_token.present?
              if @manager_obj.send("#{GlobalConstant::Manager.has_setup_mfa_property}?")
                # If manager already setup MFA fail
                return success_response
              else
                # case when QR Code URL was once generated but manager never submitted valid OTP against it to setup MFA
                decrypt_authentication_salt
                decrypt_ga_secret
              end
            else
              # Set up a new one
              decrypt_authentication_salt
              setup_ga_secret
            end

            set_ga_secret_auth

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
          fail OstCustomError.new r unless r.success?

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
          fail OstCustomError.new r unless r.success?

          otpauth = r.data[:otpauth]
          escaped_otpauth = CGI.escape(otpauth)

          # @qr_code_url = "https://www.google.com/chart?chs=200x200&chld=M|0&cht=qr&chl=#{escaped_otpauth}"
          @qr_code_url ="https://chart.googleapis.com/chart?chs=200x200&chld=M|0&cht=qr&chl=#{escaped_otpauth}"
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
                                qr_code_url: @qr_code_url
                              }
                            })
        end

      end

    end

  end

end