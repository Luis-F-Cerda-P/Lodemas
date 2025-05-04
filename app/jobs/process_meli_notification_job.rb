class ProcessMeliNotificationJob < ApplicationJob
  queue_as :default

  def perform(raw_post)
    payload = JSON.parse(raw_post, symbolize_names: true)
    meli_account = MeliAccount.find_by(mercadolibre_identifier: payload[:user_id])
    user = meli_account&.user

    unless user
      Rails.logger.warn "No user found for meli_user_id #{payload[:user_id]}, topic: #{payload[:topic]}"
      return
    end

    notification = MeliNotification.find_by(
      resource: payload[:resource],
      meli_user_id: payload[:user_id],
      topic: payload[:topic]
    )

    if notification
      notification.update!(
        attempts: payload[:attempts],
        sent: payload[:sent],
        received: payload[:received]
      )
    else
      MeliNotification.create!(
        resource: payload[:resource],
        meli_user_id: payload[:user_id],
        topic: payload[:topic],
        application_id: payload[:application_id],
        attempts: payload[:attempts],
        sent: payload[:sent],
        received: payload[:received],
        user: user
      )
    end
  end
end
