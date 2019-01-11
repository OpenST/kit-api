# frozen_string_literal: true
module GlobalConstant

  class GoTo

    class << self

      def login
        {
            by_screen_name: :login
        }
      end

      def verify_email
        {
            by_screen_name: :verify_email
        }
      end

      def setup_mfa
        {
            by_screen_name: :setup_mfa
        }
      end

      def authenticate_mfa
        {
          by_screen_name: :authenticate_mfa
        }
      end

      def token_setup
        {
            by_screen_name: :token_setup
        }
      end

      def token_deploy
        {
          by_screen_name: :token_deploy
        }
      end

      def service_unavailable
        {
            by_screen_name: :service_unavailable
        }
      end

    end

  end

end
