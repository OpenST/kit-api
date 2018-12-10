class OstCustomError < StandardError

  attr_reader :response

  def initialize(response)
    @response = response
    super(response.error_message)
  end

end