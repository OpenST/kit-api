module Email

  module HookCreator

    class Base

      include Util::ResultHelper

      # Initialize
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Email::HookCreator::Base] returns an object of Email::HookCreator::Base class
      #
      def initialize(params)
        @receiver_entity_id = params[:receiver_entity_id]
        @receiver_entity_kind = params[:receiver_entity_kind]
        @custom_description = params[:custom_description]
        @custom_attributes = params[:custom_attributes] || {}
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def perform

        r = validate
        return r unless r.success?

        handle_event

      end

      private

      # Validate
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate
        fail 'sub class to implement'
      end

      # Event type
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [String] event type that goes into hook table
      #
      def event_type
        fail 'sub class to implement'
      end

      # sub classes to implement logic of handling an event here
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def handle_event
        fail 'sub class to implement'
      end

      # Validate email
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate_receiver_entity

        if Util::CommonValidator.is_integer?(@receiver_entity_id) && GlobalConstant::EmailServiceApiCallHook.receiver_entity_kind.include?(@receiver_entity_kind)
          success
        else
          validation_error(
              'e_hc_b_3',
              'invalid_api_params',
              ['invalid_email'],
              GlobalConstant::ErrorAction.default
          )
        end

      end

      # Validate Custom Attributes
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @return [Result::Base] returns an object of Result::Base class
      #
      def validate_custom_variables

        return success if @custom_attributes.blank?

        unsupported_keys = @custom_attributes.keys - GlobalConstant::PepoCampaigns.allowed_custom_attributes

        unsupported_keys.blank? ? success :
            error_with_data(
                'e_hc_b_2',
                'something_went_wrong',
                GlobalConstant::ErrorAction.default,
                {unsupported_keys: unsupported_keys}
            )

      end

      # Create new hook
      #
      # * Author: Puneet
      # * Date: 12/01/2018
      # * Reviewed By:
      #
      # @param [String] event_type
      # @param [Hash] params
      #
      def create_hook(params = {})
        EmailServiceApiCallHook.create!(
            receiver_entity_id: @receiver_entity_id,
            receiver_entity_kind: @receiver_entity_kind,
            event_type: event_type,
            execution_timestamp: params[:execution_timestamp] || current_timestamp,
            custom_description: @custom_description,
            params: params
        )
      end

    end

  end

end