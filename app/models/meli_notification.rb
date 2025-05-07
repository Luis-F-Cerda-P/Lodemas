class MeliNotification < ApplicationRecord
  belongs_to :user

  after_create_commit :enqueue_fetch_resource_job

  private

  def enqueue_fetch_resource_job
    FetchResourceJob.perform_later(id)
  end
end
