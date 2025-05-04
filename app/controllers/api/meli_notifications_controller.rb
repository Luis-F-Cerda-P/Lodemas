class Api::MeliNotificationsController < ActionController::Metal
  def create
    # MeliNotificationJob.perform_later(request.raw_post)
    self.status = 200
    self.response_body= request.remote_ip
  end
end
