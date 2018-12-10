module Sanitizer

  def sanitize_params_recursively(passed_param)
    if passed_param.is_a? String
      # if the passed_param is a string, sanitize it directly to remove script tags etc
      passed_param = Sanitize.fragment(passed_param.to_s).gsub("`", "&#x60;")
    elsif passed_param.is_a?(Hash) || passed_param.is_a?(ActionController::Parameters)
      # if the passed_param is a hash, sanitize the values.
      # we are not sanitizing keys, as not known keys will not be accessed - assumption
      passed_param.each do |key, val|
        passed_param[key] = sanitize_params_recursively(val)
      end
    elsif passed_param.is_a? Array
      # if passed_param is a array, sanitize each element
      passed_param.each_with_index do |val, index|
        passed_param[index] = sanitize_params_recursively(val)
      end
    end
    passed_param
  end

  def hashify_params_recursively(passed_param)

    if passed_param.is_a? ActionController::Parameters
      # if the passed_param is a ActionController::Parameters, convert it to a Hash
      # and recursively call this method over that Hash
      hashified_param = HashWithIndifferentAccess.new(passed_param.to_unsafe_hash)
      hashify_params_recursively(hashified_param)
    elsif passed_param.is_a? Hash
      hashified_param = HashWithIndifferentAccess.new
      passed_param.each do |key, val|
        hashified_param[key] = hashify_params_recursively(val)
      end
    elsif passed_param.is_a? Array
      hashified_param = passed_param.deep_dup
      hashified_param.each_with_index do |p, i|
        hashified_param[i] = hashify_params_recursively(p)
      end
    else
      hashified_param = passed_param
    end
    hashified_param

  end

  def recursively_check_keys_sanity(passed_params)

    if passed_params.is_a?(Hash)
      passed_params.each do |params_key, params_value|
        sanitized_params_key = Sanitize.fragment(params_key.to_s.dup).gsub('`', '&#x60;')
        unless sanitized_params_key.eql?(params_key.to_s)
          #   send notification mail and redirect properly.
        end
        recursively_check_keys_sanity(params_value) if params_value.is_a?(Hash) || params_value.is_a?(Array)
      end
    elsif passed_params.is_a?(Array)
      passed_params.each do |params_value|
        recursively_check_keys_sanity(params_value) if params_value.is_a?(Hash) || params_value.is_a?(Array)
      end
    end

  end

end