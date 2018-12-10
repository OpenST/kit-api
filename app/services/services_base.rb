class ServicesBase

  include Util::ResultHelper

  attr_reader :params

  def initialize(service_params={})
    service_klass = self.class.to_s
    service_params_list = ServicesBase.get_service_params(service_klass)

    # passing only the mandatory and optional params to a service
    permitted_params_list = ((service_params_list[:mandatory] || []) + (service_params_list[:optional] || [])) || []

    permitted_params = {}

    permitted_params_list.each do |pp|
      permitted_params[pp] = service_params[pp] if service_params[pp].present?
    end

    @params = HashWithIndifferentAccess.new(permitted_params)
  end

  # Handle Error & Exceptions
  #
  # * Author: Puneet
  # * Date: 06/12/2018
  # * Reviewed By:
  #
  # @return [Result::Base]
  #
  def handle_errors_and_exceptions(&block)
    begin
      block.call
    rescue OstCustomError => ose
      puts "Handled Exception: #{ose.response}"
      return ose.response
    rescue StandardError => se
      puts "Unhandled Exception: msg: #{se.message}"
      puts "Unhandled Exception: trace: #{se.backtrace}"
      return exception_with_data(
          se,
          's_b_1',
          GlobalConstant::ErrorAction.default
      )
    end
  end

  def current_time
    @c_t ||= Time.now
  end

  def current_timestamp
    @c_tstmp ||= current_time.to_i
  end

  def self.get_service_params(service_class)
    # Load mandatory params yml only once
    @mandatory_params ||= YAML.load_file(open(Rails.root.to_s + '/app/services/service_params.yml'))
    @mandatory_params[service_class]
  end

  private

  def validate

    # perform presence related validations here
    # result object is returned
    service_params_list = ServicesBase.get_service_params(self.class.to_s)
    missing_mandatory_params_errors = []

    service_params_list[:mandatory].each do |mandatory_param|
      missing_mandatory_params_errors << "missing_#{mandatory_param}" if @params[mandatory_param].to_s.blank?
    end if service_params_list[:mandatory].present?

    fail OstCustomError.new validation_error(
        'sb_1',
        'invalid_api_params',
        missing_mandatory_params_errors,
        GlobalConstant::ErrorAction.mandatory_params_missing
    ) if missing_mandatory_params_errors.any?

    success

  end

end