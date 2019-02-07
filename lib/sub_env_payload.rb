class SubEnvPayload
  include Util::ResultHelper

  # Initialize
  #
  # * Author: Ankit
  # * Date: 30/01/2019
  # * Reviewed By:
  #
  # @params [Integer] parent_id (mandatory) - workflow parent Id
  #
  # @return [TokenSetup::SetupProgress]
  def initialize(params)
    @client_id = params[:client_id]
  end

  # Perform
  #
  # * Author: Ankit
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  def perform

    r = prepare_sub_env_payload
    return r unless r.success?

    success_with_data({
                        sub_env_payloads: @sub_env_payload
                      })

  end


  # Client subenv payload
  #
  # * Author: Ankit
  # * Date: 15/01/2019
  # * Reviewed By:
  #
  # @return [Result::Base]
  def prepare_sub_env_payload
    client_data = CacheManagement::Client.new([@client_id]).fetch[@client_id]

    return error_with_data(
      'l_sep_1',
      'client_not_found',
      GlobalConstant::ErrorAction.default
    ) if client_data.blank?

    m_statuses = client_data[:mainnet_statuses]
    s_statuses = client_data[:sandbox_statuses]

    @sub_env_payload = {
      mainnet: {
        whitelisted: m_statuses.include?(GlobalConstant::Client.mainnet_whitelisted_status).to_i,
        whitelisting_requested: m_statuses.include?(GlobalConstant::Client.mainnet_whitelist_requested_status).to_i
      },
      testnet: {
        whitelisted: s_statuses.include?(GlobalConstant::Client.sandbox_whitelisted_status).to_i,
        whitelisting_requested: s_statuses.include?(GlobalConstant::Client.sandbox_whitelist_requested_status).to_i
      }
    }

    success

  end

end