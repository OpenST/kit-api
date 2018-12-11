module AdminManagement

  class ResetMfa < ServicesBase

    # Initialize
    #
    # * Author: Puneet
    # * Date: 03/05/2018
    # * Reviewed By:
    #
    # @params [Integer] email (mandatory) - email of manager whose MFA has to be set
    #
    # @return [ManagerManagement::ResetMfa]
    #
    def initialize(params)
      super
      @email = @params[:email]
    end

    # Perform
    #
    # * Author: Puneet
    # * Date: 03/05/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def perform

      handle_errors_and_exceptions do

        validate_and_sanitize

        fetch_manager

        reset_mfa

        success_with_data({})

      end

    end

    private

    # Validate and sanitize
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def validate_and_sanitize

      validation_errors = []

      @email = @email.to_s.downcase.strip
      validation_errors.push('invalid_email') unless Util::CommonValidator.is_valid_email?(@email)

      fail OstCustomError.new validation_error(
                                  'am_rm_1',
                                  'invalid_api_params',
                                  validation_errors,
                                  GlobalConstant::ErrorAction.default
                              ) if validation_errors.present?

      # NOTE: To be on safe side, check for generic errors as well
      validate

    end

    # Validate and sanitize
    #
    # * Author: Puneet
    # * Date: 06/12/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def fetch_manager
      @manager = Manager.where(email: @email).first
      fail OstCustomError.new unauthorized_access_response('am_rm_2') if @manager.blank?
      success
    end

    # Resets MFA token of admin
    #
    # * Author: Puneet
    # * Date: 03/05/2018
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def reset_mfa

      @manager.mfa_token = nil
      @manager.send("unset_#{GlobalConstant::Manager.has_setup_mfa_property}")
      @manager.last_session_updated_at = current_timestamp
      @manager.save!

      success

    end

  end

end
