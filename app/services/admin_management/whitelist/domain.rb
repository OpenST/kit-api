module AdminManagement

  module Whitelist

    class Domain < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 18/03/2019
      # * Reviewed By:
      #
      # @params [String] identifier (mandatory) - domain which needs to be whitelisted
      #
      # @return [AdminManagement::Whitelist::Domain]
      #
      def initialize(params)
        super
        @domain = @params[:identifier]
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

        @domain = @domain.downcase.strip

        unless Util::CommonValidator.is_valid_domain?(@domain)
          return validation_error(
              'am_w_d_1',
              'invalid_api_params',
              ['invalid_domain'],
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
          kind: GlobalConstant::ManagerWhitelisting.domain_kind,
          identifier: @domain
        ).first

        unless record.present?
          ManagerWhitelisting.create!(
            kind: GlobalConstant::ManagerWhitelisting.domain_kind,
            identifier: @domain
          )
        end

        success

      end

    end

  end

end