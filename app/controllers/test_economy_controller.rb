class TestEconomyController < AuthenticationController

  skip_before_action :set_authentication_params_to_nil, only: [:self_invite]
  skip_before_action :authenticate_by_mfa_cookie, only: [:self_invite]
  skip_before_action :authenticate_sub_env_access, only: [:self_invite]

  # Get Demo Details
  #
  # * Author: Puneet
  # * Date: 10/04/2019
  # * Reviewed By: Sunil
  #
  def get
    service_response = TestEconomyManagement::Get.new(params).perform
    return render_api_response(service_response)
  end

  # Activate
  #
  # * Author: Puneet
  # * Date: 10/04/2019
  # * Reviewed By: Sunil
  #
  def activate
    service_response = TestEconomyManagement::Activate.new(params).perform
    return render_api_response(service_response)
  end

  # Invite
  #
  # * Author: Sunil
  # * Date: 25/04/2019
  # * Reviewed By: Puneet
  #
  def invite
    service_response = TestEconomyManagement::Invite.new(params).perform
    return render_api_response(service_response)
  end

  # Invite yourself for economy
  #
  # * Author: Pankaj
  # * Date: 08/07/2019
  # * Reviewed By:
  #
  def self_invite
    # For now this is for popcorn economy, so hardcoding client from here
    params.merge!({client_id: ENV['OST_POPCORN_ECONOMY_CLIENT'].to_i})
    service_response = TestEconomyManagement::SelfInvite.new(params).perform
    return render_api_response(service_response)
  end

end