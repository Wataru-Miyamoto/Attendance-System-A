require 'test_helper'

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  test "should get update" do
    get attendances_update_url
    assert_response :success
  end

end
