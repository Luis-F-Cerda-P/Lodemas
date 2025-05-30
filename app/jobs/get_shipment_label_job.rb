class GetShipmentLabelJob < ApplicationJob
  class LabelNotReady < StandardError; end
  class LabelCannotBeDownloadedAnymore < StandardError; end

  queue_as :default

  retry_on LabelNotReady, wait: 2.minutes, attempts: 5
  discard_on LabelCannotBeDownloadedAnymore

  def perform(shipment)
    client = MeliApiClient.new(shipment.order.user.meli_account)
    shipment_data = client.get("shipments/#{shipment.meli_id}", { optional_headers: { "x-format-new": true } })

    raise LabelCannotBeDownloadedAnymore if shipment_data["status"] == "delivered" 
    raise LabelNotReady unless shipment_data["status"] == "ready_to_print" || shipment_data["status"] == "ready_to_ship"

    shipment_label_response = client.get("shipment_labels?shipment_ids=#{shipment.meli_id}&response_type=pdf", { expect_binary: true })

    shipment.shipment_label.attach(
      io: StringIO.new(shipment_label_response),
      filename: "shipment_label_#{shipment.order.human_readable_id}.pdf",
      content_type: "application/pdf"
    )
  end
end
