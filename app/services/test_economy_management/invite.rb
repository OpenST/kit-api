module TestEconomyManagement

  class Invite < TestEconomyManagement::Base

    # Initialize
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [Hash] client (mandatory) - Client cache data
    # @params [Hash] manager (mandatory) - Manager cache data
    # @params [String] email_addresses (mandatory) - invited emails
    #
    # @return [TestEconomyManagement::Invite]
    #
    def initialize(params)

      super

      @emails_str = @params[:email_addresses]

      @email_arr = []
      @already_invited_emails_map = {}
    end

    # Perform
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = check_activation_status
        return r unless r.success?

        r = fetch_token
        return r unless r.success?

        r = check_invitee_emails
        return r unless r.success?

        r = check_total_invites
        return r unless r.success?

        r = create_email_hook
        return r unless r.success?

        prepare_response

      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = super
      return r unless r.success?

      r = validate_and_sanitize_invitee_emails
      return r unless r.success?

      success

    end

    # Validate and sanitize email addresses
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize_invitee_emails

      invalid_emails_present = false

      @emails_str.split(',').each do |email|
        email = email.downcase.strip
        next if email.blank?

        if Util::CommonValidator.is_valid_email?(email)
          @email_arr << email
        else
          invalid_emails_present = true
          break
        end
      end

      return validation_error(
          'tem_i_1',
          'invalid_api_params',
          ['token_demo_invite_invalid_email'],
          GlobalConstant::ErrorAction.default
      ) if invalid_emails_present

      return validation_error(
          'tem_i_2',
          'invalid_api_params',
          ['token_demo_invite_no_email'],
          GlobalConstant::ErrorAction.default
      ) if @email_arr.blank?

      return validation_error(
          'tem_i_6',
          'invalid_api_params',
          ['token_demo_invite_too_many_email'],
          GlobalConstant::ErrorAction.default
      ) if @email_arr.length > 10

      success

    end

    # Check if activation is complete or not
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def check_activation_status

      return success if registered_in_mappy_server? && test_economy_qr_code_uploaded?

      return error_with_data(
        'tem_i_3',
        'token_demo_setup_incomplete',
        GlobalConstant::ErrorAction.default
      )
    end

    # Check already invited emails
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def check_invitee_emails

      ::TestEconomyInvite.where(email: @email_arr, token_id: @token_id).all.each do |invite_obj|
        if invite_obj.last_invitation_timestamp + 24.hours.to_i >= Time.now.to_i
          return validation_error(
              'tem_i_4',
              'invalid_api_params',
              ['token_demo_reinvite_too_early'],
              GlobalConstant::ErrorAction.default
          )
        else
          @already_invited_emails_map[invite_obj.email] = invite_obj
        end
      end

      success

    end

    # Check total invites in given duration
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def check_total_invites

      total_invites = ::TestEconomyInvite.where("token_id=? AND last_invitation_timestamp>?", @token_id,
                                                (Time.now.to_i - 30.days.to_i)).count('id')

      return error_with_data(
        'tem_i_5',
        'token_demo_too_many_invites',
        GlobalConstant::ErrorAction.default
      ) if (total_invites + @email_arr.length) > 1000

      success

    end

    # Create email hook
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def create_email_hook

      email_template_vars = {
        qr_code_url: qr_code_s3_url,
        ios_app_download_link: GlobalConstant::DemoApp.ios_url,
        android_app_download_link: GlobalConstant::DemoApp.android_url,
        company_web_domain: GlobalConstant::CompanyWeb.domain
      }

      @email_arr.each do |email|

        invite_obj = @already_invited_emails_map[email].present? ?
                       @already_invited_emails_map[email] :
                       ::TestEconomyInvite.new(token_id: @token_id, email: email)
        invite_obj.last_invitation_timestamp = Time.now.to_i
        invite_obj.save!

        r = ::Email::HookCreator::SendTransactionalMail.new(
          receiver_entity_id: invite_obj.id,
          receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.test_economy_invite_receiver_entity_kind,
          template_name: GlobalConstant::PepoCampaigns.platform_test_economy_invite_template,
          template_vars: email_template_vars).perform
        return r unless r.success?

      end

      success
    end

    # prepare response
    #
    # * Author: Sunil
    # * Date: 25/04/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def prepare_response
      success
    end

  end

end
