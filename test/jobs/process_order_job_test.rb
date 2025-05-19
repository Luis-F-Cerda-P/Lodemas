require "test_helper"
require "minitest/mock"

class ProcessOrderJobTest < ActiveJob::TestCase
  setup do
    @order_A1 = File.read("./test/fixtures/files/order_A1.json")
    @order_A2 = File.read("./test/fixtures/files/order_A2.json")
    @order_B = File.read("./test/fixtures/files/order_B.json")
    @order_A1_hash = JSON.parse(@order_A1)
    @order_A2_hash = JSON.parse(@order_A2)
    @order_B_hash = JSON.parse(@order_B)
    @user = users(:one)
    @pack_A_id = JSON.parse(@order_A1)["pack_id"]
  end
  test "Creates a single Order, a single Shipment and two OrderItem records when passed two novel pack_order json strings" do
    mock_client = Minitest::Mock.new
    # Define expected response from the get method
    mock_pack_data = JSON.parse(File.read("./test/fixtures/files/pack_A.json"))
    # Expect the get method to be called with specific parameters
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]
    # Replace the actual MeliApiClient with our mock
    MeliApiClient.stub :new, mock_client do
      assert_difference -> { Order.count } => 1, -> { OrderItem.count } => 2, -> { Shipment.count } => 1 do
        ProcessOrderJob.perform_now(@order_A1, @user.id)
        ProcessOrderJob.perform_now(@order_A2, @user.id)
      end
    end

    # Verify all expected methods were called
    mock_client.verify

    # Verify the data was saved correctly
    order = Order.find_by(human_readable_id: @pack_A_id)
    assert_equal order.order_items.first.sale_channel_id, @order_A1_hash["id"]
    assert_equal order.order_items.last.sale_channel_id, @order_A2_hash["id"]
    assert_equal order.order_items.count, order.expected_item_count
    assert_equal @user, order.user
    assert_equal @pack_A_id, order.pack_id
    assert_equal "mercadolibre", order.source_channel
  end
  test "Creates an Order record when passed a novel pack_order json string" do
    mock_client = Minitest::Mock.new
    # Define expected response from the get method
    mock_pack_data = JSON.parse(File.read("./test/fixtures/files/pack_A.json"))
    # Expect the get method to be called with specific parameters
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]
    # Replace the actual MeliApiClient with our mock
    MeliApiClient.stub :new, mock_client do
      assert_difference -> { Order.count } => 1, -> { OrderItem.count } => 1, -> { Shipment.count } => 1 do
        ProcessOrderJob.perform_now(@order_A1, @user.id)
      end
    end

    # Verify all expected methods were called
    mock_client.verify

    # Verify the data was saved correctly
    order = Order.find_by(human_readable_id: @pack_A_id)
    assert_equal 2, order.expected_item_count
    assert_equal @user, order.user
    assert_equal @pack_A_id, order.pack_id
    assert_equal "mercadolibre", order.source_channel
  end
  test "Creates an Order record when passed a novel non-pack_order json string" do
    mock_client = Minitest::Mock.new
    # Define expected response from the get method
    mock_pack_data = JSON.parse(File.read("./test/fixtures/files/pack_A.json"))
    # Expect the get method to be called with specific parameters
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]
    # Replace the actual MeliApiClient with our mock
    MeliApiClient.stub :new, mock_client do
      assert_difference -> { Order.count } => 1, -> { OrderItem.count } => 1, -> { Shipment.count } => 1 do
        ProcessOrderJob.perform_now(@order_A1, @user.id)
      end
    end

    # Verify all expected methods were called
    mock_client.verify

    # Verify the data was saved correctly
    order = Order.find_by(human_readable_id: @pack_A_id)
    assert_equal 2, order.expected_item_count
    assert_equal @user, order.user
    assert_equal @pack_A_id, order.pack_id
    assert_equal "mercadolibre", order.source_channel
  end

  test "Creates a single Order record when passed the same Json string twice" do
    mock_client = Minitest::Mock.new
    # Define expected response from the get method
    mock_pack_data = JSON.parse(File.read("./test/fixtures/files/pack_A.json"))
    # Expect the get method to be called with specific parameters
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]
    # Replace the actual MeliApiClient with our mock
    MeliApiClient.stub :new, mock_client do
      assert_difference -> { Order.count } => 1, -> { OrderItem.count } => 1, -> { Shipment.count } => 1 do
        ProcessOrderJob.perform_now(@order_A1, @user.id)
        ProcessOrderJob.perform_now(@order_A1, @user.id)
      end
    end
  end
  test "Creates a single Order record with two distinct OrderItems, even when passed the individual order_items multiple times" do
    mock_client = Minitest::Mock.new
    # Define expected response from the get method
    mock_pack_data = JSON.parse(File.read("./test/fixtures/files/pack_A.json"))
    # Expect the get method to be called with specific parameters
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]
    # Replace the actual MeliApiClient with our mock
    MeliApiClient.stub :new, mock_client do
      assert_difference -> { Order.count } => 1, -> { OrderItem.count } => 2, -> { Shipment.count } => 1 do
        ProcessOrderJob.perform_now(@order_A1, @user.id)
        ProcessOrderJob.perform_now(@order_A1, @user.id)
        ProcessOrderJob.perform_now(@order_A2, @user.id)
        ProcessOrderJob.perform_now(@order_A2, @user.id)
      end
    end
  end
  test "Records billable_amount field for individual order_items on pack orders" do
    mock_client = Minitest::Mock.new
    # Define expected response from the get method
    mock_pack_data = JSON.parse(File.read("./test/fixtures/files/pack_A.json"))
    # Expect the get method to be called with specific parameters
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]
    # Replace the actual MeliApiClient with our mock
    MeliApiClient.stub :new, mock_client do
      ProcessOrderJob.perform_now(@order_A1, @user.id)
      ProcessOrderJob.perform_now(@order_A2, @user.id)
    end

    order_item_A1 = OrderItem.find_by(sale_channel_id: @order_A1_hash["id"])
    assert_equal 13990, order_item_A1.billable_amount
    order_item_A2 = OrderItem.find_by(sale_channel_id: @order_A2_hash["id"])
    assert_equal 8990, order_item_A2.billable_amount
  end

  test "handles concurrent processing of the same order" do
    mock_client = Minitest::Mock.new
    mock_pack_data = JSON.parse(File.read("./test/fixtures/files/pack_A.json"))
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]

    MeliApiClient.stub :new, mock_client do
      # Simulate concurrent processing
      threads = []
      2.times do
        threads << Thread.new do
          ProcessOrderJob.perform_now(@order_A1, @user.id)
        end
      end
      threads.each(&:join)

      # Check that we still have only one order
      assert_equal 1, Order.where(human_readable_id: @pack_A_id).count
      assert_equal 1, OrderItem.where(sale_channel_id: @order_A1_hash["id"]).count
    end
  end
  test "Correctly records the 'billable_amount' field" do
    assert_difference -> { Order.count } => 1, -> { OrderItem.count } => 1, -> { Shipment.count } => 1 do
      ProcessOrderJob.perform_now(@order_B, @user.id)
    end

    # Verify the data was saved correctly
    order_item = OrderItem.find_by(sale_channel_id: @order_B_hash["id"])
    assert_equal 8790, order_item.billable_amount
  end

  test "Enqueues the ProcessShipmentJob when a new Order record is created" do
    assert_enqueued_with(job: ProcessShipmentJob) do
      ProcessOrderJob.perform_now(@order_B, @user.id)
    end
  end
  test "Enqueues the BillCalculationJob once per order, even if the order is multi-item" do
    mock_client = Minitest::Mock.new
    # Define expected response from the get method
    mock_pack_data = JSON.parse(File.read("./test/fixtures/files/pack_A.json"))
    # Expect the get method to be called with specific parameters
    mock_client.expect :get, mock_pack_data, [ "packs/#{@pack_A_id}" ]
    # Replace the actual MeliApiClient with our mock
    MeliApiClient.stub :new, mock_client do
      assert_enqueued_jobs 0
      ProcessOrderJob.perform_now(@order_A1, @user.id)
      assert_enqueued_jobs 1
      ProcessOrderJob.perform_now(@order_A2, @user.id)
      assert_enqueued_jobs 1
    end
  end
end
