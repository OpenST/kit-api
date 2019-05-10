module WalletAddressesManagement

  class Base < ServicesBase

    # Initialize
    #
    # * Author: Ankit
    # * Date: 19/01/2019
    # * Reviewed By:
    #
    # @return [WalletAddressesManagement::Base]
    def initialize(params)
      super
    end


    # Fetch token details
    # Note: Need the row object to perform an update later. Thus data is fetched directly from database
    #
    # * Author: Ankit
    # * Date: 23/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_details
      @token = Token.where(client_id: @client_id).first
      @token_id = @token[:id]

      success
    end

    # Fetch token owner address
    #
    # * Author: Ankit
    # * Date: 25/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def fetch_token_owner_address
      # Fetch token addresses.
      token_addresses_data = KitSaasSharedCacheManagement::TokenAddresses.new([@token_id]).fetch || {}
      token_addresses = token_addresses_data[@token_id]
      @owner_address = token_addresses[GlobalConstant::TokenAddresses.owner_address_kind]

      success
    end

    # Return address entity
    #
    # * Author: Ankit
    # * Date: 25/04/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    def return_addresses_entity
      origin_addresses = {owner_address: @owner_address, admin: '', whitelisted: [], workers: []}
      auxiliary_addresses = {owner_address: @owner_address, admin: '', whitelisted: [], workers: []}

      success_with_data({
                          origin_addresses: origin_addresses,
                          auxiliary_addresses: auxiliary_addresses
                        })
    end
  end

end