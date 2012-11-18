require_relative 'spec_helper'
require 'minitest/mock'

describe CaptchedToDeath::Client do
  before do
    @username = ENV['DECAPTCHER_USERNAME']
    @password = ENV['DECAPTCHER_PASSWORD']

    # some CAPTCHA challenges for testing purposes:
    # http://i.imgur.com/vOj5f.jpg (jd472tFO)
    # http://i.imgur.com/iWlb4.png
    # http://i.imgur.com/LsbEV.gif
    # http://i.imgur.com/9a1da.jpg (jFnq60dd) 
    # http://i.imgur.com/nRITM.jpg (ByKBPX9Z)
    # http://i.imgur.com/mr3E0.jpg (6gOFiI01)
    # http://i.imgur.com/uY3RN.jpg (gTKDrGtF)
    @challenge = 'http://i.imgur.com/vOj5f.jpg'
  end

  it 'is the correct way of using mocks' do
    client = MiniTest::Mock.new
    response = {"captcha" => 123456789, "is_correct" => true, "text" => "jd472tFO"}

    client.expect :captcha, response, [123456789]
    client.captcha(123456789).must_equal response
    assert client.verify

    client.expect :decode, response, [@challenge]
    client.decode(@challenge).must_equal response
    assert client.verify
  end

  describe 'when checking balance' do
    subject do
      CaptchedToDeath::Client.new(@username,@password)
    end

    it 'responds with account details or does not work if missing API credentials' do
      if @username && @password
        balance = subject.balance
        balance.must_be_instance_of Hash
        balance.keys.must_equal ["is_banned", "status", "rate", "balance", "user"]  # NOTE: "balance" float means Cents
        refute balance["is_banned"]
      else
        proc { subject.balance }.must_raise CaptchedToDeath::RejectedError
      end
    end
  end

  describe 'when polling for uploaded CAPTCHA status' do
    subject do
      CaptchedToDeath::Client.new
    end

    it 'raises custom exception on unexisting CAPTCHA id' do
      proc { subject.captcha(:captcha_id) }.must_raise CaptchedToDeath::NotFound
    end
  end

  describe 'when decoding challenges' do
    subject do
      CaptchedToDeath::Client.new
    end

    it 'does not work if missing API credentials' do
      proc { subject.decode(@challenge) }.must_raise CaptchedToDeath::RejectedError
    end
  end

  describe 'when reporting wrongly resolved captchas' do
    subject do
      CaptchedToDeath::Client.new
    end

    it 'does not work if missing API credentials' do
      proc { subject.report(:captcha_id) }.must_raise CaptchedToDeath::RejectedError
    end
  end
end
