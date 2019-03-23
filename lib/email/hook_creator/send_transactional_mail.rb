module Email

  module HookCreator

    class SendTransactionalMail < Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @param [String] template_name (mandatory) - Template Name
      # @param [Hash] template_vars (mandatory) - Template Vars
      #
      #
      # @return [Email::HookCreator::SendTransactionalMail]  returns an object of Email::HookCreator::SendTransactionalMail class
      #
      def initialize(params)
        super
        @template_name = params[:template_name]
        @template_vars = params[:template_vars]
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def perform
        super
      end

      private

      # Validate
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate

        r = validate_template_name
        return r unless r.success?

        validate_template_vars

      end

      # Event type
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [String] event type that goes into hook table
      #
      def event_type
        GlobalConstant::EmailServiceApiCallHook.send_transactional_mail_event_type
      end

      # check if this template is supported currently
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate_template_name
        GlobalConstant::PepoCampaigns.supported_templates.include?(@template_name) ? success : error_with_data(
          'e_hc_stm_3',
          'something_went_wrong',
          GlobalConstant::ErrorAction.default,
          {template_name: @template_name}
        )
      end

      # depending on template name validate mandatory template vars
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate_template_vars
        
        return error_with_data(
            'e_hc_stm_6',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default
        ) if @template_vars[:company_web_domain].blank?

        if GlobalConstant::PepoCampaigns.is_double_opt_in_related_template?(@template_name)

          return error_with_data(
            'e_hc_stm_4',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default
          ) if @template_vars[:double_opt_in_token].blank?

        elsif GlobalConstant::PepoCampaigns.is_forgot_password_template?(@template_name)

          return error_with_data(
              'e_hc_stm_5',
              'something_went_wrong',
              GlobalConstant::ErrorAction.default
          ) if @template_vars[:reset_password_token].blank?

        elsif GlobalConstant::PepoCampaigns.is_manager_invite_template?(@template_name)

          return error_with_data(
              'e_hc_stm_6',
              'something_went_wrong',
              GlobalConstant::ErrorAction.default
          ) if @template_vars[:invite_token].blank?

        elsif GlobalConstant::PepoCampaigns.is_mainnet_whitelisting_template?(@template_name)

          return error_with_data(
            'e_hc_stm_7',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default
          ) if @template_vars[:manager_email_id].blank?

        elsif GlobalConstant::PepoCampaigns.is_recovery_request_submission_template?(@template_name)
  
          return error_with_data(
            'e_hc_stm_8',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default
          ) if @template_vars[:manager_email_id].blank?

        end

        success

      end

      # create a hook to send transactional email
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def handle_event

        create_hook(
          {
            template_name: @template_name,
            template_vars: @template_vars
          }
        )

        success

      end

    end

  end

end
