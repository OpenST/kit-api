# frozen_string_literal: true
module GlobalConstant

  class PepoCampaigns

    class << self

      ########### Config ############

      def api_key
        config[:api][:key]
      end

      def api_secret
        config[:api][:secret]
      end

      def base_url
        config[:api][:base_url]
      end

      def version
        config[:api][:version]
      end

      def api_timeout
        5
      end

      ########### List Ids ############

      def master_list_id
        config[:list_ids][:master_list]
      end

      ########### User Custom Attributes #########


      def user_registered_attribute
        'user_registered'
      end

      def double_optin_done_attribute
        'double_optin_done'
      end


      def allowed_custom_attributes
        [
          user_registered_attribute,
          double_optin_done_attribute
        ]
      end

      ########### User Setting : Keys ############

      def double_opt_in_status_user_setting
        'double_opt_in_status'
      end

      def subscribe_status_user_setting
        'subscribe_status'
      end

      # def hardbounce_status_user_setting
      #   'hardbounce_status'
      # end
      #
      # def complaint_status_user_setting
      #   'complaint_status'
      # end

      ########### User Setting : Possible Values ############

      # def blacklisted_value
      #   'blacklisted'
      # end
      #
      # def unblacklisted_value
      #   'unblacklisted'
      # end
      #
      def verified_value
        'verified'
      end
      #
      # def pending_value
      #   'pending'
      # end

      def subscribed_value
        'subscribed'
      end

      # def unsubscribed_value
      #   'unsubscribed'
      # end

      ########### Transaction Email Templates ############

      ################ Custom Attribute Values ################

      def user_registered_value
        1
      end

      def double_optin_done_value
        1
      end

      ############# Custom Attribute Values ################

      # double optin email - sent when user is adding email for the first time
      def double_opt_in_template
        'ost_kit_double_optin'
      end

      # reset password email - sent when user clicks on forgot password
      def forgot_password_template
        'forgot_password'
      end

      # All possible templates integrated with email service
      #
      # * Author: Puneet
      # * Date: 11/10/2017
      # * Reviewed By:
      #
      # @return [Array]
      #
      def supported_templates
        [
          double_opt_in_template,
          forgot_password_template
        ]
      end

      # is this template related to double opt in email
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Boolean]
      #
      def is_double_opt_in_related_template?(template_name)
        [
          GlobalConstant::PepoCampaigns.double_opt_in_template
        ].include?(template_name)
      end

      # Is this template of forgot password
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Boolean]
      #
      def is_forgot_password_template?(template_name)
        [
            GlobalConstant::PepoCampaigns.forgot_password_template
        ].include?(template_name)
      end

      private

      def config
        GlobalConstant::Base.pepo_campaigns_config
      end

    end

  end

end
