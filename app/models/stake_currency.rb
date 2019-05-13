class StakeCurrency < DbConnection::KitSaasSubenv

  serialize :constants, JSON

  # Format data to a format which goes into cache
  #
  # * Author: Santhosh
  # * Date: 11/04/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formatted_cache_data
    {
      id: id,
      name: name,
      symbol: symbol,
      decimal: decimal,
      contract_address: contract_address,
      price_oracle_contract_address: price_oracle_contract_address,
      constants: constants
    }
  end

  # Fetch from db
  #
  # * Author: Santhosh
  # * Date: 11/04/2019
  # * Reviewed By:
  #
  # @return [Array]
  #
  def self.fetch_from_db
    data = []
    StakeCurrency.all.each do |row|
      data << row.formatted_cache_data
    end
    data
  end

  # Id to details cache
  #
  # * Author: Santhosh
  # * Date: 11/04/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def self.ids_to_details_cache
    @ids_to_details_cache ||= begin
      data = {}
      StakeCurrency.fetch_from_db.each do |row|
        data[row[:id]] = row
      end
      data
    end
  end

  # Symbol to details cache
  #
  # * Author: Santhosh
  # * Date: 11/04/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def self.symbols_to_details_cache
    @symbols_to_details_cache ||= begin
      data = {}
      StakeCurrency.fetch_from_db.each do |row|
        data[row[:symbol]] = row
      end
      data
    end
  end

end