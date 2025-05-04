class MeliNotificationsController < ApplicationController
  include OwnedResource

  skip_before_action :set_owned_resource_instance

  def index
    @meli_notifications = @meli_notifications.order(sent: :desc).limit(20)
  end
end
