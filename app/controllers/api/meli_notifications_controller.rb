class Api::MeliNotificationsController < ActionController::Metal
  ALLOWED_IPS = %w[
    54.88.218.97
    18.215.140.160
    18.213.114.129
    18.206.34.84
    181.42.142.19
  ].freeze

  def create
    unless ALLOWED_IPS.include?(request.remote_ip)
      self.status = 403
      self.content_type = "text/plain"
      self.response_body = "Forbidden"
      return
    end

    # MeliNotificationJob.perform_later(request.raw_post)
    self.status = 200
    self.content_type = "text/plain"
    self.response_body = "OK"
  end
end
