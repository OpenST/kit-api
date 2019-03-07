class Manager::DetailController < AuthenticationController

  # Get Manager's details
  #
  # * Author: Puneet
  # * Date: 08/12/2018
  # * Reviewed By: Sunil
  #
  def get_details
    go_to = FetchGoTo.new({
                    is_password_auth_cookie_valid: true,
                    is_multi_auth_cookie_valid: true,
                    client: params[:client],
                    manager: params[:manager]
                  }).fetch_by_manager_state

    if go_to
      service_response = error_with_go_to('a_c_m_lc_1', 'data_validation_failed', go_to)
    else
      service_response = success_with_data(
        {
          manager: params[:manager],
          client: params[:client],
          client_manager: params[:client_manager]
        }
      )
    end

    render_api_response(service_response)
  end

end
