json.extract! shipment, :id, :order_id, :meli_id, :created_at, :updated_at
json.url shipment_url(shipment, format: :json)
