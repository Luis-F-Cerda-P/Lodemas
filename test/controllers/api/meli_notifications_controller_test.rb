require "test_helper"

class Api::MeliNotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should respond with success to valid POST with whitelisted IP" do
    post api_meli_notifications_url,
      params: {
        resource: "/orders/2195160686",
        user_id: 468424240,
        topic: "orders_v2",
        application_id: 5503910054141466,
        attempts: 1,
        sent: "2019-10-30T16:19:20.129Z",
        received: "2019-10-30T16:19:20.106Z"
      },
      as: :json,
      headers: {
        "REMOTE_ADDR": "54.88.218.97"  # Directly set the remote IP
      }

    assert_response :success
  end

  test "should respond with forbidden when IP is not whitelisted" do
    post api_meli_notifications_url,
      params: {
        resource: "/orders/2195160686",
        user_id: 468424240,
        topic: "orders_v2",
        application_id: 5503910054141466,
        attempts: 1,
        sent: "2019-10-30T16:19:20.129Z",
        received: "2019-10-30T16:19:20.106Z"
      },
      as: :json,
      headers: {
        "REMOTE_ADDR": "192.168.0.1"  # Non-whitelisted IP
      }

    assert_response :forbidden
  end
end
