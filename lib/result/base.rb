module Result

  class Base

    class << self

      def general_error_config
        @g_e_c ||= YAML.load_file('config/general_error_config.yml')
      end

      def param_error_config
        @p_e_c ||= YAML.load_file('config/param_error_config.yml')
      end

    end

    attr_accessor :internal_id,
                  :error_message,
                  :error_display_text,
                  :error_display_heading,
                  :error_action,
                  :params_error_identifiers,
                  :general_error_identifier,
                  :message,
                  :data,
                  :exception,
                  :http_code,
                  :go_to

    # Initialize
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [Hash] params (optional) is a Hash
    #
    def initialize(params = {})
      set_error(params)
      set_message(params[:message])
      set_error_identifiers(params)
      set_http_code(params[:http_code])
      set_go_to(params[:go_to])
      set_error_data(params[:error_data])
      @data = params[:data] || {}
    end

    # Set Http Code
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [Integer] h_c is an Integer http_code
    #
    def set_http_code(h_c)
      if h_c.present?
        @http_code = h_c
      elsif @general_error_identifier.present?
        config = self.class.general_error_config[@general_error_identifier] || {}
        @http_code = config[:http_code] || GlobalConstant::ErrorCode.ok
      else
        @http_code = GlobalConstant::ErrorCode.ok
      end
    end

    # Set Go To
    #
    # * Author: Puneet
    # * Date: 19/02/2018
    # * Reviewed By:
    #
    # @param [Hash]
    #
    def set_go_to(go_to)
      @go_to = (go_to.blank? || !go_to.is_a?(Hash)) ? {} : go_to
    end

    # Set formatted error data
    #
    # * Author: Puneet
    # * Date: 19/02/2018
    # * Reviewed By:
    #
    # @param [Array]
    #
    def set_error_data(error_data)
      @error_data = error_data
    end

    # Set Error Identifiers
    #
    # * Author: Puneet
    # * Date: 05/05/2018
    # * Reviewed By:
    #
    # @param [Hash]
    #
    def set_error_identifiers(params)
      @params_error_identifiers = params[:params_error_identifiers] || []
      @general_error_identifier = params[:general_error_identifier]
    end

    # Set Error
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [Hash] params is a Hash
    #
    def set_error(params)
      @internal_id = params[:internal_id] if params.key?(:internal_id)
      @error_message = params[:error_message] if params.key?(:error_message)
      @params_error_identifiers = params[:params_error_identifiers] || []
      @error_action = params[:error_action] if params.key?(:error_action)
      @error_display_text = params[:error_display_text] if params.key?(:error_display_text)
      @error_display_heading = params[:error_display_heading] if params.key?(:error_display_heading)
    end

    # Set Message
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [String] msg is a String
    #
    def set_message(msg)
      @message = msg
    end

    # Set Exception
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [Exception] e is an Exception
    #
    def set_exception(e)
      @exception = e
    end

    # is valid?
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns True / False
    #
    def valid?
      !invalid?
    end

    # is invalid?
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns True / False
    #
    def invalid?
      errors_present?
    end

    # Define error / failed methods
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    [:internal_id?, :errors?, :failed?].each do |name|
      define_method(name) { invalid? }
    end

    # Define success method
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    [:success?].each do |name|
      define_method(name) { valid? }
    end

    # are errors present?
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Boolean] returns True / False
    #
    def errors_present?
      @internal_id.present? ||
        @error_message.present? ||
        @params_error_identifiers.present? ||
        @error_display_text.present? ||
        @error_display_heading.present? ||
        @error_action.present? ||
        @exception.present?
    end

    # Exception message
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [String]
    #
    def exception_message
      @e_m ||= @exception.present? ? @exception.message : ''
    end

    # Exception backtrace
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [String]
    #
    def exception_backtrace
      @e_b ||= @exception.present? ? @exception.backtrace : ''
    end

    # Get instance variables Hash style from object
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    def [](key)
        instance_variable_get("@#{key}")
    end

    # Error
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Result::Base] returns object of Result::Base class
    #
    def self.error(params)
      new(params)
    end

    # Success
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Result::Base] returns object of Result::Base class
    #
    def self.success(params)
      new(params.merge!(no_error))
    end

    # Exception
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Result::Base] returns object of Result::Base class
    #
    def self.exception(e, params = {})
      obj = new(params)
      obj.set_exception(e)
      if params[:notify].present? ? params[:notify] : true
        send_notification_mail(e, params)
      end
      return obj
    end

    # Send Notification Email
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    def self.send_notification_mail(e, params)
      ApplicationMailer.notify(
          body: {exception: {message: e.message, backtrace: e.backtrace}},
          data: params,
          subject: "#{params[:internal_id]} : #{params[:error_message]}"
      ).deliver
    end

    # No Error
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Hash] returns Hash
    #
    def self.no_error
      @n_err ||= {
          internal_id: nil,
          error_message: nil,
          params_error_identifiers: nil,
          error_action: nil,
          error_display_text: nil,
          error_display_heading: nil
      }
    end

    # Fields
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Array] returns Array object
    #
    def self.fields
      error_fields + [:data, :message, :go_to]
    end

    # Error Fields
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Array] returns Array object
    #
    def self.error_fields
      [
          :internal_id,
          :error_message,
          :error_action,
          :error_display_text,
          :error_display_heading
      ]
    end

    # To Hash
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Hash] returns Hash object
    #
    def to_hash
      self.class.fields.each_with_object({}) do |key, hash|
        val = send(key)
        hash[key] = val if val.present?
      end
    end

    # is request for a non found resource
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Result::Base] returns an object of Result::Base class
    #
    def is_entity_not_found_action?
      http_code == GlobalConstant::ErrorCode.not_found
    end


    # To JSON
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    def to_json

      hash = self.to_hash

      if @internal_id.nil?
        h = {
            success: true
        }.merge(hash)
        h
      else
        general_error_config = self.class.general_error_config[@general_error_identifier] || {}
        if @error_data.present?
          error_data = @error_data
        else
          error_data = []
          params_error_config_hash = self.class.param_error_config
          @params_error_identifiers.each do |params_error_identifier|
            params_error_config = params_error_config_hash[params_error_identifier] || {}
            error_data << {
                code: params_error_config['code'],
                msg: params_error_config['message'],
                parameter: params_error_config['parameter']
            }
          end
        end
        {
            success: false,
            err: {
                internal_id: @internal_id,
                msg: hash[:error_message] || general_error_config['message'],
                code: general_error_config['code'] || 'INTERNAL_SERVER_ERROR',
                action: hash[:error_action] || GlobalConstant::ErrorAction.default,
                display_text: hash[:error_display_text].to_s,
                display_heading: hash[:error_display_heading].to_s,
                error_data: error_data,
                go_to: hash[:go_to] || {}
            },
            data: hash[:data] || {}
        }
      end

    end

  end

end
