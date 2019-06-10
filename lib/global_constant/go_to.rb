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

      def team
        {
          by_screen_name: :team
        }
      end

      def developer
        {
          by_screen_name: :developer
        }
      end

      def token_setup
        {
            by_screen_name: :token_setup
        }
      end

      def mainnet_token_dashboard
        {
          by_screen_name: :mainnet_token_dashboard
        }
      end

      def sandbox_token_dashboard
        {
          by_screen_name: :sandbox_token_dashboard
        }
      end

      def token_deploy
        {
          by_screen_name: :token_deploy
        }
      end

      def token_dashboard
        {
          by_screen_name: :token_dashboard
        }
      end

      def service_unavailable
        {
            by_screen_name: :service_unavailable
        }
      end

      def token_mint
        {
          by_screen_name: :token_mint
        }
      end

      def token_mint_progress
        {
          by_screen_name: :token_mint_progress
        }
      end

      def test_economy
        {
            by_screen_name: :test_economy
        }
      end

      def logout
        {
          by_screen_name: :logout
        }
      end

      def verify_device
        {
          by_screen_name: :verify_device
        }
      end

      def identify_wf_goto(workflow)
        if workflow.kind == GlobalConstant::Workflow.token_deploy
          return token_deploy
        elsif workflow.kind == GlobalConstant::Workflow.bt_stake_and_mint
          return token_mint
        end
      end

      def company_information
        {
          by_screen_name: :company_information
        }
      end

    end

  end

end
