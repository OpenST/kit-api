module Email

  module HookProcessor

    class SendTransactionalMail < Base

      # Initialize
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @param [EmailServiceApiCallHook] hook (mandatory) - db record of EmailServiceApiCallHook table
      #
      # @return [Email::HookProcessor::SendTransactionalMail] returns an object of Email::HookProcessor::SendTransactionalMail class
      #
      def initialize(params)
        super
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
        success
      end

      # Start processing hook
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def process_hook

        send_mail_params = @hook.params

        unless send_mail_params["template_vars"]["company_web_domain"].present?
          send_mail_params["template_vars"]["company_web_domain"] = CGI.escape(GlobalConstant::CompanyWeb.domain)
        end

        link = fetch_view_link(send_mail_params)

        send_mail_params["template_vars"]["view_link"] = link if link.present?

        send_mail_response = Email::Services::PepoCampaigns.new.send_transactional_email(
          @email,
          send_mail_params["template_name"],
          send_mail_params["template_vars"]
        )

        if send_mail_response['error'].present?
          error_with_data(
            'e_hp_stm_1',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default,
            send_mail_response
          )
        else
          success_with_data(send_mail_response)
        end

      end

      # Add extra template vars
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def fetch_view_link(send_mail_params)
        return success unless send_mail_params["template_vars"]["token_id"].present?

        token_id = send_mail_params["template_vars"]["token_id"].to_i # Cache expects this to be an integer

        client_mile_stone = ::ClientMileStone.new({})

        client_mile_stone.fetch_view_link(token_id, GlobalConstant::Environment.url_prefix)
      end

    end

  end

end
