class VerifyEmailWhitelisting

  include Util::ResultHelper

  # Initialize
  #
  # * Author: Puneet
  # * Date: 18/03/2019
  # * Reviewed By:
  #
  # @params [String] email (mandatory) - email which needs to be checked
  #
  # @return [VerifyEmailWhitelisting]
  #
  def initialize(params)
    @email = params[:email]
  end

  # Perform
  #
  # * Author: Puneet
  # * Date: 18/03/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def perform

    is_whitelisted_email?(@email) ? success : validation_error(
        'vew_2',
        'invalid_api_params',
        ['email_not_allowed_to_access_kit'],
        GlobalConstant::ErrorAction.default
    )

  end
  
  private
  
  # Is the Email a Valid Email
  #
  # * Author: Puneet
  # * Date: 18/03/2019
  # * Reviewed By:
  #
  # @return [Boolean] returns a boolean
  #
  def is_whitelisted_email?(email)
    sanitized_email = email.to_s.downcase.strip
    (is_email_from_allowed_domains?(sanitized_email) || whitelisted_emails.include?(sanitized_email))
  end

  # list of whitelisted emails
  #
  # * Author: Puneet
  # * Date: 18/03/2019
  # * Reviewed By:
  #
  # @return [Array]
  #
  def whitelisted_emails
    r = CacheManagement::WhitelistedEmails.new().fetch
    r.success? ? r.data[:emails] : []
  end

  # Is the Email a OST Email
  #
  # * Author: Puneet
  # * Date: 18/03/2019
  # * Reviewed By:
  #
  # @return [Boolean] returns a boolean
  #
  def is_email_from_allowed_domains?(email)
    /w*@(#{allowed_domains.join('|')})$/.match(email).present?
  end

  # List of Domains which we need to support
  #
  # * Author: Puneet
  # * Date: 18/03/2019
  # * Reviewed By:
  #
  # @return [Array] returns a boolean
  #
  def allowed_domains
    r = CacheManagement::WhitelistedDomains.new().fetch
    r.success? ? r.data[:domains] : []
  end

end