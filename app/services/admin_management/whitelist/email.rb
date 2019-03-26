module AdminManagement

  module Whitelist

    class Email < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 18/03/2019
      # * Reviewed By: Kedar
      #
      # @params [String] e (mandatory) - email which needs to be whitelisted
      #
      # @return [AdminManagement::Whitelist::Email]
      #
      def initialize(params)
        super

        @email = @params[:e]
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 18/03/2019
      # * Reviewed By: Kedar
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          find_or_create_record

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 18/03/2019
      # * Reviewed By: Kedar
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        @email = @email.downcase.strip

        unless Util::CommonValidator.is_valid_email?(@email)
          return validation_error(
              'am_w_e_1',
              'invalid_api_params',
              ['invalid_email'],
              GlobalConstant::ErrorAction.default
          )
        end

        success

      end

      # Find or create record
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By: Kedar
      #
      # @return [Result::Base]
      #
      def find_or_create_record

        #check if the email has already signed up.
        manager_record = Manager.where(email: @email).first

        if manager_record.present?
          return validation_error(
            'am_w_e_2',
            'invalid_api_params',
            ['email_already_signed_up'],
            GlobalConstant::ErrorAction.default
          )
        end

        record = ManagerWhitelisting.where(
          kind: GlobalConstant::ManagerWhitelisting.email_kind,
          identifier: @email
        ).first

        if record.present?
          return validation_error(
            'am_w_e_3',
            'invalid_api_params',
            ['email_already_whitelisted'],
            GlobalConstant::ErrorAction.default
          )
        end

        create_response = ManagerWhitelisting.create!(
          kind: GlobalConstant::ManagerWhitelisting.email_kind,
          identifier: @email
        )

        template_vars = {company_web_domain: GlobalConstant::CompanyWeb.domain}

        r = ::Email::HookCreator::SendTransactionalMail.new(
          receiver_entity_id: create_response.id,
          receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.whitelisting_requester_kind,
          template_name: GlobalConstant::PepoCampaigns.platform_whitelisting_done_template,
          template_vars: template_vars).perform
        return r unless r.success?

        success

      end

    end

  end

end