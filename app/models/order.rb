class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_one :shipment, dependent: :destroy

  has_one_attached :bill

  enum :source_channel, { mercadolibre: 0 }

  def run_ready_for_billing_check!
    if ready_for_billing?
      calculate_billable_amount
      GenerateBillJob.perform_later(self)
    end
  end

  def ready_for_billing?
    expected_item_count == order_items.count &&
      order_items.all? { |item| item.billable_amount.present? && item.billable_amount > 0 } &&
      shipment&.billable_amount.present? &&
      !bill.attached?
  end

  def has_been_cancelled
    self.status == "cancelled" || update_and_check_status
  end

  def already_billed?
    client = MeliApiClient.new(self.user.meli_account)
    resource = "/packs/#{self.human_readable_id}/fiscal_documents"

    begin
      response = client.get(resource)
      response["fiscal_documents"].size == 1
    rescue MeliApiError => e
      if e.status_code == 404
        false  # 404 means not billed yet
      else
        raise e  # Re-raise other API errors
      end
    end
  end

  private

  def calculate_billable_amount
    total = order_items.sum(:billable_amount) + shipment.billable_amount
    update!(billable_amount: total)
  end

  def update_and_check_status
    client = MeliApiClient.new(self.user.meli_account)
    resource = self.pack_id? ? "/packs/" : "/orders/"
    response = client.get(resource + self.human_readable_id)

    latest_status = response["status"]
    self.update!(status: latest_status)

    latest_status == "cancelled"
  end
end
