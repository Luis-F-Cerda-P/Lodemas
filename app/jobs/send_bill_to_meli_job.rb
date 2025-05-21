class SendBillToMeliJob < ApplicationJob
  queue_as :default

  def perform(order)
    return unless order.bill.attached?
    return unless order.human_readable_id.present?

    # Get the MeliAccount associated with this order
    meli_account = order.user.meli_account

    # Create MeliApiClient
    client = MeliApiClient.new(meli_account)

    # Download the bill temporarily to send it
    bill_path = download_bill(order)

    begin
      # Send the bill to MercadoLibre
      response = client.post_file(
        "packs/#{order.human_readable_id}/fiscal_documents",
        file_path: bill_path,
        file_param_name: "fiscal_document"
      )

      # Log the response
      Rails.logger.info("MercadoLibre fiscal document response: #{response}")

      # Update order with the document ID from MercadoLibre if needed
      # if response["ids"].present?
      #   order.update(meli_fiscal_document_id: response["ids"].first)
      # end
    ensure
      # Clean up the temporary file
      FileUtils.rm_f(bill_path) if bill_path && File.exist?(bill_path)
    end
  end

  private

  def download_bill(order)
    temp_dir = Rails.root.join("tmp", "meli_bills")
    FileUtils.mkdir_p(temp_dir)

    temp_path = File.join(temp_dir, "PETPORIUM_Boleta_orden_#{order.human_readable_id}.pdf")

    File.open(temp_path, "wb") do |file|
      file.write(order.bill.download)
    end

    temp_path
  end
end
