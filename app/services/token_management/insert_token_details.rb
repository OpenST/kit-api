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

        insert_token_details

        success_with_data({})

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

      return validation_error(
        'um_su_1',
        'invalid_api_params',
        validation_errors,
        GlobalConstant::ErrorAction.default
      ) if validation_errors.present?

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

      if Token.where('name = ?', @name).first.present?
        validation_errors.push('duplicate_token_name')
      end

      if Token.where('symbol = ?', @symbol).first.present?
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
    def insert_token_details
      Token.create!(
        client_id: @client_id,
        name: @name,
        symbol: @symbol,
        conversion_factor: @conversion_factor
      )
      CacheManagement::TokenDetails.new(client_id: @client_id).clear

      success
    end

  end

end