require_relative 'spec_helper'

describe CaptchedToDeath::Server do
  it 'checks for remote server status' do
    status = CaptchedToDeath::Server.status
    status.must_be_instance_of Hash
    status.keys.must_equal ["status", "todays_accuracy", "solved_in", "is_service_overloaded"]
    # NOTE: status["solved_in"] integer means Seconds
  end
end
