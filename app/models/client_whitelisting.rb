class ClientWhitelisting < EstablishCompanyClientDbConnection

  enum kind: {
      GlobalConstant::ClientWhitelisting.domain_kind => 1,
      GlobalConstant::ClientWhitelisting.email_kind => 2
  }

  after_commit :flush_cache

  # Flush memcache
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  def flush_cache

    case self.kind
    when GlobalConstant::ClientWhitelisting.domain_kind
      CacheManagement::ClientWhitelistedDomains.new().clear
    when GlobalConstant::ClientWhitelisting.email_kind
      CacheManagement::ClientWhitelistedEmails.new().clear
    else
      fail "unsupported #{self.kind}"
    end

  end

end
