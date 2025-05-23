class ProcessShipmentJob < ApplicationJob
  queue_as :default

  LOGISTIC_TYPE_MAP = {
    "self_service" => :flex,
    "xd_drop_off" => :mercadoenvios
  }

  def perform(shipment)
    client = MeliApiClient.new(shipment.order.user.meli_account)
    # "shipments/shipment.meli_id"
    shipment_data = client.get("shipments/#{shipment.meli_id}", { optional_headers: { "x-format-new": true } })
    # Búscame el destino
    address_line = shipment_data["destination"]["shipping_address"]["address_line"]
    municipality = shipment_data["destination"]["shipping_address"]["city"]["name"]
    region = shipment_data["destination"]["shipping_address"]["state"]["name"]
    destination = "#{address_line}, #{municipality}, #{region}"
    # Búscame el tipo de despacho
    external_type = shipment_data["logistic"]["type"]
    logistic_type = LOGISTIC_TYPE_MAP[external_type]
    # Búscame la hora tope
    delivery_deadline = client.get("shipments/#{shipment.meli_id}/sla")["expected_date"]
    # Búscame el monto boleteable (último paso) solo si el envío ES flex y si el monto declarado no supera los 19.990
    billable_amount = 0
    is_flex = logistic_type === :flex
    payed_for_shipping = shipment_data["declared_value"] < 19_990
    if is_flex && payed_for_shipping
      shipment_payment_data = client.get("shipments/#{shipment.meli_id}/costs")
      gross_amount = shipment_payment_data["gross_amount"]
      receiver_save = shipment_payment_data["receiver"]["save"]
      senders_cost = shipment_payment_data["senders"][0]["cost"]
      billable_amount = gross_amount - receiver_save - senders_cost
    end

    shipment.update!(
      destination: destination,
      logistic_type: logistic_type,
      delivery_deadline: delivery_deadline,
      billable_amount: billable_amount,
    )

    GetShipmentLabelJob.set(wait: 1.minute).perform_later(shipment)
  end
end
