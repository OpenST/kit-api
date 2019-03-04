class TokenCompanyUser < DbConnection::KitSaasSubenv

  include Util::ResultHelper

  # Format data to a format which goes into cache
  #
  # * Author: Shlok
  # * Date: /03/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formated_cache_data
    {
      token_id: token_id,
      userUuids: user_uuid
    }
  end

  # Fetch all company uuids for token ids passed.
  #
  # * Author: Shlok
  # * Date: /03/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def fetch_all_uuids(params)
    @token_ids = params[:token_ids]

    @return_data = []
    company_uuids = TokenCompanyUsers.where(token_id: @token_ids).all

    company_uuids.each do |token_address_row|
      @return_data[token_address_row.token_id] ||= []
      @return_data[token_address_row.token_id].push(token_address_row.user_uuid)
    end
    success_with_data(@return_data)
  end

end
