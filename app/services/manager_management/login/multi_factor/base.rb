module ManagerManagement

  module Login

    module MultiFactor

      class Base < ServicesBase

        # Initialize
        #
        # * Author: Puneet
        # * Date: 10/10/2017
        # * Reviewed By: 
        #
        # @params [String] password_auth_cookie_value (mandatory) - single auth cookie value
        #
        # @return [ManagerManagement::Login::MultiFactor::Base]
        #
        def initialize(params)

          super

          @manager_id = @params[:manager_id]

          @manager = nil
          @authentication_salt_d = nil
          @ga_secret_d = nil

        end

        private

        # Fetch admin
        #
        # * Author: 
        # * Date: 10/10/2017
        # * Reviewed By: Sunil
        #
        # Sets @manager
        #
        # @return [Result::Base]
        #
        def fetch_manager
          @manager = Manager.where(id: @manager_id).first
          fail OstCustomError.new unauthorized_access_response('am_l_ma_b_2') unless @manager.present?
          success
        end

        # Decrypt login salt
        #
        # * Author: 
        # * Date: 10/10/2017
        # * Reviewed By: Sunil
        #
        # Sets @authentication_salt_d
        #
        # @return [Result::Base]
        #
        def decrypt_authentication_salt

          authentication_salt_e = @manager.authentication_salt
          fail OstCustomError.new unauthorized_access_response('am_l_ma_b_4') unless authentication_salt_e.present?

          r = Aws::Kms.new('login', 'user').decrypt(authentication_salt_e)
          fail OstCustomError.new unauthorized_access_response('am_l_ma_b_5') unless r.success?

          @authentication_salt_d = r.data[:plaintext]

          success
        end

        # Decrypt ga secret
        #
        # * Author: Puneet
        # * Date: 10/10/2017
        # * Reviewed By: Sunil
        #
        # Sets @ga_secret_d
        #
        # @return [Result::Base]
        #
        def decrypt_ga_secret

          decryptor_obj = LocalCipher.new(@authentication_salt_d)

          resp = decryptor_obj.decrypt(@manager.mfa_token)
          fail OstCustomError.new unauthorized_access_response('am_l_ma_b_6') unless resp.success?

          @ga_secret_d = resp.data[:plaintext]

          success
        end

        # Unauthorized access response
        #
        # * Author: Alpesh
        # * Date: 15/01/2018
        # * Reviewed By:
        #
        # @param [String] err (mandatory) - err code
        # @param [String] display_text (optional) - display text
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

      end

    end
  end

end