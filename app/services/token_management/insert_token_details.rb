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
    # @params [String] stake_currency_symbol (mandatory) - stake currency symbol
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
      @stake_currency_symbol = @params[:stake_currency_symbol]

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

        r = fetch_staking_currency_id
        return r unless r.success?

        r = insert_update_token_details
        return r unless r.success?

        r = delete_old_addresses
        return r unless r.success?

        r = create_api_credentials
        return r unless r.success?

        r = fetch_token_details
        return r unless r.success?

        r = fetch_stake_currency_details
        return r unless r.success?

        success_with_data({
          token: @token,
          stake_currencies: @stake_currencies
         })

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
      @stake_currency_symbol = @stake_currency_symbol.to_s.strip.upcase

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

    # Fetch staking currency id
    #
    # * Author: Ankit
    # * Date: 23/04/2019
    # * Reviewed By:
    #
    # @return [Array]
    #
    def fetch_staking_currency_id

      stake_currency_data = StakeCurrency.symbols_to_details_cache
      unless stake_currency_data[@stake_currency_symbol].present?
        return validation_error(
          'a_tm_itd_3',
          'invalid_api_params',
          ['invalid_stake_currency_symbol'],
          GlobalConstant::ErrorAction.default
        )
      end

      @stake_currency_id = stake_currency_data[@stake_currency_symbol][:id]
      @stake_currency_decimal = stake_currency_data[@stake_currency_symbol][:decimal]

      success
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
      @token_details.stake_currency_id = @stake_currency_id
      @token_details.decimal = @stake_currency_decimal

      @token_details.save! if @token_details.changed?

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
      token_addresses = TokenAddresses.where(token_id: token_id, kind: GlobalConstant::TokenAddresses.owner_address_kind).first

      if token_addresses.present? && token_addresses.known_address_id.present?
        SaasApi::WalletAddress::RemoveKnownAddress.new.perform({known_address_id: token_addresses.known_address_id})
        token_addresses.destroy!
      end

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

    # Fetch token details
    #
    # * Author: Anagha
    # * Date: 08/03/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_details
      @token = @token_details.formatted_cache_data
      puts "@token==========#{@token}"
      success
    end

    # Fetch stake currency details.
    #
    # * Author: Anagha
    # * Date: 06/05/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_stake_currency_details
      if @token[:stake_currency_id].present?
        stake_currency_id = @token[:stake_currency_id]
        @stake_currencies = Util::EntityHelper.fetch_stake_currency_details(stake_currency_id).data

        @token[:stake_currency_symbol] = @stake_currencies.keys[0]
      end

      success
    end

  end

end