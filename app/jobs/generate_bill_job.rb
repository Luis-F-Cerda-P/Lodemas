class GenerateBillJob < ApplicationJob
  queue_as :default

  def perform(order)
    order_id = order.id
    download_dir = Rails.root.join("tmp", "bills", "order_#{order_id}")

    pdf_path = BillGenerator.new(order: order, download_dir: download_dir).generate!

    order.bill.attach(
      io: File.open(pdf_path),
      filename: "boleta_order_#{order.human_readable_id}.pdf",
      content_type: "application/pdf"
    )
  ensure
    FileUtils.rm_rf(download_dir)
  end
end
