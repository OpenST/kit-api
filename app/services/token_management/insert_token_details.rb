module TokenManagement

  class InsertTokenDetails < TokenManagement::Base

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    # @params [String] name (mandatory) - Token name
    # @params [String] symbol (mandatory) - Token symbol
    # @params [String] conversion_factor (mandatory) - Conversion factor
    # @params [Hash] client_manager (mandatory) - logged in client manager object
    #
    # @return [TokenManagement::InsertTokenDetails]
    #
    def initialize(params)

      super

      @client_manager = @params[:client_manager]
      @name = @params[:name]
      @symbol = @params[:symbol]
      @conversion_factor = @params[:conversion_factor]

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = insert_update_token_details
        return r unless r.success?

        r = delete_old_addresses
        return r unless r.success?

        r = create_api_credentials
        return r unless r.success?

        success_with_data({token: @token_details.formatted_cache_data})

      end

    end

    #private

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      @name = @name.to_s.strip
      @symbol = @symbol.to_s.strip.upcase

      validation_errors = validate_token_creation_params

      if validation_errors.present?
        return validation_error(
          'a_tm_itd_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        )
      end

      success

    end

    # validate
    #
    # * Author: Kedar
    # * Date: 22/02/2019
    # * Reviewed By: Puneet
    #
    # @return [Result::Base]
    #
    def validate
      r = super
      return r unless r.success?

      r = ManagerManagement::Team::CheckSuperAdminRole.new(
        {client_manager: @client_manager}).perform

      unless r.success?
        return error_with_data(
          's_tm_itd_1',
          'unauthorized_to_perform_action',
          GlobalConstant::ErrorAction.default
        )
      end

      success
    end


    # Validate token creation params
    #
    # * Author: Puneet
    # * Date: 02/02/2018
    # * Reviewed By: Sunil
    #
    # @return [Array]
    #
    def validate_token_creation_params

      validation_errors = []

      unless Util::CommonValidator.is_valid_token_symbol?(@symbol)
        validation_errors.push('invalid_token_symbol')
      end

      unless Util::CommonValidator.is_valid_token_name?(@name)
        validation_errors.push('invalid_token_name')
      end

      if Util::CommonValidator.has_stop_words?(@name)
        validation_errors.push('inappropriate_token_name')
      end

      if Util::CommonValidator.has_stop_words?(@symbol)
        validation_errors.push('inappropriate_token_symbol')
      end

      @conversion_factor = BigDecimal.new(@conversion_factor.to_s)

      validation_errors.push('invalid_conversion_factor') if @conversion_factor <= 0

      if Token.where('(client_id != ? || client_id IS NULL) AND name = ?', @client_id, @name).first.present?
        validation_errors.push('duplicate_token_name')
      end

      if Token.where('(client_id != ? || client_id IS NULL) AND symbol = ?', @client_id, @symbol).first.present?
        validation_errors.push('duplicate_token_symbol')
      end

      validation_errors

    end

    # Insert token details
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def insert_update_token_details
      @token_details = Token.where(client_id: @client_id).first
      @token_details ||= Token.new(client_id: @client_id)

      @token_details.name = @name
      @token_details.symbol = @symbol
      @token_details.conversion_factor = @conversion_factor
      @token_details.delayed_recovery_interval = GlobalConstant::ClientToken.delayed_recovery_interval

      @token_details.save!

      KitSaasSharedCacheManagement::TokenDetails.new([@client_id]).clear

      success
    end

    # Delete old addresses which were present in wallet_addresses and token_addresses table
    #
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def delete_old_addresses
      # Fetch token id
      # delete if any address present in token addresses table and client_wallet_addresses table

      token_id = @token_details.id
      ClientWalletAddress.where(client_id: @client_id, sub_environment: GlobalConstant::Base.sub_environment_name ).destroy_all
      TokenAddresses.where(token_id: token_id, kind: GlobalConstant::TokenAddresses.owner_address_kind).destroy_all

      KitSaasSharedCacheManagement::TokenAddresses.new([token_id]).clear

      success
    end

    # Create api credentials
    #
    #
    # * Author: Santhosh
    # * Date: 08/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def create_api_credentials
      ::ApiCredentials::Create.new({client_id:@client_id}).perform
    end

  end

end