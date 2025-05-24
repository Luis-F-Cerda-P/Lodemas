class GetShipmentLabelJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 2.minutes, attempts: 5

  def perform(shipment)
    client = MeliApiClient.new(shipment.order.user.meli_account)
    shipment_data = client.get("shipments/#{shipment.meli_id}", { optional_headers: { "x-format-new": true } })

    raise StandardError unless shipment_data["status"] == "ready_to_ship"
    # Búscame la etiqueta en PDF - TODO: Chequea antes que el tipo de logistica contengo "me2" y que la etiqueta esté lista. Si no está, programa obtener la etiqueta después. Este podría ser el último paso ya que le otorga unos segundos adicionales a Meli para que tengan lista la etiqueta
    shipment_label_response = client.get("shipment_labels?shipment_ids=#{shipment.meli_id}&response_type=pdf", { expect_binary: true })

    shipment.shipment_label.attach(
      io: StringIO.new(shipment_label_response),
      filename: "shipment_label_#{shipment.order.human_readable_id}.pdf",
      content_type: "application/pdf"
    )
  end
end
