require_relative 'spec_helper'
require 'minitest/mock'

describe CaptchedToDeath::Client do
  before do
    @username = ENV['DECAPTCHER_USERNAME']
    @password = ENV['DECAPTCHER_PASSWORD']
  end

  it 'is the correct way of using mocks' do
    client = MiniTest::Mock.new
    response = {"captcha" => 1234, "is_correct" => true, "text" => "slothrop"}
    challenge = 'http://firpo.nic.ar/tmp/13E43610A2A23C88E4355CF3ADD2579C.jpg'

    client.expect :captcha, response, [1234]
    client.captcha(1234).must_equal response
    assert client.verify

    client.expect :decode, response, [challenge]
    client.decode(challenge).must_equal response
    assert client.verify
  end

  describe 'when checking balance' do
    it 'does not work if missing API credentials' do
      proc { CaptchedToDeath::Client.new.balance }.must_raise CaptchedToDeath::RejectedError
    end

    it 'responds with account details' do
      if @username && @password
        balance = CaptchedToDeath::Client.new(@username,@password).balance
        balance.must_be_instance_of Hash
        balance.keys.must_equal ["is_banned", "status", "rate", "balance", "user"]
        refute balance["is_banned"]
        # NOTE: balance["balance"] float means Cents
      end
    end
  end

  describe 'when polling for uploaded CAPTCHA status' do
    it 'raises custom exception on unexisting CAPTCHA id' do
      proc { CaptchedToDeath::Client.new.captcha 'abcdef' }.must_raise CaptchedToDeath::NotFound
    end
  end

  describe 'when decoding challenges' do
    it 'does not work if missing API credentials' do
      proc { CaptchedToDeath::Client.new.decode(@challenge) }.must_raise CaptchedToDeath::RejectedError
    end
  end

  describe 'when reporting wrongly resolved captchas' do
    it 'does not work if missing API credentials' do
      proc { CaptchedToDeath::Client.new.report(:some_captcha_id) }.must_raise CaptchedToDeath::RejectedError
    end
  end
end
