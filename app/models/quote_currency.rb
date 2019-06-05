class QuoteCurrency < DbConnection::KitSaasSubenv

  enum status: {
      GlobalConstant::QuoteCurrency.active_status => 1,
      GlobalConstant::QuoteCurrency.inactive_status => 2
  }

  serialize :constants, JSON

  # Format data to a format which goes into cache
  #
  # * Author: Santhosh
  # * Date: 05/06/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def formatted_cache_data
    {
        id: id,
        name: name,
        symbol: symbol,
        status: status
    }
  end

  # Fetch from db
  #
  # * Author: Santhosh
  # * Date: 05/06/2019
  # * Reviewed By:
  #
  # @return [Array]
  #
  def self.fetch_from_db
    data = []
    QuoteCurrency.all.each do |row|
      data << row.formatted_cache_data
    end
    data
  end

  # Id to details cache
  #
  # * Author: Santhosh
  # * Date: 05/06/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def self.ids_to_details_cache
    @ids_to_details_cache ||= begin
      data = {}
      QuoteCurrency.fetch_from_db.each do |row|
        data[row[:id]] = row
      end
      data
    end
  end

  # Symbol to details cache
  #
  # * Author: Santhosh
  # * Date: 05/06/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def self.symbols_to_details_cache
    @symbols_to_details_cache ||= begin
      data = {}
      QuoteCurrency.fetch_from_db.each do |row|
        data[row[:symbol]] = row
      end
      data
    end
  end

  # Symbol to details cache ONLY of active quote currencies
  #
  # * Author: Santhosh
  # * Date: 05/06/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def self.active_quote_currencies_by_symbol
    @active_quote_currencies_by_symbol ||= begin
      QuoteCurrency.symbols_to_details_cache.select { |_,data| data[:status] == GlobalConstant::QuoteCurrency.active_status}
    end
  end

end