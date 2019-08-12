module AdminManagement
  
  module Whitelist
  
    class Client < ServicesBase
    
      # Initialize
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @params [String] email (mandatory) - Email
      # @params [Integer] token_users_shard_number (optional) - shard number for token
      # @params [Integer] balance_shard_number (optional) -
      # @params [Integer] config_group_id (optional) - config group id
      #
      # @return [AdminManagement::Whitelist::Client]
      #
      def initialize(params)
        super
        @email = @params[:email]
        @token_users_shard_number = @params[:token_users_shard_number]
        @balance_shard_number = @params[:balance_shard_number]
        @config_group_id = @params[:config_group_id]
        @client_id = nil
      end
    
      # Perform
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def perform

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          r = fetch_client
          return r unless r.success?

          r = find_or_create_client_preprovisioning
          return r unless r.success?

          r = find_or_create_client_whitelisting
          return r unless r.success?

          r = enforce_mfa_and_mark_client_as_whitelisted_for_mainnet
          return r unless r.success?

          success

        end
    
      end
    
      private
      
      # Validate and sanitize
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        if GlobalConstant::Base.sandbox_sub_environment?
          return validation_error(
            'um_w_d_1',
            'unauthorized_to_access_main_env',
            [],
            GlobalConstant::ErrorAction.default
          )
        end

        r = fetch_client
        return r unless r.success?

        token_details = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id]
        if token_details.present? && token_details[:status] != GlobalConstant::ClientToken.not_deployed
          return validation_error(
            'um_w_d_2',
            'data_validation_failed',
            [],
            GlobalConstant::ErrorAction.default
          )
        end

        @email = @email.downcase.strip

        unless Util::CommonValidator.is_valid_email?(@email)
          return validation_error(
            'um_w_d_3',
            'invalid_api_params',
            ['invalid_email'],
            GlobalConstant::ErrorAction.default
          )
        end

        success

      end

      # Fetch client for this email
      #
      # * Author: Puneet
      # * Date: 28/01/2019
      # * Reviewed By:
      #
      # Sets @client_id
      #
      # @return [Result::Base]
      #
      def fetch_client

        manager = Manager.where(email: @email).select(:current_client_id).first

        if manager.blank?
          return validation_error(
            'um_w_d_4',
            'invalid_api_params',
            ['invalid_email'],
            GlobalConstant::ErrorAction.default
          )
        end

        @client_id = manager.current_client_id

        success
      end

      # Find or create record
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def find_or_create_client_whitelisting
  
        wd = ClientWhitelisting.where(client_id: @client_id).first
        
        unless wd.present?
          ClientWhitelisting.create!(client_id: @client_id)
        end
  
        success

      end

      # Find or create record
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def find_or_create_client_preprovisioning

        wd = ClientPreProvisioning.where(client_id: @client_id).first

        if wd.present?
          wd.config['config_group_id'] = @config_group_id if @config_group_id.present?
          wd.config['token_users_shard_number'] = @token_users_shard_number if @token_users_shard_number.present?
          wd.config['balance_shard_number'] = @balance_shard_number if @balance_shard_number.present?
          wd.save!
        else
          config = {}
          config['config_group_id'] = @config_group_id if @config_group_id.present?
          config['balance_shard_number'] = @balance_shard_number if @balance_shard_number.present?
          config['token_users_shard_number'] = @token_users_shard_number if @token_users_shard_number.present?
          ClientPreProvisioning.create!(client_id: @client_id, config: config)
        end

        success

      end

      # Enforce MFA and Whitelist the client in client table
      # * Author: Ankit
      # * Date: 30/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      def enforce_mfa_and_mark_client_as_whitelisted_for_mainnet

        column_name, value = ::Client.send("get_bit_details_for_#{GlobalConstant::Client.has_enforced_mfa_property}")

        clubbed_properties = {}
        clubbed_properties[column_name] = value

        column_name, value = ::Client.send("get_bit_details_for_#{GlobalConstant::Client.mainnet_whitelisted_status}")
        clubbed_properties[column_name] |= value

        update_strings = []
        clubbed_properties.each do |column_name, value|
          update_strings.push("#{column_name} = #{column_name} | #{value}")
        end

        update_string = update_strings.join(',')
        ::Client.where(id: @client_id).update_all([update_string])

        ::Client.deliberate_cache_flush(@client_id)

        success
      end

    end
    
  end

end