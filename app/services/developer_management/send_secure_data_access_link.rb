module DeveloperManagement

  class SendSecureDataAccessLink < ServicesBase

    # Initialize
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By: Kedar
    #
    # @params [String] manager_id (mandatory) - manager id
    #
    # @return [DeveloperManagement::SendSecureDataAccessLink]
    #
    def initialize(params)
      super

      @manager_id = @params[:manager_id]

      @manager = nil

    end

    # Perform
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate
        return r unless r.success?

        r = fetch_manager
        return r unless r.success?

        r = create_manager_validation_hash
        return r unless r.success?

        r = fetch_secure_data_acccess_token
        return r unless r.success?

        r = send_mail
        return r unless r.success?

        success_with_data({manager_validation_hash_id: @manager_validation_hash_id})

      end

    end

    private

    # Fetch manager
    #
    # * Author: Dhananjay
    # * Date: 01/06/2019
    # * Reviewed By:
    #
    # Sets @manager
    #
    # @return [Result::Base]
    #
    def fetch_manager

      @manager = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]

      return error_with_data(
        's_dm_ssdalj_1',
        'something_went_wrong',
        GlobalConstant::ErrorAction.default
      ) unless @manager.present? && @manager[:status] == GlobalConstant::Manager.active_status

      success

    end

    # Create manager validation hash
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By:
    #
    # Sets @validation_hash, @manager_validation_hash_id
    #
    # @return [Result::Base]
    #
    def create_manager_validation_hash

      @validation_hash = LocalCipher.get_sha_hashed_text(
        "#{@manager[:id]}::#{@manager[:email]}::#{current_timestamp}::secure_access_data::#{rand}"
      )

      # purpose of this extra hash is to increase complexity.
      salt = LocalCipher.get_sha_hashed_text(
        "#{@manager[:id]}::#{@manager[:first_name]}::#{@manager[:last_name]}::#{current_timestamp}::extra_hash::#{rand}"
      )

      db_row = ManagerValidationHash.create!(
        manager_id: @manager[:id],
        kind: GlobalConstant::ManagerValidationHash.secure_data_access_kind,
        validation_hash: @validation_hash,
        status: GlobalConstant::ManagerValidationHash.active_status,
        extra_data: {salt: salt}
      )

      @manager_validation_hash_id = db_row.id

      success

    end

    # Fetch Secure Data Access Token
    #
    # * Author: Dhananjay
    # * Date: 03/06/2019
    # * Reviewed By:
    #
    # Sets @secure_data_access_token
    #
    def fetch_secure_data_acccess_token

      sda_token_str = "#{@manager_validation_hash_id.to_s}:#{current_timestamp}:#{@validation_hash}"
      encryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)

      r = encryptor_obj.encrypt(sda_token_str, GlobalConstant::ManagerValidationHash::secure_data_access_kind)
      return r unless r.success?

      @secure_data_access_token = r.data[:ciphertext_blob]

      success

    end

    # Send secure data access verification mail
    #
    # * Author: Dhananjay
    # * Date: 01/06/2019
    # * Reviewed By:
    #
    def send_mail
      Email::HookCreator::SendTransactionalMail.new(
        receiver_entity_id: @manager_id,
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
        template_name: GlobalConstant::PepoCampaigns.platform_secure_data_access_template,
        template_vars: {
          secure_data_access_token: CGI.escape(@secure_data_access_token),
          company_web_domain: CGI.escape(GlobalConstant::CompanyWeb.domain),
          sub_environment: GlobalConstant::Base.sub_environment_name
        }
      ).perform

      success
    end

  end

end
