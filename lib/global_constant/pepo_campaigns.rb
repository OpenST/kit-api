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

      def platform_marketing_attribute
        'platform_marketing'
      end

      def platform_signup_attribute
        'platform_signup'
      end

      def platform_double_optin_done_attribute
        'platform_double_optin_done'
      end

      def manager_first_name_attribute
        'First Name' #Attribute name as given in pepo campaigns.
      end

      def manager_last_name_attribute
        'Last Name' #Attribute name as given in pepo campaigns.
      end


      def allowed_custom_attributes
        [
          platform_signup_attribute,
          platform_double_optin_done_attribute,
          platform_marketing_attribute,
          manager_first_name_attribute,
          manager_last_name_attribute
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

      def platform_signup_value
        1
      end

      def platform_double_optin_done_value
        1
      end

      def platform_marketing_value_true
        1
      end

      def platform_marketing_value_false
        0
      end

      ############# Custom Attribute Values ################

      # double optin email - sent when user is adding email for the first time
      def platform_double_optin_template
        'platform_double_optin'
      end

      # device authorization email - sent when user is trying to access platform from a new device or browser.
      def platform_device_verification_template
        'platform_authorize_new_device'
      end

      # reset password email - sent when user clicks on forgot password
      def platform_forgot_password_template
        'platform_forgot_password'
      end

      # invite manager email - sent when manager is invited to a client
      def platform_invite_manager_template
        'platform_invite_manager'
      end

      # Request mainnet  - sent when client requests to get whitelisted for mainnet
      def platform_mainnet_access_request_template
        'platform_mainnet_access_request'
      end

      # Secure data access - sent when secure_data_access is required for developer's page
      def platform_secure_data_access_template
        'platform_secure_data_access'
      end

      # Platform whitelisting done  - sent when platform whitelisting is done
      def platform_whitelisting_done_template
        'platform_whitelist_done'
      end

      # Platform test economy invite  - sent when user is invited to platform test economy
      def platform_test_economy_invite_template
        'platform_test_economy_invite'
      end

      # Initiate Recovery - sent when recovery is initiated from saas-api
      def recovery_request_submission_template
        'recovery_request_submission'
      end

      # Platform usage report to get an idea of the funnel
      def platform_usage_report_template
        'platform_usage_report'
      end

      # Platform token setup status successful
      def platform_token_setup_status_success_template
        'platform_token_setup_status_success'
      end

      # Platform token setup status failes
      def platform_token_setup_status_failed_template
        'platform_token_setup_status_failed'
      end

      # Platform stake and mint status successful
      def platform_stake_and_mint_status_success_template
        'platform_stake_and_mint_status_success'
      end

      # Platform token setup status failes
      def platform_stake_and_mint_status_failed_template
        'platform_stake_and_mint_status_failed'
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
          platform_double_optin_template,
          platform_forgot_password_template,
          platform_invite_manager_template,
          platform_device_verification_template,
          platform_mainnet_access_request_template,
          platform_secure_data_access_template,
          platform_test_economy_invite_template,
          recovery_request_submission_template,
          platform_whitelisting_done_template,
          platform_token_setup_status_success_template,
          platform_token_setup_status_failed_template,
          platform_stake_and_mint_status_success_template,
          platform_stake_and_mint_status_failed_template
        ]
      end

      # is this template related to device verification email
      #
      # * Author: Ankit
      # * Date: 21/05/2019
      # * Reviewed By:
      #
      # @return [Boolean]
      #
      def is_device_verification_related_template?(template_name)
        GlobalConstant::PepoCampaigns.platform_device_verification_template == template_name
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
        GlobalConstant::PepoCampaigns.platform_double_optin_template == template_name
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
        GlobalConstant::PepoCampaigns.platform_forgot_password_template == template_name
      end

      # Is this template of manager invite
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Boolean]
      #
      def is_manager_invite_template?(template_name)
        GlobalConstant::PepoCampaigns.platform_invite_manager_template == template_name
      end

      # Is this template of whitelist request
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Boolean]
      #
      def is_mainnet_whitelisting_template?(template_name)
        GlobalConstant::PepoCampaigns.platform_mainnet_access_request_template == template_name
      end

      # Is this template of initiate recovery
      #
      # * Author: Dhananjay
      # * Date: 13/03/2019
      # * Reviewed By:
      #
      # @return [Boolean]
      #
      def is_recovery_request_submission_template?(template_name)
        GlobalConstant::PepoCampaigns.recovery_request_submission_template == template_name
      end

      # Is this template of test economy invite
      #
      # * Author: Sunil
      # * Date: 25/04/2019
      # * Reviewed By: Puneet
      #
      # @return [Boolean]
      #
      def is_test_economy_invite_template?(template_name)
        GlobalConstant::PepoCampaigns.platform_test_economy_invite_template == template_name
      end

      private

      def config
        GlobalConstant::Base.pepo_campaigns_config
      end

    end

  end

end
