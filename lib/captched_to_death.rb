require "captched_to_death/version"
require "captched_to_death/client"

module CaptchedToDeath
  API_URI = 'http://api.dbcapi.me/api/captcha'

  class NoCreditError < StandardError; end
  class RejectedError < StandardError; end
end
