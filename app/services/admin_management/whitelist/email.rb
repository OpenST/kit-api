module AdminManagement

  module Whitelist

    class Email < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 18/03/2019
      # * Reviewed By:
      #
      # @params [String] identifier (mandatory) - email which needs to be whitelisted
      #
      # @return [AdminManagement::Whitelist::Email]
      #
      def initialize(params)
        super
        @email = @params[:identifier]
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

        handle_errors_and_exceptions do

          r = validate_and_sanitize
          return r unless r.success?

          find_or_create_record

        end

      end

      private

      # Validate and sanitize
      #
      # * Author: Puneet
      # * Date: 18/03/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def validate_and_sanitize

        r = validate
        return r unless r.success?

        @email = @email.downcase.strip

        unless Util::CommonValidator.is_valid_email?(@email)
          return validation_error(
              'am_w_e_1',
              'invalid_api_params',
              ['invalid_email'],
              GlobalConstant::ErrorAction.default
          )
        end

        success

      end

      # Find or create record
      #
      # * Author: Shlok
      # * Date: 14/09/2018
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def find_or_create_record

        record = ManagerWhitelisting.where(
          kind: GlobalConstant::ManagerWhitelisting.email_kind,
          identifier: @email
        ).first

        unless record.present?
          ManagerWhitelisting.create!(
            kind: GlobalConstant::ManagerWhitelisting.email_kind,
            identifier: @email
          )
        end

        success

      end

    end

  end

end