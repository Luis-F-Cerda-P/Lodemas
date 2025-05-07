class FetchResourceJob < ApplicationJob
  queue_as :default

  def perform(meli_notification_id)
    notification = MeliNotification.find(meli_notification_id)
    account = MeliAccount.find_by(mercadolibre_identifier: notification.meli_user_id)
    return unless account

    client = MeliApiClient.new(account)
    resource_json = client.get(notification.resource)

    # Store raw JSON — for auditing or debugging
    if notification.topic == "orders"
      ProcessOrderJob.perform_later(resource_json.to_json, account.user_id)
    end
  end
end
