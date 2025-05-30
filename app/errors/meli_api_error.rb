class MeliApiError < StandardError
  attr_reader :status_code, :response_body

  def initialize(message, status_code = nil, response_body = nil)
    super(message)
    @status_code = status_code
    @response_body = response_body
  end
end
