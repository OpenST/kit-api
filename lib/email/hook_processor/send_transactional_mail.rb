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

        @manager_ids = []
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

      # Fetch email from managers table
      #
      # * Author: Shlok
      # * Date: 11/03/20120
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def set_email

        if @hook[:receiver_entity_kind] == GlobalConstant::EmailServiceApiCallHook.client_all_super_admins_receiver_entity_kind
          r = set_manager_ids
          return r unless r.success?
        else
          super
        end

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

        if @hook[:receiver_entity_kind] == GlobalConstant::EmailServiceApiCallHook.client_all_super_admins_receiver_entity_kind
          @manager_ids.each do |manager_id|
            email_hook_creation_resp = Email::HookCreator::SendTransactionalMail.new(
              receiver_entity_id: manager_id,
              receiver_entity_kind: GlobalConstant::EmailServiceApiCallHook.manager_receiver_entity_kind,
              template_name: send_mail_params["template_name"],
              template_vars: send_mail_params["template_vars"]
            ).perform

            puts "email_hook_creation_resp ====== #{email_hook_creation_resp}"

            if email_hook_creation_resp['error'].present?
              error_with_data(
                'e_hp_stm_1',
                'something_went_wrong',
                GlobalConstant::ErrorAction.default,
                email_hook_creation_resp
              )
            else
              success_with_data(email_hook_creation_resp)
            end
          end
        end

        if @email.present?
          link = fetch_view_link(send_mail_params)
          send_mail_params["template_vars"]["view_link"] = CGI.escape(link) if link.present?
          send_mail_response = Email::Services::PepoCampaigns.new.send_transactional_email(
            @email,
            send_mail_params["template_name"],
            send_mail_params["template_vars"]
          )

          if send_mail_response['error'].present?
            error_with_data(
              'e_hp_stm_2',
              'something_went_wrong',
              GlobalConstant::ErrorAction.default,
              send_mail_response
            )
          else
            success_with_data(send_mail_response)
          end
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
        return nil unless send_mail_params["template_vars"]["token_id"].present?

        token_id = send_mail_params["template_vars"]["token_id"].to_i # Cache expects this to be an integer

        campaign_attribute_manager = CampaignAttributeManager.new({})

        campaign_attribute_manager.fetch_view_link(token_id, GlobalConstant::Environment.url_prefix)
      end

      # Select manager ids based on receiver entity kind
      #
      # * Author: Shlok
      # * Date: 09/03/2020
      # * Reviewed By:
      #
      # @Sets @manager_ids
      #
      # @return [Result::Base]
      #
      def set_manager_ids

        receiver_entity_id = @hook[:receiver_entity_id] # This is the client id.
        #TODO: Can we cache this query ?
        @manager_ids = ClientManager.super_admins(receiver_entity_id).pluck(:manager_id)


        success

      end

    end

  end

end
