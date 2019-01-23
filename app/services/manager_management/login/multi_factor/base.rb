module ManagerManagement

  module Login

    module MultiFactor

      class Base < ServicesBase

        # Initialize
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By: 
        #
        # @params [String] password_auth_cookie_value (mandatory) - single auth cookie value
        # @params [String] browser_user_agent (mandatory) - browser user agent
        # @params [String] cookie_value (mandatory) - cookie value
        # @params [Hash] client (mandatory) - client
        #
        # @return [ManagerManagement::Login::MultiFactor::Base]
        #
        def initialize(params)

          super

          @client = @params[:client]
          @manager_id = @params[:manager_id]
          @cookie_value = @params[:cookie_value]
          @browser_user_agent = @params[:browser_user_agent]

          @manager_obj = nil
          @authentication_salt_d = nil
          @ga_secret_d = nil

        end

        private

        # Fetch admin
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        # Sets @manager_obj
        #
        # @return [Result::Base]
        #
        def fetch_manager

          @manager_obj = Manager.where(id: @manager_id).first

          fail OstCustomError.new unauthorized_access_response('am_l_ma_b_2') unless @manager_obj.present?

          fail OstCustomError.new error_with_go_to(
                                      'am_l_ma_b_3',
                                      'unauthorized_access_response',
                                      GlobalConstant::GoTo.verify_email
                                  ) unless @manager_obj.send("#{GlobalConstant::Manager.has_verified_email_property}?")

          success

        end

        # Decrypt login salt
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        # Sets @authentication_salt_d
        #
        # @return [Result::Base]
        #
        def decrypt_authentication_salt

          authentication_salt_e = @manager_obj.authentication_salt
          fail OstCustomError.new unauthorized_access_response('am_l_ma_b_4') unless authentication_salt_e.present?

          r = Aws::Kms.new(GlobalConstant::Kms.login_purpose, GlobalConstant::Kms.user_role).decrypt(authentication_salt_e)
          fail OstCustomError.new unauthorized_access_response('am_l_ma_b_5') unless r.success?

          @authentication_salt_d = r.data[:plaintext]

          success
        end

        # Decrypt ga secret
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        # Sets @ga_secret_d
        #
        # @return [Result::Base]
        #
        def decrypt_ga_secret

          decryptor_obj = LocalCipher.new(@authentication_salt_d)

          resp = decryptor_obj.decrypt(@manager_obj.mfa_token)
          fail OstCustomError.new unauthorized_access_response('am_l_ma_b_6') unless resp.success?

          @ga_secret_d = resp.data[:plaintext]

          success
        end

        # Unauthorized access response
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        # @param [String] err (mandatory) - err code
        #
        # @return [Result::Base]
        #
        def unauthorized_access_response(err)
          fail OstCustomError.new error_with_data(
              err,
              'unauthorized_access_response',
              GlobalConstant::ErrorAction.default
          )
        end

        # Handle Go To
        #
        # * Author: Puneet
        # * Date: 08/12/2018
        # * Reviewed By:
        #
        # @return [Result::Base]
        #
        def handle_go_to

          r = ManagerManagement::VerifyCookie::MultiFactorAuth.new(
              browser_user_agent: @browser_user_agent, cookie_value: @cookie_value
          ).perform

          if r.success?

            go_to = FetchGoTo.new({
                              is_password_auth_cookie_valid: true,
                              is_multi_auth_cookie_valid: true,
                              client: @client,
                              manager: @manager_obj.formated_cache_data
                          }).fetch_by_economy_state

            fail OstCustomError.new error_with_go_to(
                                        'am_l_ma_b_7',
                                        'unauthorized_access_response',
                                        go_to
                                    )

          end

        end

      end

    end

  end

end