module AdminManagement
  
  module Whitelist
  
    class Client < ServicesBase
    
      # Initialize
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @param [String] email (mandatory) - Email
      # @param [Integer] token_users_shard_number (optional) - shard number for token
      # @param [Integer] config_group_id (optional) - config group id
      #
      # @return [AdminManagement::Whitelist::Client]
      #
      def initialize(params)
        super
        @email = @params[:email]
        @token_users_shard_number = @params[:token_users_shard_number]
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

          validate_and_sanitize

          fetch_client

          find_or_create_client_preprovisioning

          find_or_create_client_whitelisting

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

        validate

        if GlobalConstant::Base.sandbox_sub_environment?
          fail OstCustomError.new validation_error(
                                      'um_w_d_1',
                                      'unauthorized_to_access_main_env',
                                      [],
                                      GlobalConstant::ErrorAction.default
                                  )
        end

        fetch_client

        token_details = KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).fetch[@client_id]
        if token_details.present? && token_details[:status] != GlobalConstant::ClientToken.not_deployed
          fail OstCustomError.new validation_error(
                                      'um_w_d_2',
                                      'data_validation_failed',
                                      [],
                                      GlobalConstant::ErrorAction.default
                                  )
        end

        @email = @email.downcase.strip

        unless Util::CommonValidator.is_valid_email?(@email)
          fail OstCustomError.new validation_error(
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

        fail OstCustomError.new validation_error(
                                    'um_w_d_4',
                                    'invalid_api_params',
                                    ['invalid_email'],
                                    GlobalConstant::ErrorAction.default
                                ) if manager.blank?

        @client_id = manager.current_client_id

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

        wd = ClientPreProvisoning.where(client_id: @client_id).first

        if wd.present?
          wd.config['config_group_id'] = @config_group_id if @config_group_id.present?
          wd.config['token_users_shard_number'] = @token_users_shard_number if @token_users_shard_number.present?
          wd.save!
        else
          config = {}
          config['config_group_id'] = @config_group_id if @config_group_id.present?
          config['token_users_shard_number'] = @token_users_shard_number if @token_users_shard_number.present?
          ClientPreProvisoning.create!(client_id: @client_id, config: config)
        end

        success

      end

    end
    
  end

end