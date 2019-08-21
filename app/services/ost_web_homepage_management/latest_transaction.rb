module OstWebHomepageManagement

  class LatestTransaction < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    #
    # @return
    #
    def initialize
      @latest_transactions_array = []
    end

    # Perform
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        r = validate_and_sanitize
        return r unless r.success?

        r = fetch_latest_transactions
        return r unless r.success?

        r = fetch_token_and_chain_ids
        return r unless r.success?

        r = fetch_tokens_data
        return r unless r.success?

        r = fetch_price_points_data
        return r unless r.success?

        response_data = {
          latest_transactions: @latest_transactions_array,
          tokens: @tokens_data,
          price_points: @price_points
        }

        success_with_data(response_data)
      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      r = validate
      return r unless r.success?

      success
    end

    # Fetch latest transactions
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_latest_transactions
      @latest_transactions_array = KitSaasSharedCacheManagement::LatestTransactions.new.fetch[:transactions]
      success
    end

    # Fetch token ids and chain ids from latest transactions array
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_token_and_chain_ids

      token_ids_hash = {}

      @latest_transactions_array.each do |latest_transaction|
        token_ids_hash[latest_transaction[:token_id]] = 1
      end

      @tokens_ids_array = token_ids_hash.keys

      success
    end

    # Fetch tokens data to prepare tokens entity
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_tokens_data
      @tokens_data = KitSaasSharedCacheManagement::TokenByTokenId.new(@tokens_ids_array).fetch
      success
    end

    # Fetch price points data for required chain ids
    #
    # * Author: Ankit
    # * Date: 20/08/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_price_points_data
      @price_points = CacheManagement::OstPricePointsDefault.new.fetch
      success
    end

  end
end