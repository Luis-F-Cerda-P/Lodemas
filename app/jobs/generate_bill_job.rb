class GenerateBillJob < ApplicationJob
  class OrderNotReady < StandardError; end
  class OrderHasBeenCancelled < StandardError; end
  class AlreadyBilled < StandardError; end

  queue_as :default

  limits_concurrency to: 1, key: ->(_) { "singleton" }, duration: 5.minutes

  retry_on OrderNotReady, wait: 5.minutes, attempts: 3
  discard_on OrderHasBeenCancelled
  discard_on AlreadyBilled

  def perform(order)
    raise OrderNotReady unless order.ready_for_billing?
    raise OrderHasBeenCancelled if order.has_been_cancelled
    raise AlreadyBilled if order.already_billed?

    begin
      # Instanciar el SiiApiClient
      sii_client = SiiApiClient.new(order.user.tax_accounts.first!)
      # Pasarle a su función de boleteo el monto billeable de la orden
      bill_json = sii_client.generate_bill_by_amount(order.billable_amount)
      folio = bill_json["folio"]
      raw_b64 = bill_json["b64encoded_pdf"]
      # Remove the data URI prefix if present
      b64_string = raw_b64.sub(/^data:application\/pdf;base64,/, "")

      # Procesar respuesta y adjuntar boleta a orden
      file_name = "eboleta_#{folio}_orden_#{order.human_readable_id}.pdf"
      order.bill.attach(
        io: StringIO.new(Base64.decode64(b64_string)),
        filename: file_name,
        content_type: "application/pdf"
      )
      # Enfilar el trabajo de envío de la boleta a Mercadolibre
      SendBillToMeliJob.perform_later(order)
    rescue => e
      Rails.logger.error("[GenerateBillJob] Failed for Order #{order.human_readable_id}: #{e.class} - #{e.message}")
      raise
    end
  end
end
