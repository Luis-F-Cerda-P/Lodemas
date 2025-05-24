require "test_helper"
require "minitest/mock"

class ProcessShipmentJobTest < ActiveJob::TestCase
  test "fetches and assigns shipment destination, deadline, and attaches label" do
    shipment = shipments(:five)
    # Sanity check
    assert_nil shipment.destination
    assert_nil shipment.delivery_deadline
    assert_not shipment.shipment_label.attached?

    mock_client = Minitest::Mock.new
    mock_shipment_response = JSON.parse(File.read("test/fixtures/files/shipment_A.json"))
    mock_shipment_sla_response = JSON.parse(File.read("test/fixtures/files/shipment_A_sla.json"))
    mock_shipment_label = File.read("test/fixtures/files/shipment_A_label")

    mock_client.expect :get, mock_shipment_response, [ "shipments/#{shipment.meli_id}",  { optional_headers: { "x-format-new": true } } ]
    mock_client.expect :get, mock_shipment_sla_response, [ "shipments/#{shipment.meli_id}/sla" ]
    mock_client.expect :get, mock_shipment_response, [ "shipments/#{shipment.meli_id}",  { optional_headers: { "x-format-new": true } } ]
    mock_client.expect :get, mock_shipment_label, [ "shipment_labels?shipment_ids=#{shipment.meli_id}&response_type=pdf",  { expect_binary: true } ]

    MeliApiClient.stub :new, mock_client do
      perform_enqueued_jobs do
        ProcessShipmentJob.perform_now(shipment)
      end
    end

    mock_client.verify

    shipment.reload

    assert_equal mock_shipment_label, shipment.shipment_label.download
    assert shipment.destination.present?, "Expected shipment to have destination"
    assert shipment.delivery_deadline.present?, "Expected shipment to have delivery deadline"
    assert shipment.shipment_label.attached?, "Expected shipment label to be attached"
    assert_predicate shipment.billable_amount, :zero?
  end
end
