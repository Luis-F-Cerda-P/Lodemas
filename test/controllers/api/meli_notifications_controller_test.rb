require "test_helper"

class Api::MeliNotificationsControllerTest < ActionDispatch::IntegrationTest
  test "should respond with success to valid POST" do
    post api_meli_notifications_url, params: {
      resource: "/orders/2195160686",
      user_id: 468424240,
      topic: "orders_v2",
      application_id: 5503910054141466,
      attempts: 1,
      sent: "2019-10-30T16:19:20.129Z",
      received: "2019-10-30T16:19:20.106Z"
    }, as: :json

    assert_response :success
  end
end
