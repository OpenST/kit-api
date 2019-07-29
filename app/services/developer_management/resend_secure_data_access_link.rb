module DeveloperManagement

  class ResendSecureDataAccessLink < ServicesBase

    # Initialize
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By: Kedar
    #
    # @params [String] manager_id (mandatory) - id of manager to which mail is to be sent
    #
    # @return [DeveloperManagement::ResendSecureDataAccessLink]
    #
    def initialize(params)
      super

      @manager_id = @params[:manager_id]

    end

    # Perform
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate
        return r unless r.success?

        r = fetch_manager_validation_hash_details
        return r unless r.success?

        r = create_secure_data_acccess_token
        return r unless r.success?

        r = send_mail
        return r unless r.success?

        success_with_data({manager_validation_hash_id: @manager_validation_hash[:id]})

      end

    end

    private

    # Fetch manager validation hash details for given manager id
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By:
    #
    # Sets @manager_validation_hash
    #
    def fetch_manager_validation_hash_details

      mvh_record = ManagerValidationHash.where(
        manager_id: @manager_id,
        kind: GlobalConstant::ManagerValidationHash.secure_data_access_kind).order('created_at desc').limit(1)

      return error_with_data(
        's_dm_rsdal_1',
        'something_went_wrong',
        GlobalConstant::ErrorAction.default
      ) unless mvh_record.present?

      @manager_validation_hash = mvh_record[0]

      success

    end

    # Create Secure Data Access Token
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By:
    #
    # Sets @secure_data_access_token
    #
    def create_secure_data_acccess_token

      manager_validation_hash_id = @manager_validation_hash[:id]
      validation_hash = @manager_validation_hash[:validation_hash]

      sda_token_str = "#{manager_validation_hash_id}:#{current_timestamp}:#{validation_hash}"
      encryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = encryptor_obj.encrypt(sda_token_str, GlobalConstant::ManagerValidationHash::secure_data_access_kind)
      return r unless r.success?

      @secure_data_access_token = r.data[:ciphertext_blob]

      success

    end

    # Send mail
    # Send secure data access verification mail
    #
    # * Author: Dhananjay
    # * Date: 04/06/2019
    # * Reviewed By:
    #
    def send_mail
      Email::HookCreator::SendTransactionalMail.new(
        receiver_entity_id: @manager_id,
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
        template_name: GlobalConstant::PepoCampaigns.platform_secure_data_access_template,
        template_vars: {
          secure_data_access_token: CGI.escape(@secure_data_access_token),
          company_web_domain: CGI.escape(GlobalConstant::CompanyWeb.domain)
        }
      ).perform

      success
    end

  end

end
