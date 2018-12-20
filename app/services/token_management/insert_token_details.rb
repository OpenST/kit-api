module TokenManagement

  class InsertTokenDetails < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @params [Integer] client_id (mandatory) - Client Id
    #
    # @return [TokenManagement::TokenDetails]
    #
    def initialize(params)

      super

      @client_id = @params[:client_id]
      @name = @params[:name]
      @symbol = @params[:symbol]
      @conversion_factor = @params[:conversion_factor]

    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 19/12/2018
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

        success_with_data({token: @token_details.formated_cache_data})

      end

    end

    #private

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 19/12/2018
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

      # NOTE: To be on safe side, check for generic errors as well
      r = validate
      return r unless r.success?

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
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    def insert_update_token_details
      @token_details = Token.where(client_id: @client_id).first
      @token_details ||= Token.new(client_id: @client_id)

      @token_details.name = @name
      @token_details.symbol = @symbol
      @token_details.conversion_factor = @conversion_factor

      @token_details.save!

      CacheManagement::TokenDetails.new([@client_id]).clear

      success
    end

    # Delete old addresses which were present in wallet_addresses and token_addresses table
    #
    #
    # * Author: Ankit
    # * Date: 19/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    def delete_old_addresses
      #fetch token id
      # delete if any address present in token addresses table and client_wallet_addresses table

      token_id = @token_details.id
      ClientWalletAddress.where('client_id = ?', @client_id).delete_all
      TokenAddresses.where('token_id = ?', token_id).delete_all

      success
    end

  end

end