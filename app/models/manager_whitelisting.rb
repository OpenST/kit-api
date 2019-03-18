class ManagerWhitelisting < DbConnection::KitClient

  enum kind: {
      GlobalConstant::ManagerWhitelisting.domain_kind => 1,
      GlobalConstant::ManagerWhitelisting.email_kind => 2
  }

  after_commit :flush_cache

  # Flush memcache
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  def flush_cache
    CacheManagement::WhitelistedDomains.new().clear
    CacheManagement::WhitelistedEmails.new().clear
  end

end
