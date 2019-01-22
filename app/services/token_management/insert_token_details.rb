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
    #
    # @return [TokenManagement::TokenDetails]
    #
    def initialize(params)

      super

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

        fetch_and_validate_token

        validate_and_sanitize

        insert_update_token_details

        delete_old_addresses

        success_with_data({token: @token_details.formated_cache_data})

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

      @token_name = @token_name.to_s.strip
      @token_symbol = @token_symbol.to_s.strip

      validation_errors = validate_token_creation_params

      if validation_errors.present?
        return validation_error(
          'a_tm_itd_1',
          'invalid_api_params',
          validation_errors,
          GlobalConstant::ErrorAction.default
        )
      end

      validate

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

      if Token.where('client_id != ? AND name = ?', @client_id, @name).first.present?
        validation_errors.push('duplicate_token_name')
      end

      if Token.where('client_id != ? AND symbol = ?', @client_id, @symbol).first.present?
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
      #TODO: @shlok - Shouldn't there be a check first if the same token already exists?
      @token_details ||= Token.new(client_id: @client_id)

      @token_details.name = @name
      @token_details.symbol = @symbol
      @token_details.conversion_factor = @conversion_factor

      @token_details.save!

      CacheManagement::TokenDetails.new([@client_id]).clear

      success
    end

    # TODO: <VERY IMPORTANT> Need to check if the deployment is completed or initiated. If yes then there should not be any modification
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
      ClientWalletAddress.where('client_id = ?', @client_id).destroy_all
      TokenAddresses.where('token_id = ?', token_id).destroy_all

      success
    end

  end

end