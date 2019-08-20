class HomepageLatestTransaction < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_jwt

  # Get latest transaction
  #
  # * Author: Ankit
  # * Date: 20/08/2019
  # * Reviewed By:
  #
  def get
    service_response = OstWebHomepageManagement::LatestTransaction.new.perform
    return render_api_response(service_response)
  end


  # Authenticate jwt
  #
  # * Author: Ankit
  # * Date: 20/08/2019
  # * Reviewed By:
  #
  def authenticate_jwt
    r = SubenvCommunicationApi.new.decrypyt_request(params)

    unless r.success?
      r.http_code = GlobalConstant::ErrorCode.unauthorized_access
      r.data = {}
      render_api_response(r)
    end
  end

end