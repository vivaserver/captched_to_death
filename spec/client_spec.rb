require_relative 'spec_helper'
require 'minitest/mock'

describe CaptchedToDeath::Client do
  before do
    @client = MiniTest::Mock.new
    @response = {"captcha" => 1234, "is_correct" => true, "text" => "slothrop"}
    @challenge = 'http://firpo.nic.ar/tmp/13E43610A2A23C88E4355CF3ADD2579C.jpg'
    # warning: LIVE account
    @username = 'vivab0rg'
    @password = 'deathargon'
  end

  it 'is the correct way of using mocks' do
    @client.expect :captcha, @response, [1234]
    @client.captcha(1234).must_equal @response
    assert @client.verify

    @client.expect :decode, @response, [@challenge]
    @client.decode(@challenge).must_equal @response
    assert @client.verify
  end

  describe 'when checking balance' do
    it 'does not work if missing API credentials' do
      proc {
        CaptchedToDeath::Client.new.balance
      }.must_raise ArgumentError
    end

    it 'responds with account details' do
      balance = CaptchedToDeath::Client.new(@username,@password).balance
      balance.must_be_instance_of Hash
      balance.keys.must_equal ["is_banned", "status", "rate", "balance", "user"]
      refute balance["is_banned"]
      # NOTE: balance["balance"] float means Cents
    end
  end

  describe 'when decoding challenges' do
    it 'does not work if missing API credentials' do
      proc {
        CaptchedToDeath::Client.new.decode(@challenge)
      }.must_raise ArgumentError
    end
  end
end
