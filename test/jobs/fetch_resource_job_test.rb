require "test_helper"

class FetchResourceJobTest < ActiveJob::TestCase
  setup do
    @meli_notification = meli_notifications(:three)
  end
end
