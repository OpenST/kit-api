module ManagerManagement

  class SendResetPasswordLink < ServicesBase

    # Initialize
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # @params [String] email (mandatory) - this is the email entered
    #
    # @return [ManagerManagement::SendResetPasswordLink]
    #
    def initialize(params)

      super

      @email = @params[:email]

      @manager = nil
      @reset_password_token = nil

    end

    # Perform
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate

        fetch_user

        create_reset_password_token

        send_forgot_password_mail

        success

      end

    end

    private

    # Fetch user
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # Sets @manager
    #
    # @return [Result::Base]
    #
    def fetch_user

      @manager = Manager.where(email: @email).first

      error_key = ''
      if @manager.blank?
        error_key = 'unrecognized_email'
      elsif !@manager.is_eligible_for_reset_password?
        error_key = 'email_inactive'
      end

      fail OstCustomError.new validation_error(
          'um_srpl_1',
          'invalid_api_params',
          [error_key],
          GlobalConstant::ErrorAction.default
      ) if error_key.present?

      success

    end

    # Create Reset Password Token
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    # Sets @reset_password_token
    #
    # @return [Result::Base]
    #
    def create_reset_password_token

      reset_token = LocalCipher.get_sha_hashed_text(
          "#{@manager.id}::#{@manager.password}::#{Time.now.to_i}::reset_password::#{rand}"
      )

      db_row = ManagerValidationHash.create!(
        manager_id: @manager.id,
        kind: GlobalConstant::ManagerValidationHash.reset_password_kind,
        validation_hash: reset_token,
        status: GlobalConstant::ManagerValidationHash.active_status
      )

      reset_pass_token_str = "#{db_row.id.to_s}:#{reset_token}"
      encryptor_obj = EmailTokenEncryptor.new(GlobalConstant::SecretEncryptor.email_tokens_key)
      r = encryptor_obj.encrypt(reset_pass_token_str)
      fail OstCustomError.new(r) unless r.success?

      @reset_password_token = r.data[:ciphertext_blob]

      success

    end

    # Send forgot password_mail
    #
    # * Author: Pankaj
    # * Date: 11/01/2018
    # * Reviewed By:
    #
    def send_forgot_password_mail
      puts "@reset_password_token: #{@reset_password_token}"
      Email::HookCreator::SendTransactionalMail.new(
          email: @manager.email,
          template_name: GlobalConstant::PepoCampaigns.forgot_password_template,
          template_vars: {
              reset_password_token: CGI.escape(@reset_password_token),
              company_web_domain: GlobalConstant::CompanyWeb.domain
          }
      ).perform
    end

  end

end
