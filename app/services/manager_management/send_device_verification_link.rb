module ManagerManagement

  class SendDeviceVerificationLink < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 21/05/2019
    # * Reviewed By:
    #
    # @params [String] manager_id (mandatory) - id of manager to which mail is to be sent
    # @params [String] manager_device_id (mandatory) - manager device id
    #
    # @return [ManagerManagement::SendDeviceVerificationLink]
    #
    def initialize(params)
      super

      @manager_id = @params[:manager_id]
      @manager_device_id = @params[:manager_device_id]

      @manager = nil
      @manager_s = nil
      @device_verification_token = nil

    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 21/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate
        return r unless r.success?

        r = fetch_manager_device
        return r unless r.success?

        r = create_device_verification_token
        return r unless r.success?

        r = send_device_verification_token
        return r unless r.success?

        success

      end

    end

    private

    # Fetch user
    #
    # * Author: Ankit
    # * Date: 21/05/2019
    # * Reviewed By:
    #
    # Sets @manager, @manager_device
    #
    # @return [Result::Base]
    #
    def fetch_manager_device

      @manager = CacheManagement::Manager.new([@manager_id]).fetch[@manager_id]
      @manager_device = CacheManagement::ManagerDeviceById.new([@manager_device_id]).fetch[@manager_device_id]

      return error_with_data(
        'a_s_mm_sdv_1',
        'something_went_wrong',
        GlobalConstant::ErrorAction.default
      ) if !@manager_device.present? || @manager_device[:status] != GlobalConstant::ManagerDevice.un_authorized

      success

    end

    # Create Device Verification Token
    #
    # * Author: Ankit
    # * Date: 21/05/2019
    # * Reviewed By:
    #
    # Sets @device_verification_token
    #
    # @return [Result::Base]
    #
    def create_device_verification_token

      device_verification_token = LocalCipher.get_sha_hashed_text(
          "#{@manager[:id]}::#{@manager_device[:id]}::#{current_timestamp}::device_verification::#{rand}"
      )
      db_row = ManagerValidationHash.create!(
          manager_id: @manager[:id],
          kind: GlobalConstant::ManagerValidationHash.device_verification_kind,
          validation_hash: device_verification_token,
          status: GlobalConstant::ManagerValidationHash.active_status,
          extra_data: {manager_device_id: @manager_device[:id]}
      )

      device_verification_token_str = "#{db_row.id.to_s}:#{device_verification_token}"
      encryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = encryptor_obj.encrypt(device_verification_token_str, GlobalConstant::ManagerValidationHash::device_verification_kind)
      return r unless r.success?

      @device_verification_token = r.data[:ciphertext_blob]

      success

    end

    # Send Device Verification mail
    #
    # * Author: Ankit
    # * Date: 27/05/2018
    # * Reviewed By:
    #
    def send_device_verification_token
      Email::HookCreator::SendTransactionalMail.new(
          receiver_entity_id: @manager_id,
          receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
          template_name: GlobalConstant::PepoCampaigns.platform_device_verification_template,
          template_vars: {
              device_verification_token: CGI.escape(@device_verification_token),
              company_web_domain: GlobalConstant::CompanyWeb.domain
          }
      ).perform

      success
    end

  end

end
