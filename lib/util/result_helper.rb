module Util

  module ResultHelper

    # All methods of this module are common short hands used for

    # Success
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def success
      success_with_data({})
    end

    # Success with data
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [Hash] data (mandatory) - data to be sent in the response
    #
    # @return [Result::Base]
    #
    def success_with_data(data)
      # Allow only Hash data to pass ahead
      data = {} unless Util::CommonValidator.is_a_hash?(data)

      Result::Base.success({
                               data: data
                           })
    end

    # Success with Go TO
    #
    # * Author: Puneet
    # * Date: 19/02/2018
    # * Reviewed By:
    #
    # @param [Hash] data (mandatory) - data to be sent in the response
    #
    # @return [Result::Base]
    #
    def success_with_go_to(go_to)
      Result::Base.success(go_to: go_to)
    end

    # Error with Action
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [String] internal_id (mandatory) - internal_id
    # @param [String] general_error_identifier (mandatory) - key which is used to look up error config file
    # @param [String] action (mandatory) - error action
    # @param [Hash] data (optional) - data
    #
    # @return [Result::Base]
    #
    def error_with_data(internal_id, general_error_identifier, action, data = {})
      Result::Base.error(
          {
              internal_id: internal_id,
              general_error_identifier: general_error_identifier,
              error_action: action,
              data: data
          }
      )
    end

    # Error with Formatted Error Data
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [String] internal_id (mandatory) - internal_id
    # @param [String] error_message (mandatory) - message string
    # @param [Hash] error_data (mandatory) - formatted data
    #
    # @return [Result::Base]
    #
    def error_with_formatted_error_data(internal_id, error_message, error_data)
      Result::Base.error(
          {
              internal_id: internal_id,
              error_message: error_message,
              error_action: GlobalConstant::ErrorAction.default,
              error_data: error_data
          }
      )
    end

    # Error with Validation
    #
    # * Author: Puneet
    # * Date: 08/05/2018
    # * Reviewed By:
    #
    # @param [String] internal_id (mandatory) - internal_id
    # @param [Array] params_error_identifiers (mandatory) - keys for param errors
    #
    # @return [Result::Base]
    #
    def validation_error(internal_id, general_error_identifier, params_error_identifiers, action)
      Result::Base.error(
          {
              internal_id: internal_id,
              general_error_identifier: general_error_identifier,
              params_error_identifiers: params_error_identifiers,
              error_action: action
          }
      )
    end

    # Exception with action and data
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [Exception] e (mandatory) - Exception object
    # @param [String] internal_id (mandatory) - internal_id
    # @param [String] action (mandatory) - action
    # @param [Hash] data (mandatory) - error data
    #
    # @return [Result::Base]
    #
    def exception_with_data(e, internal_id, action, data = {})
      Result::Base.exception(
        e, {
        internal_id: internal_id,
        general_error_identifier: 'something_went_wrong',
        error_action: action,
        data: data
      })
    end

    # Error with Go TO
    #
    # * Author: Puneet
    # * Date: 19/02/2018
    # * Reviewed By:
    #
    # @param [String] internal_id (mandatory) - internal code
    # @param [String] general_error_identifier (mandatory) - key which is used to look up error config file
    # @param [Hash] go_to (mandatory) - go_to to be sent in the response
    #
    # @return [Result::Base]
    #
    def error_with_go_to(internal_id, general_error_identifier, go_to)
      Result::Base.error(
          {
              internal_id: internal_id,
              general_error_identifier: general_error_identifier,
              go_to: go_to
          }
      )
    end

    # Current Time
    #
    # * Author:
    # * Date: 19/10/2017
    # * Reviewed By: Puneet
    #
    def current_time
      @c_t ||= Time.now
    end

    # Current Time Stamp
    #
    # * Author:
    # * Date: 19/10/2017
    # * Reviewed By: Puneet
    #
    def current_timestamp
      @c_tstmp ||= current_time.to_i
    end

  end

end