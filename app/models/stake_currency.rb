class StakeCurrency < DbConnection::KitSaasSubenv

  enum status: {
    GlobalConstant::StakeCurrency.setup_in_progress_status => 1,
    GlobalConstant::StakeCurrency.active_status => 2,
    GlobalConstant::StakeCurrency.inactive_status => 3
  }

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
      constants: constants,
      status: status
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

  # Symbol to details cache ONLY of active stake currencies
  #
  # * Author: Shlok
  # * Date: 15/05/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def self.active_stake_currencies_by_symbol
    @active_stake_currencies_by_symbol ||= begin
      StakeCurrency.symbols_to_details_cache.select { |_,data| data[:status] == GlobalConstant::StakeCurrency.active_status}
    end
  end

end