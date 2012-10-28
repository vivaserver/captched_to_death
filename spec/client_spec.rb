require_relative 'spec_helper'
require 'minitest/mock'

describe CaptchedToDeath::Client do
  before do
    @client = MiniTest::Mock.new
    @response = {"captcha" => 1234, "is_correct" => true, "text" => "slothrop"}
    @challenge = 'http://firpo.nic.ar/tmp/13E43610A2A23C88E4355CF3ADD2579C.jpg'
  end

  it 'is the correct way of using mocks' do
    @client.expect :captcha, @response, [1234]
    @client.captcha(1234).must_equal @response
    assert @client.verify

    @client.expect :decode, @response, [@challenge]
    @client.decode(@challenge).must_equal @response
    assert @client.verify
  end

  it 'does not decode challenge if missing API credentials' do
    proc {
      CaptchedToDeath::Client.new.decode(@challenge)
    }.must_raise ArgumentError
  end
end
