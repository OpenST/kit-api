module ManagerManagement

  class SendDoubleOptInLink < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 15/01/2018
    # * Reviewed By:
    #
    # @params [String] manager_id (mandatory) - id of manager to which mail is to be sent
    #
    # @return [ManagerManagement::SendDoubleOptInLink]
    #
    def initialize(params)
      super

      @manager_id = @params[:manager_id]

      @manager = nil
      @manager_s = nil
      @double_optin_token = nil

    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 15/01/2018
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

        r = create_double_opt_in_token
        return r unless r.success?

        r = send_double_optin_email
        return r unless r.success?

        success

      end

    end

    private

    # Fetch user
    #
    # * Author: Puneet
    # * Date: 15/01/2018
    # * Reviewed By:
    #
    # Sets @manager, @manager_s
    #
    # @return [Result::Base]
    #
    def fetch_manager

      @manager = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]
      @manager_s = CacheManagement::ManagerSecure.new([@manager_id]).fetch[@manager_id]

      return validation_error(
          'um_doil_1',
          'invalid_api_params',
          ['unrecognized_email'],
          GlobalConstant::ErrorAction.default
      ) unless @manager.present? && @manager[:status] == GlobalConstant::Manager.active_status

      return validation_error(
          'um_doil_2',
          'invalid_api_params',
          ['already_verified_email'],
          GlobalConstant::ErrorAction.default
      ) if @manager[:properties].include?(GlobalConstant::Manager.has_verified_email_property)

      success

    end

    # Create Double Opt In Token
    #
    # * Author: Puneet
    # * Date: 15/01/2018
    # * Reviewed By:
    #
    # Sets @double_optin_token
    #
    # @return [Result::Base]
    #
    def create_double_opt_in_token

      double_opt_in_token = LocalCipher.get_sha_hashed_text(
          "#{@manager[:id]}::#{@manager_s[:password]}::#{current_timestamp}::double_optin::#{rand}"
      )
      db_row = ManagerValidationHash.create!(
          manager_id: @manager[:id],
          kind: GlobalConstant::ManagerValidationHash.double_optin_kind,
          validation_hash: double_opt_in_token,
          status: GlobalConstant::ManagerValidationHash.active_status
      )

      double_opt_in_token_str = "#{db_row.id.to_s}:#{double_opt_in_token}"
      encryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = encryptor_obj.encrypt(double_opt_in_token_str, GlobalConstant::ManagerValidationHash::double_optin_kind)
      return r unless r.success?

      @double_optin_token = r.data[:ciphertext_blob]

      success

    end

    # Send Double OptIn mail
    #
    # * Author: Puneet
    # * Date: 15/01/2018
    # * Reviewed By:
    #
    def send_double_optin_email
      Email::HookCreator::SendTransactionalMail.new(
          email: @manager[:email],
          template_name: GlobalConstant::PepoCampaigns.platform_double_optin_template,
          template_vars: {
              double_opt_in_token: CGI.escape(@double_optin_token),
              company_web_domain: GlobalConstant::CompanyWeb.domain
          }
      ).perform

      success
    end

  end

end
