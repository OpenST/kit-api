module Google

  class Authenticator

    DRIFT_TIME = 30 # expiry time difference for otp

    include ::Util::ResultHelper

    # Initialize
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By:
    #
    # @return [Google::Authenticator]
    #
    def initialize(secret)
      @secret = secret
    end

    # Verify the OTP
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By:
    #
    # @param [String] otp - Current OTP
    # @param [TimeStamp] last_otp_at - last otp generation timestamp. All otps generated <= last_otp_at will invalidate
    #
    # @return [Result::Base]
    #
    def verify_with_drift_and_prior(otp, last_otp_at = nil)
      begin
        # We are subtracting 60 seconds from the timestamp to ensure that the current OTP being in use is not invalidated.
        if last_otp_at
          last_otp_at = last_otp_at - 60
        end
        verified_at_timestamp = client.verify_with_drift_and_prior(otp, DRIFT_TIME, last_otp_at)

        if verified_at_timestamp.present?
          return success_with_data(verified_at_timestamp: verified_at_timestamp)
        else
          fail OstCustomError.new error_with_data(
                                      'r_t_1',
                                      'something_went_wrong',
                                      GlobalConstant::ErrorAction.default,
                                      {}
                                  )
        end
      rescue StandardError
        fail OstCustomError.new validation_error(
                                    'r_t_2',
                                    'invalid_api_params',
                                    ['invalid_otp'],
                                    GlobalConstant::ErrorAction.default
                                )
      end
    end

    # Get provisioning url
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By:
    #
    # @param [String] name - Display Name
    #
    # @return [Result::Base]
    #
    def provisioning_uri(name)
      begin
        otpauth = client.provisioning_uri(name)
        return success_with_data(otpauth: otpauth)
      rescue => e
        fail OstCustomError.new exception_with_data(
            e,
            'r_t_3',
            GlobalConstant::ErrorAction.default,
            {
                name: name
            }
        )
      end
    end

    private

    # Setup client for ROTP
    #
    # * Author: Puneet
    # * Date: 10/10/2017
    # * Reviewed By:
    #
    # @return [Object] ROTP
    #
    def client
      env_name = Rails.env.production? ? '' :  " - #{Rails.env}"
      @client ||= ROTP::TOTP.new(@secret, issuer: "OST Kit #{env_name}")
    end

  end

end