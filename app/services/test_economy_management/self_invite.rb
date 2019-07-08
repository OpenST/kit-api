module TestEconomyManagement

  class SelfInvite < ServicesBase

    # Invite self email to receive economy join email
    #
    # * Author: Pankaj
    # * Date: 08/07/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [String] email_address (mandatory) - users's email to receive economy email
    #
    # @return [TestEconomyManagement::Invite]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @email = @params[:email_address]
    end

    # Perform
    #
    # * Author: Pankaj
    # * Date: 08/07/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = send_invite_email
        return r unless r.success?

        r = add_email_for_future_communications
        return r unless r.success?

        success

      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Pankaj
    # * Date: 08/07/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      token_resp = Util::EntityHelper.fetch_and_validate_token(@client_id, 'tem_si')
      return token_resp unless token_resp.success?

      return validation_error(
          'tem_si_1',
          'invalid_api_params',
          ['token_demo_invite_invalid_email'],
          GlobalConstant::ErrorAction.default
      ) if !Util::CommonValidator.is_valid_email?(@email)

      success

    end

    # Add contact
    #
    # @return [Result::Base]
    #
    def add_email_for_future_communications

      ::Email::HookCreator::AddContact.new(
          receiver_entity_id: 0,
          receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.specific_email_receiver_entity_kind,
          receiver_email: @email
      ).perform

    end

    # Send Invite email
    #
    # @return [Result::Base]
    #
    def send_invite_email

      ::Email::HookCreator::SendTransactionalMail.new(
        receiver_entity_id: 0,
        receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.specific_email_receiver_entity_kind,
        receiver_email: @email,
        template_name: GlobalConstant::PepoCampaigns.platform_test_economy_invite_template,
        template_vars: {}).perform

    end

  end

end
