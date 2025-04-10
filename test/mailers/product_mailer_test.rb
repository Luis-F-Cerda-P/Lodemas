require "test_helper"

class ProductMailerTest < ActionMailer::TestCase
  test "in_stock" do
    mail = ProductMailer.with(product: products(:shoes), subscriber: subscribers(:david)).in_stock
    assert_equal "In stock", mail.subject
    assert_equal [ "david@david.com" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Good news!", mail.body.encoded
  end
end
