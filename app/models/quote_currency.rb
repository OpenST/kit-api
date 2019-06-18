class QuoteCurrency < DbConnection::KitSaasSubenv

  enum status: {
      GlobalConstant::QuoteCurrency.active_status => 1,
      GlobalConstant::QuoteCurrency.inactive_status => 2
  }

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

  # Id to details cache
  #
  # * Author: Santhosh
  # * Date: 12/06/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def self.details_by_id(id)
    @id_to_details_cache ||= {}

    return @id_to_details_cache[id] unless @id_to_details_cache[id].nil?

    row = QuoteCurrency.where(id: id).first
    formatted_row = row.formatted_cache_data

    @id_to_details_cache[id] = formatted_row unless (formatted_row[:status] != GlobalConstant::QuoteCurrency.active_status)

    return formatted_row
  end

  # Details by symbol
  #
  # * Author: Santhosh
  # * Date: 12/06/2019
  # * Reviewed By:
  #
  # @return [Hash]
  #
  def self.details_by_symbol(symbol)
    @symbol_to_details_cache ||= {}

    return @symbol_to_details_cache[symbol] unless @symbol_to_details_cache[symbol].nil?

    row = QuoteCurrency.where(symbol: symbol).first
    formatted_row = row.formatted_cache_data

    @symbol_to_details_cache[symbol] = formatted_row unless (formatted_row[:status] != GlobalConstant::QuoteCurrency.active_status)

    return formatted_row
  end

end